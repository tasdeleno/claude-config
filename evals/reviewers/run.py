"""Reviewer eval seti: gomulu hatali fixture'lar + FP tuzaklari.

Her vaka gecici bir git reposunda staged diff olarak kurulur, ilgili reviewer
`claude -p --agent <ad>` ile kosulur, rapor regex ile notlanir.

Kullanim:  python -I run.py <etiket> [vaka_id ...]
Cikti:     results/<etiket>/<vaka>.txt  ve  results/<etiket>.tsv
Kolonlar:  case agent kind hit fp verdict repo_clean seconds cost_usd
  hit        : bug vakasinda beklenen bulgu raporda var mi (dosya adi + anahtar kelime)
  fp         : tuzak vakasinda yasak kalip raporda var mi (1 = yanlis alarm)
  verdict    : raporda `Verdict:` satiri var mi
  repo_clean : agent repoda dosya yaratti/degistirdi mi (0 = yazdi)
"""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

HERE = Path(__file__).resolve().parent
PROMPT = ("Commit oncesi review. Repo: {repo}. Staged degisikligi incele (`git diff --staged`), "
          "bulgularini raporla. Proje bir Laravel 12 / PHP 8.3 (MySQL 8) + React Native (Expo) urunu.")
ALLOWED = ("Read,Grep,Glob,Bash(git diff:*),Bash(git status:*),Bash(git log:*),"
           "Bash(git show:*),Bash(ls:*),Bash(cat:*)")

