---
name: claude-config-dotfiles
description: "~/.claude git dotfiles reposu (tasdeleno/claude-config) — makineler arası senkron, restore, taşınabilirlik tuzakları"
metadata:
  node_type: memory
  type: project
  originSessionId: 5751a595-9189-46ec-ae01-730475ce5f18
  modified: 2026-10-16T09:45:28.045Z
---

2026-10-14: `~/.claude` taşınabilir git dotfiles reposuna alındı → **tasdeleno/claude-config** (private, `main`). Amaç: bu PC (`C:\Users\tasde`) ile laptop (`C:\Users\X`) arası setup senkronu.

**Takip edilen:** CLAUDE.md, AGENTS.md, agents/, commands/, hooks/ (2 custom js), skills/ (junction'lar hariç), settings.json, memory/, bootstrap/. **Allowlist .gitignore** (önce `/*` yok say, sonra aç).

**Dışlanan:** `.credentials.json`, cache/log/session/daemon/state, `settings.local.json` (makine-yerel permission'lar), cloud-synced (`skills/synced`, `plugins/synced` — login'de geri akar), tüm `plugins/` ağacı, `hooks/.logs/`, `node_modules`.

**Taşınabilirlik (2026-10-16 düzeltildi):** `%USERPROFILE%` YANLIŞTI — CC hook'ları cmd.exe ile değil Git Bash/PowerShell ile koşuyor; 2026-10-14 transcript'inde `node "%USERPROFILE%/..."` → MODULE_NOT_FOUND. Doğru biçim **`$HOME`** (bash + PowerShell ikisi de açar; ikisinde de test edildi). Ayrıca Orca kendi hook'larını her makinede mutlak yolla yeniden yazıyor. Çözüm: git clean filter `bootstrap/settings-clean.js` (`.gitattributes`: `settings.json filter=portable-settings`; config'i setup.ps1/sync.ps1 kurar) commit'e giderken `C:/Users/<ad>/` → `$HOME/` yapar ve Orca hook'larını çıkarır; çalışma kopyasına dokunmaz → Orca rewrite'ları git status'u kirletmez. Yolu tasde/X'e SABİTLEME.

**Pluginler kopyalanmaz:** `bootstrap/plugins.ps1` 9 marketplace + 10 plugin'i CLI ile reinstall eder (güncel sürüm gelir).

**ECC özel:** kendi `.git`'i olduğu için repoya gömülmedi (git gitlink/submodule yapıyor, laptopta boş gelir; submodule yerel değişikliği taşımaz). `bootstrap/setup.ps1` pinli commit `9ac593b5`'ten clone + `bootstrap/ecc-local.patch` (gateguard-fact-force.js SQL tespiti yerel değişikliği) apply + `npm install`. ECC'nin kendi ff-only güncelleme akışı korunur. Bkz [[ecc-kurulumu]].

**Auto-memory portability:** CC memory'yi `projects/<cwd-encoded>/memory`'den okur; encoding `C:\Users\X\.claude` → `C--Users-X--claude` (`: \ / .` → `-`). Repo'daki kopya `C--Users-tasde--claude` altında; `setup.ps1` laptopun kendi encoding'ine kopyalar.

**Herhangi bir PC'de restore:** `~/.claude`'u `.bak`'e taşı → `git clone https://github.com/tasdeleno/claude-config .claude` → `powershell -ExecutionPolicy Bypass -File bootstrap/setup.ps1` → `claude` (login) → `... bootstrap/plugins.ps1`. Önkoşul: Git for Windows, Node 22+, Python, `gh auth login`. Orca hook'larını Orca app kendisi ekler.

**Otomatik senkron (2026-10-16):** SessionStart hook (matcher `startup`) → `bootstrap/sync.ps1`: 30 dk throttle; yalnız ff pull; yalnız mevcut commit'leri push (asla kendisi commit atmaz, merge/rebase/force yok); farklı kullanıcı adında memory iki yönlü robocopy /XO (yerel→repo pull'dan önce); setup.ps1/plugins.ps1 hash'i değiştiyse `run-bootstrap.ps1` ile arka planda yeniden koşar — hash yalnız BAŞARIDAN sonra yazılır, ilk görüşte sadece benimsenir (çalıştırmaz), FAILED `.status` sonraki oturumda mesaj olur, lock dosyası çift koşuyu engeller. Neden `-File` ve PS-içi yönlendirme yok: PS 5.1'de `*>` native stderr'i (npm warn) 'Stop' script'inde ölümcül hataya çevirir (reviewer deneyle doğruladı). Filter `required=true`: filtre çökerse commit durur, ham yol sızmaz. Memory klasör kodlaması `[^A-Za-z0-9]`→`-` (gerçek klasör `Masa-st` ile doğrulandı). setup.ps1 idempotent: ECC pin değişince yama/lockfile dışı yerel değişiklik varsa durur, yoksa `checkout --force` + yama + HEAD doğrulama; plugins.ps1 yalnız eksikleri kurar. Kapatma: `CLAUDE_CONFIG_SYNC=off`. Script ASCII-only (PS 5.1 BOM'suz UTF-8'i bozuk okur).
