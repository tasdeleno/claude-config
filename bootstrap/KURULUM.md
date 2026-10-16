# Kurulum ve Bakım Rehberi — `~/.claude` (claude-config)

Bu repo Claude Code kurulumunun tamamıdır: talimatlar, agent'lar, skill'ler, hook'lar, ayarlar,
memory ve bunları her bilgisayara kuran/senkronlayan script'ler. **Herhangi bir Windows
bilgisayarda, herhangi bir kullanıcı adıyla** çalışır (bu PC: `tasde`, laptop: `X`).

İlk kurulumdan sonra senkron **otomatiktir**: bir makinede commit atılan her şey, diğer makinede
bir sonraki Claude Code açılışında gelir.

İçindekiler
1. [Neler senkronlanır, neler senkronlanmaz](#1-neler-senkronlanır-neler-senkronlanmaz)
2. [Önkoşullar](#2-önkoşullar)
3. [Sıfırdan kurulum (yeni bilgisayar)](#3-sıfırdan-kurulum-yeni-bilgisayar)
4. [Daha önce clone edilmiş bilgisayarı güncelleme (laptop)](#4-daha-önce-clone-edilmiş-bilgisayarı-güncelleme-laptop)
5. [İsteğe bağlı: `/brag` tam mod (Hyperframes video)](#5-isteğe-bağlı-brag-tam-mod-hyperframes-video)
6. [Otomatik senkron nasıl çalışır](#6-otomatik-senkron-nasıl-çalışır)
7. [Taşınabilir `settings.json`](#7-taşınabilir-settingsjson)
8. [Memory senkronu](#8-memory-senkronu)
9. [ECC (cherry-pick kurulum) ve pin yükseltme](#9-ecc-cherry-pick-kurulum-ve-pin-yükseltme)
10. [Plugin ekleme / kaldırma](#10-plugin-ekleme--kaldırma)
11. [Kurulumu doğrulama](#11-kurulumu-doğrulama)
12. [Sorun giderme](#12-sorun-giderme)
13. [Bakım: reviewer eval seti](#13-bakım-reviewer-eval-seti)
14. [Bilinen sınırlar](#14-bilinen-sınırlar)

---

## 1. Neler senkronlanır, neler senkronlanmaz

| Senkronlanır (git) | Senkronlanmaz | Nasıl geri gelir |
|---|---|---|
| `CLAUDE.md`, `AGENTS.md` | `.credentials.json`, secret'lar | `claude` ile login |
| `agents/`, `commands/`, `hooks/` | `settings.local.json` (makineye özel izinler) | — |
| `skills/` (yerel skill'ler) | `skills/synced`, `plugins/synced` | claude.ai hesabından login'de akar |
| `settings.json` (taşınabilir biçimde, §7) | `plugins/` ağacının tamamı | `bootstrap/plugins.ps1` (marketplace plugin'leri) |
| memory (`projects/C--Users-tasde--claude/memory/`) | ECC klonu (`plugins/ecc`) | `bootstrap/setup.ps1` (pinli commit + yama) |
| `bootstrap/`, `evals/`, `reports/` | Orca hook'ları | Orca uygulaması kendisi yazar (§4 notu) |
| `backups/agents-archive-*/` | junction skill'ler (`orchestration`, `orca-cli`, `computer-use`) | Orca kurulumu |
| | FFmpeg, Kokoro, Hyperframes CLI | §5 |
| | cache, log, session, `hooks-state/` | çalışma sırasında oluşur |

Ayrıntılı liste: kökteki `.gitignore` (allowlist: önce her şey yok sayılır, sonra açılır).

## 2. Önkoşullar

| Araç | Neden | Kontrol |
|---|---|---|
| **Git for Windows** (Git Bash dahil) | repo + Claude Code hook'ları Git Bash'te koşar | `git --version` |
| **Node.js 22+** | hook'lar, ECC, clean filter, Hyperframes | `node --version` |
| **Python 3.11+** | brag müzik analizi, Kokoro, eval seti | `python --version` (`python3` değil) |
| **uv** (önerilir) | brag'in Python bağımlılıklarını kendisi kurar | `uv --version` |
| **Claude Code CLI** | — | `claude --version` |
| **GitHub CLI + login** | private repoyu pull/push etmek | `gh auth status` |
| Orca (isteğe bağlı) | Orca worktree/hook'ları | — |

Yönetici yetkisi **gerekmez**. Bu PC'de doğrulanan sürümler: git 2.54, Node 24.15, Python 3.14,
uv 0.11, gh 2.95, Claude Code 2.1.

## 3. Sıfırdan kurulum (yeni bilgisayar)

PowerShell'de (Windows PowerShell 5.1 yeterli; `pwsh` gerekmez):

```powershell
# 1) GitHub'a giriş (private repo için)
gh auth login

# 2) Varsa mevcut ~/.claude'u yedekle, repoyu clone et
cd $HOME
if (Test-Path .claude) { Rename-Item .claude ".claude.bak-$(Get-Date -f yyyyMMdd-HHmmss)" }
git clone https://github.com/tasdeleno/claude-config .claude
cd .claude

# 3) Tek seferlik kurulum
powershell -ExecutionPolicy Bypass -File ./bootstrap/setup.ps1

# 4) Claude Code'a giriş (hesaba bağlı skill/plugin'ler geri akar), sonra çık
claude

# 5) Marketplace plugin'lerini kur
powershell -ExecutionPolicy Bypass -File ./bootstrap/plugins.ps1

# 6) Claude Code'u yeniden başlat — bundan sonrası otomatik (§6)
```

`setup.ps1` ne yapar:
- ECC'yi `plugins/ecc`'ye pinli commit'ten clone eder, `bootstrap/ecc-local.patch`'i uygular, `npm install`.
- `settings.json` için git clean filter'ı bu klonun yerel git config'ine yazar (§7).
- Memory'yi bu bilgisayarın kullanıcı adına göre doğru klasöre kopyalar (§8).
- Tekrar çalıştırmak güvenlidir (idempotent).

`plugins.ps1` ne yapar: listedeki marketplace ve plugin'lerden **yalnız eksik olanları** kurar
(güncel liste dosyanın başında; şu an 11 marketplace, 12 plugin — brag ve hyperframes dahil).

## 4. Daha önce clone edilmiş bilgisayarı güncelleme (laptop)

Laptopta repo otomatik senkron eklenmeden önce clone edildiyse, **bir kerelik** şunlar gerekir.
Orca o makinede `settings.json`'u yeniden yazmış olabilir; önce o yerel değişiklik geri alınır:

```powershell
git -C $HOME/.claude status                     # başka yerel değişiklik var mı bak
git -C $HOME/.claude checkout -- settings.json  # Orca'nın yeniden yazdığı hali at
git -C $HOME/.claude pull
powershell -ExecutionPolicy Bypass -File $HOME/.claude/bootstrap/setup.ps1
powershell -ExecutionPolicy Bypass -File $HOME/.claude/bootstrap/plugins.ps1
# Claude Code'u yeniden başlat
```

- `status`'ta `settings.json` dışında değişiklik varsa (ör. memory), önce commit et ya da `git stash`.
- Orca kendi hook'larını `settings.json`'a yazar (bu PC'de mevcut hook'ları yeniden yazdığı
  gözlendi); clean filter sayesinde bu git'te değişiklik olarak görünmez. Orca'nın hook'ları hiç
  olmayan bir `settings.json`'a kendiliğinden ekleyip eklemediği **doğrulanmadı** — Orca
  özellikleri çalışmazsa Orca uygulamasındaki Claude Code entegrasyonunu yeniden kur.
- Laptop daha önce hiç kurulmadıysa §3'ü uygula.

## 5. İsteğe bağlı: `/brag` tam mod (Hyperframes video)

`brag` ve `hyperframes` plugin'leri `plugins.ps1` ile gelir. Opus 5.5'te `/brag` otomatik olarak
hafif sürüme (`brag-slim`) geçer ve ek bir şey istemez. Tam mod (`/brag --full`, sesli anlatım
için `--voice`) şunları da ister — bunlar repo dışında, her bilgisayarda bir kez kurulur:

**FFmpeg (yönetici yetkisi gerekmez, kullanıcı PATH'ine):**
```powershell
$name = 'ffmpeg-n8.1-latest-win64-gpl-8.1'
$dl = Join-Path $env:TEMP 'ffdl'; New-Item -ItemType Directory -Force $dl | Out-Null
gh release download latest -R BtbN/FFmpeg-Builds -p "$name.zip" -p 'checksums.sha256' -D $dl --clobber
$expected = ((Select-String -Path "$dl\checksums.sha256" -Pattern "$name.zip").Line -split '\s+')[0]
if ((Get-FileHash "$dl\$name.zip" -Algorithm SHA256).Hash -ne $expected.ToUpper()) { throw 'checksum uyusmuyor' }
Expand-Archive "$dl\$name.zip" -DestinationPath "$env:LOCALAPPDATA\ffmpeg"
$bin = "$env:LOCALAPPDATA\ffmpeg\$name\bin"
$p = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($p -split ';') -notcontains $bin) { [Environment]::SetEnvironmentVariable('Path', "$($p.TrimEnd(';'));$bin", 'User') }
Remove-Item $dl -Recurse
# Yeni terminal aç: ffmpeg -version
```
Yönetici hesabın varsa alternatif: `choco install ffmpeg -y`.

**Kokoro TTS** (yalnız `--voice` için):
```powershell
python -m pip install --user kokoro-onnx soundfile
```

**Kontrol:**
```powershell
npx hyperframes doctor
```
Zorunlu kalemler: Node, FFmpeg, FFprobe, Chrome (ilk çalıştırmada kendisi indirir). whisper-cpp,
MusicGen ve Docker brag için gerekmez. brag'in müzik ritim script'i bağımlılıklarını `uv run` ile
kendisi kurar.

İlgili ayarlar (`settings.json` → `env`, zaten repoda): `HYPERFRAMES_NO_TELEMETRY=1` (telemetri
kapalı), `HYPERFRAMES_SKIP_SKILLS=1` (`hyperframes init` skill'leri GitHub'dan ikinci kez indirmez;
plugin'deki kullanılır).

## 6. Otomatik senkron nasıl çalışır

Her Claude Code **açılışında** (SessionStart hook, matcher `startup`) `bootstrap/sync.ps1` çalışır:

1. Son başarılı senkrondan 30 dakika geçmediyse hiçbir şey yapmaz.
2. Clean filter config'ini tazeler (§7).
3. Memory: bu makinedeki kopyayı repo kopyasına aktarır (§8).
4. `git fetch` → durum:
   - **uzakta yeni commit var, yerelde yok** → yalnız fast-forward `pull`
   - **yerelde push edilmemiş commit var, uzakta yeni yok** → `push`
   - **ikisi de var (ayrışma)** → hiçbir şey yapmaz, mesaj verir
   - Asla merge, rebase, force yapmaz; **asla kendisi commit atmaz.**
5. Memory: repo kopyasını bu makinenin klasörüne aktarır.
6. `setup.ps1` / `plugins.ps1` son **başarılı** çalışmadan beri değiştiyse, arka planda
   `run-bootstrap.ps1` ile yeniden çalıştırır (yeni plugin, yeni ECC pin'i böyle yayılır). Bir
   makine bu script'leri ilk kez görüyorsa yalnız hash'lerini kaydeder, çalıştırmaz.
7. Yalnız bir şey olduysa ya da dikkat gerekiyorsa oturuma tek satırlık mesaj yazar.

**Akış:** bu PC'de değiştir → commit at (reviewer kuralı CLAUDE.md'de) → bir sonraki açılışta
push edilir → laptopta bir sonraki açılışta pull edilir → değişen ayar/agent için Claude Code'u bir
kez daha yeniden başlat.

**Mesajlar ve ne yapmalı:**

| Mesaj (`[config-sync] ...`) | Anlamı | Ne yap |
|---|---|---|
| `pulled N new commit(s)` | diğer makineden değişiklik geldi | Claude Code'u yeniden başlat |
| `pushed N local commit(s)` | bu makinedeki commit'ler gönderildi | — |
| `pull blocked by local changes` | yerelde commit edilmemiş değişiklik, pull'un değiştireceği dosyada | `git -C ~/.claude status` → commit et ya da geri al |
| `diverged from origin` | iki makinede ayrı commit'ler var | `git -C ~/.claude pull --rebase`, sonra push |
| `no upstream branch` | dal uzak dala bağlı değil | `git -C ~/.claude push -u origin main` |
| `git fetch failed (check 'gh auth status' ...)` | kimlik doğrulama / repo erişimi | `gh auth login` |
| `bootstrap changed (...); re-running in background` | setup/plugins arka planda çalışıyor | birkaç dakika sonra Claude Code'u yeniden başlat |
| `last background ... run failed` | arka plan kurulumu hata verdi | `hooks-state/sync/bootstrap.log` ve `bootstrap.err.log`'a bak; bir sonraki açılışta yeniden denenir |
| `memory copy ... failed (robocopy N)` | memory kopyalanamadı | dosya kilidi / disk; tekrar dene |

İnternet yoksa sessiz kalır ve bir sonraki açılışta yeniden dener.

**Kapatma:** `CLAUDE_CONFIG_SYNC=off` (ör. `settings.local.json` → `env` içinde, yalnız o makine için).
**Durum dosyaları:** `hooks-state/sync/` (`last-run.txt`, `*.sha256`, `*.status`, `bootstrap*.log`, `bootstrap.lock`).

## 7. Taşınabilir `settings.json`

- Claude Code hook komutlarını **Git Bash veya PowerShell** ile çalıştırır. İkisi de `$HOME`'u açar;
  ikisi de `%USERPROFILE%`'i açmaz. Bu yüzden repodaki hook yolları `$HOME/.claude/...` biçimindedir.
  (2026-10-14'teki `%USERPROFILE%` denemesi bu yüzden `MODULE_NOT_FOUND` ile çalışmıyordu.)
- Orca ve bazı araçlar yerel `settings.json`'u mutlak yolla (`C:/Users/<ad>/...`) yeniden yazar.
  **Git clean filter** (`bootstrap/settings-clean.js`, `.gitattributes`: `settings.json
  filter=portable-settings`) dosya git'e girerken:
  - `<sürücü>:/Users/<ad>/` → `$HOME/`
  - `.orca/agent-hooks` hook'larını çıkarır (Orca her makinede kendisi ekler)
  - çalışma kopyasına dokunmaz; bu yüzden Orca'nın yeniden yazması `git status`'ta görünmez.
- Filter config'i yereldir (`.git/config`, repoda değil); `setup.ps1` ve her senkron yazar:
  `filter.portable-settings.clean = node bootstrap/settings-clean.js`, `required = true`
  (filter çökerse commit durur, makineye özel yol sızmaz).
- `settings.json`'a yeni bir hook eklerken yol olarak `$HOME/.claude/...` kullan; mutlak yol yazsan
  da filter commit'te düzeltir.

## 8. Memory senkronu

- Claude Code memory'yi `~/.claude/projects/<kodlanmış yol>/memory/` altından okur. Kodlama:
  `~/.claude` yolundaki harf ve rakam dışındaki her karakter `-` olur
  (`C:\Users\tasde\.claude` → `C--Users-tasde--claude`, `C:\Users\X\.claude` → `C--Users-X--claude`).
- Repodaki kopya kaynak makinenin klasöründedir: `projects/C--Users-tasde--claude/memory/`.
- Kullanıcı adı farklı makinelerde `sync.ps1` iki yönlü kopyalar (robocopy `/XO`, daha yeni dosya
  kazanır). Yerel → repo kopyası pull'dan **önce** yapılır; böylece yerel düzenleme git değişikliği
  olur ve çakışan bir pull üzerine yazmak yerine reddedilir.
- Laptopta değişen memory dosyaları repo kopyasında commit edilmemiş değişiklik olarak görünür;
  diğer makineye gitmeleri için **commit edilmeleri** gerekir (sync commit atmaz).
- **Silmeler yayılmaz**: bir makinede silinen memory dosyası diğerinden geri gelebilir. Silerken
  iki makinede de sil ya da commit'le birlikte sil.

## 9. ECC (cherry-pick kurulum) ve pin yükseltme

- ECC (`affaan-m/ECC`) tam plugin olarak değil, cherry-pick kuruludur: agent ve skill'ler
  `agents/` ve `skills/` altına kopyalanmış ve yerelde derinleştirilmiştir; klon yalnız hook
  script'leri için `plugins/ecc`'dedir.
- Pin: `bootstrap/setup.ps1` → `$eccSha` (şu an `9ac593b5`). Yerel hook düzeltmesi:
  `bootstrap/ecc-local.patch` (gateguard SQL tespiti; pin'e temiz uygulanır).
- **Pin yükseltme** (bu PC'de, elle):
  ```bash
  git -C ~/.claude/plugins/ecc fetch origin
  git -C ~/.claude/plugins/ecc diff --stat 9ac593b5 origin/main -- agents/ skills/
  git -C ~/.claude/plugins/ecc log --stat --diff-filter=R 9ac593b5..origin/main -- agents/ skills/   # taşıma/yeniden adlandırma
  git -C ~/.claude/plugins/ecc log --oneline 9ac593b5..origin/main -- scripts/hooks/gateguard-fact-force.js
  ```
  - upstream değişti + yerel kopya değişmedi → yerele kopyala (ör. laravel-security)
  - ikisi de değişti → `git merge-file` ile elle birleştir
  - upstream değişmedi → dokunma
  - gateguard değiştiyse: yerel yama ile upstream PR #3107 kapsamını karşılaştır, yamayı güncelle
    ya da kaldır.
  - `$eccSha`'yı güncelle, commit at → diğer makinelerde `sync.ps1` `setup.ps1`'i yeniden çalıştırır;
    `setup.ps1` klonda yama/lockfile dışı yerel değişiklik varsa durur ve mesaj verir.
- Ayrıntılı strateji: `reports/agent-skill-iyilestirme-raporu.md` §5.

## 10. Plugin ekleme / kaldırma

- **Ekleme:** plugin'i bu PC'de kur (`claude plugin marketplace add <owner/repo>`,
  `claude plugin install <ad>@<marketplace>`), sonra `bootstrap/plugins.ps1`'deki iki listeye ekle,
  commit at. Diğer makinelerde bir sonraki açılışta `plugins.ps1` arka planda yalnız eksik olanı kurar.
- **Kaldırma otomatik değildir:** listeden çıkarmak diğer makinede plugin'i kaldırmaz; orada
  `claude plugin uninstall <ad>@<marketplace>` elle çalıştırılmalı.
- Plugin cache'inde (`plugins/cache/...`) düzenleme yapma: güncellemede silinir. Davranış
  tercihlerini CLAUDE.md'ye yaz; genel düzeltmeleri upstream'e PR olarak gönder.

## 11. Kurulumu doğrulama

```powershell
claude plugin list                                   # plugins.ps1'deki 12 plugin enabled (hesaptan senkronlananlarla daha fazla olabilir)
git -C $HOME/.claude status                          # temiz olmalı
git -C $HOME/.claude config --get filter.portable-settings.clean   # node bootstrap/settings-clean.js
powershell -NoProfile -ExecutionPolicy Bypass -File $HOME/.claude/bootstrap/sync.ps1   # 30 dk içinde ikinci kez: sessiz
Get-Content $HOME/.claude/hooks-state/sync/*.status  # varsa: OK ...
npx hyperframes doctor                               # yalnız /brag tam mod için
```
Claude Code içinde: statusline görünüyor mu, oturum sonunda doc/PHP Stop hook'ları hata vermeden
çalışıyor mu.

## 12. Sorun giderme

- **Hook'lar `MODULE_NOT_FOUND` veriyor:** `settings.json`'da `%USERPROFILE%` kalmış olabilir;
  `$HOME` olmalı (§7). `git -C ~/.claude diff settings.json` ile bak.
- **`git status` hep `settings.json` değişti diyor:** filter config'i eksik →
  `powershell -ExecutionPolicy Bypass -File ~/.claude/bootstrap/setup.ps1` ya da
  `git -C ~/.claude config filter.portable-settings.clean "node bootstrap/settings-clean.js"`.
- **Commit `settings.json` filtresinde hata veriyor:** `node` PATH'te mi, `settings.json` geçerli
  JSON mu? (`node -e "require('./settings.json')"`)
- **Senkron hiç çalışmıyor gibi:** throttle (30 dk) → `hooks-state/sync/last-run.txt`'i sil ve
  Claude Code'u yeniden aç; `CLAUDE_CONFIG_SYNC` `off` mu?
- **Arka plan kurulumu tekrar tekrar başarısız:** `hooks-state/sync/bootstrap.log` /
  `bootstrap.err.log`; script'i elle çalıştırıp çıktıya bak.
- **PowerShell script'lerinde bozuk karakter:** bootstrap `.ps1` dosyaları ASCII tutulur (Windows
  PowerShell 5.1 BOM'suz UTF-8'i bozuk okur); düzenlerken Türkçe karakter ekleme.
- **Senkronu tamamen devre dışı bırakmak:** `CLAUDE_CONFIG_SYNC=off`.

## 13. Bakım: reviewer eval seti

`evals/reviewers/run.py`: reviewer agent'larını gömülü hatalı fixture'lar (6 hata + 2 yanlış alarm
tuzağı) üzerinde `claude -p --agent` ile koşturup notlar. Reviewer dosyalarını değiştirmeden önce ve
sonra çalıştır:

```powershell
cd $HOME/.claude/evals/reviewers
python -I run.py once        # değişiklikten önce
python -I run.py sonra       # değişiklikten sonra
python -I run.py sonra --grade   # koşmadan yeniden notla (kayıtlı raporlardan)
```
Sonuç: `results/<etiket>.tsv` (hit, fp, verdict, repo_clean, seconds, cost_usd). Bir tur ~0,6 $ ve
birkaç dakika sürer; her vaka 1 kez koşar. Hit düşüyorsa ya da tuzakta alarm çıkıyorsa değişiklik
gerilemedir. `ERR` = araç/altyapı hatası (reviewer sonucu değil), o vakayı yeniden koştur.

## 14. Bilinen sınırlar

- Otomatik senkron yalnız bu PC'de test edildi; laptopta (kullanıcı `X`) uçtan uca henüz çalışmadı.
- Memory silmeleri yayılmaz (§8); plugin kaldırma yayılmaz (§10).
- Repoya push yetkisi olan, sonraki açılışta tüm makinelerde kod çalıştırabilir (repo private, tek
  sahip; kabul edilen tehdit modeli). GitHub hesabında 2FA açık olsun.
- `brag` ve `hyperframes` marketplace'leri sürüm sabitlenmemiş üçüncü taraf kaynaklardır.
- ECC `npm install` lifecycle script'leri çalıştırır (pinli commit'ten; bilinçli kabul).