# base = ilk commit, change = staged degisiklik. expect: bug vakasi; forbid: tuzak vakasi.
CASES = {
    "F1-mass-assign-php": {
        "agent": "php-reviewer",
        "base": {"app/Models/User.php": "<?php\nnamespace App\\Models;\n\nuse Illuminate\\Database\\Eloquent\\Model;\n\nclass User extends Model\n{\n    protected $fillable = ['name', 'email'];\n}\n"},
        "change": {
            "app/Models/User.php": "<?php\nnamespace App\\Models;\n\nuse Illuminate\\Database\\Eloquent\\Model;\n\nclass User extends Model\n{\n    protected $guarded = [];\n}\n",
            "app/Http/Controllers/ProfileController.php": "<?php\nnamespace App\\Http\\Controllers;\n\nuse App\\Models\\User;\nuse Illuminate\\Http\\Request;\n\nclass ProfileController extends Controller\n{\n    public function update(Request $request)\n    {\n        $user = $request->user();\n        $user->update($request->all());\n\n        return back();\n    }\n}\n",
        },
        "expect": {"file": "ProfileController", "kw": r"mass.?assign|guarded|->all\(\)|is_admin|toplu atama"},
    },
    "F1-mass-assign-security": {"same_as": "F1-mass-assign-php", "agent": "security-reviewer"},
    "F2-swallowed-catch": {
        "agent": "silent-failure-hunter",
        "base": {"app/Services/AlertService.php": "<?php\nnamespace App\\Services;\n\nclass AlertService\n{\n}\n"},
        "change": {"app/Services/AlertService.php": "<?php\nnamespace App\\Services;\n\nuse Illuminate\\Support\\Facades\\Cache;\nuse Illuminate\\Support\\Facades\\Http;\n\nclass AlertService\n{\n    public function notifyDbDown(string $message): void\n    {\n        try {\n            if (Cache::add('alert:db-down', 1, 600)) {\n                Http::post(config('services.telegram.url'), ['text' => $message]);\n            }\n        } catch (\\Throwable $e) {\n        }\n    }\n}\n"},
        "expect": {"file": "AlertService", "kw": r"catch|swallow|yut|sessiz|silent"},
    },
    "F3-floating-promise": {
        "agent": "typescript-reviewer",
        "base": {"src/sync.ts": "export async function save(id: string): Promise<void> {\n  await fetch(`/api/items/${id}`, { method: 'POST' });\n}\n"},
        "change": {"src/sync.ts": "export async function save(id: string): Promise<void> {\n  await fetch(`/api/items/${id}`, { method: 'POST' });\n}\n\nexport async function syncAll(ids: string[]): Promise<string> {\n  ids.forEach(async (id) => {\n    await save(id);\n  });\n  return 'done';\n}\n"},
        "expect": {"file": "sync.ts", "kw": r"floating|unhandled|Promise\.all|forEach.{0,80}(await|beklem)"},
    },
    "F4-mysql-length": {
        "agent": "database-reviewer",
        "base": {".env.example": "APP_NAME=Demo\nDB_CONNECTION=mysql\nDB_DATABASE=demo\n",
                 "phpunit.xml": "<phpunit><php><env name=\"DB_CONNECTION\" value=\"sqlite\"/><env name=\"DB_DATABASE\" value=\":memory:\"/></php></phpunit>\n"},
        "change": {
            "database/migrations/2026_10_16_000000_create_leads_table.php": "<?php\n\nuse Illuminate\\Database\\Migrations\\Migration;\nuse Illuminate\\Database\\Schema\\Blueprint;\nuse Illuminate\\Support\\Facades\\Schema;\n\nreturn new class extends Migration\n{\n    public function up(): void\n    {\n        Schema::create('leads', function (Blueprint $table) {\n            $table->id();\n            $table->string('name', 50);\n            $table->string('message', 100);\n            $table->timestamps();\n        });\n    }\n\n    public function down(): void\n    {\n        Schema::dropIfExists('leads');\n    }\n};\n",
            "app/Http/Controllers/LeadController.php": "<?php\nnamespace App\\Http\\Controllers;\n\nuse Illuminate\\Http\\Request;\nuse Illuminate\\Support\\Facades\\DB;\n\nclass LeadController extends Controller\n{\n    public function store(Request $request)\n    {\n        $data = $request->validate(['name' => 'required|string', 'message' => 'required|string']);\n        DB::table('leads')->insert($data + ['created_at' => now(), 'updated_at' => now()]);\n\n        return response()->noContent();\n    }\n}\n",
        },
        "expect": {"file": "LeadController|create_leads", "kw": r"max:|Data too long|truncat|uzunluk|22001"},
    },
    "F5-rn-token-storage": {
        "agent": "react-reviewer",
        "base": {"package.json": "{\n  \"name\": \"app\",\n  \"dependencies\": {\"expo\": \"~57.0.0\", \"react-native\": \"0.86.0\", \"@react-native-async-storage/async-storage\": \"2.2.0\", \"expo-secure-store\": \"~15.0.0\"}\n}\n"},
        "change": {"src/auth/LoginScreen.tsx": "import AsyncStorage from '@react-native-async-storage/async-storage';\nimport { Pressable, Text, View } from 'react-native';\nimport { login } from '../api';\n\nexport function LoginScreen({ email, password }: { email: string; password: string }) {\n  async function onPress() {\n    const { token } = await login(email, password);\n    await AsyncStorage.setItem('auth_token', token);\n  }\n  return (\n    <View>\n      <Pressable onPress={onPress}>\n        <Text>Giris</Text>\n      </Pressable>\n    </View>\n  );\n}\n"},
        "expect": {"file": "LoginScreen", "kw": r"SecureStore|secure-store|Keychain|Keystore"},
    },
    "T1-env-example": {
        "agent": "security-reviewer",
        "base": {"config/services.php": "<?php\n\nreturn [];\n"},
        "change": {
            ".env.example": "APP_NAME=Demo\nSTRIPE_KEY=pk_test_your_key_here\nSTRIPE_SECRET=sk_test_your_secret_here\n",
            "config/services.php": "<?php\n\nreturn [\n    'stripe' => [\n        'key' => env('STRIPE_KEY'),\n        'secret' => env('STRIPE_SECRET'),\n    ],\n];\n",
        },
        # .env.example satirina CRITICAL/HIGH demek = yanlis alarm
        "forbid": r"(?im)^.*\.env\.example.*\b(CRITICAL|HIGH|KR[İI]T[İI]K|Y[ÜU]KSEK)\b.*$|^.*\b(CRITICAL|HIGH|KR[İI]T[İI]K|Y[ÜU]KSEK)\b.*\.env\.example.*$",
    },
    "T2-public-rate-limit": {
        "agent": "security-reviewer",
        "base": {"routes/web.php": "<?php\n\nuse Illuminate\\Support\\Facades\\Route;\n"},
        "change": {"routes/web.php": "<?php\n\nuse App\\Http\\Controllers\\ProductController;\nuse Illuminate\\Support\\Facades\\Route;\n\nRoute::get('/products', [ProductController::class, 'index'])->name('products.index');\n",
                   "app/Http/Controllers/ProductController.php": "<?php\nnamespace App\\Http\\Controllers;\n\nuse App\\Models\\Product;\n\nclass ProductController extends Controller\n{\n    public function index()\n    {\n        return view('products.index', ['products' => Product::query()->latest()->paginate(20)]);\n    }\n}\n"},
        # herkese acik listeleme rotasinda rate limit eksigini HIGH/CRITICAL saymak = yanlis alarm
        "forbid": r"(?im)^.*(rate.?limit|throttle).*\b(CRITICAL|HIGH|KR[İI]T[İI]K|Y[ÜU]KSEK)\b.*$|^.*\b(CRITICAL|HIGH|KR[İI]T[İI]K|Y[ÜU]KSEK)\b.*(rate.?limit|throttle).*$",
    },
}


def resolve(case_id):
    c = dict(CASES[case_id])
    if "same_as" in c:
        base = dict(CASES[c.pop("same_as")])
        base.update(c)
        c = base
    return c


def git(repo, *args, check=False):
    # global signing/hooks must not alter the fixture
    cmd = ["git", "-c", "commit.gpgsign=false", "-c", "core.hooksPath=NUL", "-C", str(repo), *args]
    return subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", check=check)


def rmtree(path):
    # git object files are read-only on Windows; clear the bit and retry
    shutil.rmtree(path, onexc=lambda fn, p, _e: (os.chmod(p, 0o700), fn(p)))


