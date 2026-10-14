---
name: claude-config-dotfiles
description: "~/.claude git dotfiles reposu (tasdeleno/claude-config) — makineler arası senkron, restore, taşınabilirlik tuzakları"
metadata:
  node_type: memory
  type: project
  originSessionId: 5751a595-9189-46ec-ae01-730475ce5f18
  modified: 2026-10-14T13:39:22.600Z
---

2026-10-14: `~/.claude` taşınabilir git dotfiles reposuna alındı → **tasdeleno/claude-config** (private, `main`). Amaç: bu PC (`C:\Users\tasde`) ile laptop (`C:\Users\X`) arası setup senkronu.

**Takip edilen:** CLAUDE.md, AGENTS.md, agents/, commands/, hooks/ (2 custom js), skills/ (junction'lar hariç), settings.json, memory/, bootstrap/. **Allowlist .gitignore** (önce `/*` yok say, sonra aç).

**Dışlanan:** `.credentials.json`, cache/log/session/daemon/state, `settings.local.json` (makine-yerel permission'lar), cloud-synced (`skills/synced`, `plugins/synced` — login'de geri akar), tüm `plugins/` ağacı, `hooks/.logs/`, `node_modules`.

**Taşınabilirlik:** settings.json'daki tüm mutlak yollar `C:/Users/tasde` → `%USERPROFILE%` (16 yer). cmd.exe her iki slash stiliyle de genişletiyor (native doğrulandı); CC Windows'ta hook'ları cmd.exe ile koşuyor (çalışan `.orca/...claude-hook.cmd` bunu kanıtlıyor). Yolu tasde/X'e SABİTLEME — repo iki makinede de çalışmalı.

**Pluginler kopyalanmaz:** `bootstrap/plugins.ps1` 9 marketplace + 10 plugin'i CLI ile reinstall eder (güncel sürüm gelir).

**ECC özel:** kendi `.git`'i olduğu için repoya gömülmedi (git gitlink/submodule yapıyor, laptopta boş gelir; submodule yerel değişikliği taşımaz). `bootstrap/setup.ps1` pinli commit `9ac593b5`'ten clone + `bootstrap/ecc-local.patch` (gateguard-fact-force.js SQL tespiti yerel değişikliği) apply + `npm install`. ECC'nin kendi ff-only güncelleme akışı korunur. Bkz [[ecc-kurulumu]].

**Auto-memory portability:** CC memory'yi `projects/<cwd-encoded>/memory`'den okur; encoding `C:\Users\X\.claude` → `C--Users-X--claude` (`: \ / .` → `-`). Repo'daki kopya `C--Users-tasde--claude` altında; `setup.ps1` laptopun kendi encoding'ine kopyalar.

**Laptop restore:** `~/.claude`'u `.bak`'e taşı → `git clone https://github.com/tasdeleno/claude-config .claude` → `pwsh bootstrap/setup.ps1` → `claude` (login, synced geri akar) → `pwsh bootstrap/plugins.ps1`. Orca kullanılıyorsa Orca app kurulu olmalı (`~/.orca/agent-hooks/claude-hook.cmd` repo dışı).

**Sonraki senkron:** iki makinede `git add -A && commit && push` / `git pull`. Memory değişiklikleri de repoda → commit edilmeli.