def write_files(repo, files):
    for rel, content in files.items():
        p = repo / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(content, encoding="utf-8", newline="\n")


def build_repo(case):
    repo = Path(tempfile.mkdtemp(prefix="reviewer-eval-"))
    try:
        git(repo, "init", "-q", check=True)
        git(repo, "config", "user.email", "eval@example.invalid", check=True)
        git(repo, "config", "user.name", "eval", check=True)
        git(repo, "config", "core.autocrlf", "false", check=True)
        write_files(repo, case["base"])
        git(repo, "add", "-A", check=True)
        git(repo, "commit", "-q", "-m", "base", check=True)
        write_files(repo, case["change"])
        git(repo, "add", "-A", check=True)
    except Exception:
        rmtree(repo)
        raise
    return repo


def snapshot(repo):
    return git(repo, "status", "--porcelain", "--untracked-files=all").stdout


def run_case(label, case_id):
    case = resolve(case_id)
    repo = build_repo(case)
    before = snapshot(repo)
    env = dict(os.environ, ECC_GATEGUARD="off", DOC_UPDATE_STOP_CHECK="off", ECC_PHP_STOP_CHECK="off",
               ECC_HOOK_PROFILE="minimal")
    cmd = [shutil.which("claude") or "claude", "-p", PROMPT.format(repo=repo.as_posix()),
           "--agent", case["agent"], "--output-format", "json", "--allowedTools", ALLOWED,
           "--no-session-persistence", "--max-budget-usd", "2"]
    t0 = time.time()
    try:
        proc = subprocess.run(cmd, cwd=repo, capture_output=True, text=True, encoding="utf-8", env=env, timeout=1200)
        try:
            out = json.loads(proc.stdout)
        except json.JSONDecodeError:
            out = None
        if isinstance(out, dict) and not out.get("is_error") and isinstance(out.get("result"), str) and out["result"]:
            report, cost = out["result"], out.get("total_cost_usd", "")
        else:  # no JSON, error result or empty report -> graded as ERR (cost "")
            report, cost = proc.stdout + "\n[stderr]\n" + proc.stderr, ""
    except (subprocess.TimeoutExpired, OSError) as e:
        report, cost = f"[runner error] {e!r}", ""
    secs = round(time.time() - t0)
    try:
        clean = int(snapshot(repo) == before)
    finally:
        rmtree(repo)

    outdir = HERE / "results" / label
    outdir.mkdir(parents=True, exist_ok=True)
    (outdir / f"{case_id}.txt").write_text(report, encoding="utf-8")
    meta = {"clean": clean, "secs": secs, "cost": cost}
    (outdir / f"{case_id}.json").write_text(json.dumps(meta), encoding="utf-8")
    return grade(case_id, report, meta)


def grade(case_id, report, meta):
    case = resolve(case_id)
    kind = "bug" if "expect" in case else "trap"
    if meta["cost"] == "":  # claude calismadi (JSON yok): reviewer sonucu degil, altyapi hatasi
        return [case_id, case["agent"], kind, "ERR", "ERR", "ERR", meta["clean"], meta["secs"], ""]
    hit = fp = ""
    if kind == "bug":
        e = case["expect"]
        hit = int(bool(re.search(e["file"], report)) and bool(re.search(e["kw"], report, re.I)))
    else:
        fp = int(bool(re.search(case["forbid"], report)))
    verdict = int(bool(re.search(r"(?im)^\W*verdict\s*:", report)))
    return [case_id, case["agent"], kind, hit, fp, verdict, meta["clean"], meta["secs"], meta["cost"]]


def regrade(label, case_id):
    outdir = HERE / "results" / label
    txt, meta = outdir / f"{case_id}.txt", outdir / f"{case_id}.json"
    if not (txt.exists() and meta.exists()):
        return grade(case_id, "", {"clean": "", "secs": "", "cost": ""})  # never ran -> ERR
    return grade(case_id, txt.read_text(encoding="utf-8"), json.loads(meta.read_text(encoding="utf-8")))


def main():
    """python -I run.py <etiket> [vaka...]   |   python -I run.py <etiket> --grade  (kosmadan yeniden notla)"""
    if len(sys.argv) < 2 or sys.argv[1].startswith("-"):
        sys.exit("usage: python -I run.py <label> [case ...] [--grade]")
    label = sys.argv[1]
    args = sys.argv[2:]
    only_grade = "--grade" in args
    ids = [a for a in args if a != "--grade"] or list(CASES)
    if only_grade:
        rows = [regrade(label, i) for i in ids]
    else:
        # ponytail: 4 paralel; kota/limit hatasi gorulurse dusur
        with ThreadPoolExecutor(max_workers=4) as ex:
            rows = list(ex.map(lambda i: run_case(label, i), ids))
    tsv = HERE / "results" / f"{label}.tsv"
    lines = ["case\tagent\tkind\thit\tfp\tverdict\trepo_clean\tseconds\tcost_usd"]
    lines += ["\t".join(str(x) for x in r) for r in rows]
    tsv.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines))


if __name__ == "__main__":
    main()
