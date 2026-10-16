---
name: skill-kaynaklari-plugin-tabanli
description: "Skiller artık marketplace/plugin ile yönetiliyor; güncelleme claude plugin update ile yapılır, elle kopyalama değil"
metadata: 
  node_type: memory
  type: project
  originSessionId: cc40078c-b1d5-4098-aa0a-6e5539bacaf9
  modified: 2026-10-16T10:14:25.532Z
---

**Makineler arası sürüm (2026-10-16, kullanıcı kararı):** `bootstrap/plugins.lock.json` kayıtlı
sürümler; `sync.ps1` yalnız UYARIR, asla güncellemez. Güncelleme ancak kullanıcı isterse ve
CLAUDE.md "Plugin Güncelleme" kuralıyla (yalnız `claude plugin update`, yerel agent/skill/CLAUDE.md/
settings'e dokunmadan), sonra `plugins.ps1 -Record` + commit. Kullanıcının endişesi: güncellemenin
kendi yöntem ve kurallarının üzerine yazması.

2026-07-25'te `~/.claude/skills/` altındaki elle kopyalanmış skiller plugin'e taşındı. Güncelleme artık:
`claude plugin marketplace update` → `claude plugin update <plugin>@<marketplace>` (restart gerekir).
Plugin adı kısa haliyle çalışmaz, `plugin@marketplace` tam kimliği şart.

Doğrulanmış kaynaklar (hepsi orijinal, fork değil — GitHub API `fork` bayrağı + yıldızla teyit edildi):
- ponytail (+audit/debt/gain/help/review) → DietrichGebert/ponytail (~89k★)
- impeccable → pbakaus/impeccable (~50k★)
- ui-ux-pro-max → nextlevelbuilder/ui-ux-pro-max-skill (~110k★); bu repo `design`, `brand`,
  `slides`, `ui-styling`, `banner-design`, `design-system` skillerini de yükler
- autoresearch → uditgoenka/autoresearch (~5k★)
- graphify → Graphify-Labs/graphify (~95k★); pip paketi adı `graphifyy` (çift y)

- brag (+brag-slim) → latent-spaces/brag (2026-10-16 plugin olarak kuruldu, `bootstrap/plugins.ps1`'e eklendi).
  Yalnız skill + ses varlıkları, hook/MCP yok. Opus 5.5'te otomatik brag-slim'e geçer; tam mod
  `/brag --full` (ses için `--voice`). **Tam kurulum yapıldı (2026-10-16):** hyperframes@hyperframes
  plugin (heygen-com/hyperframes, 0.8.164; Claude tarafında hook/MCP yok; kurulumdaki "84 LFS
  pointer" uyarısı yalnız repo'nun test baseline'ları — skill'lerde yok, `lfs pull` gereksiz),
  FFmpeg 8.1 kullanıcı PATH'inde (`%LOCALAPPDATA%\ffmpeg`, admin yok → choco kullanılamadı),
  Kokoro (`pip --user kokoro-onnx soundfile`). brag cue script'i `uv run` ile kendi bağımlılığını
  kuruyor (librosa 0.11 Py3.14'te çalıştı). `npx hyperframes doctor` zorunlu kalemler ✓, smoke
  render 10 sn 1080p ✓. `hyperframes init` skill'leri GitHub'dan da kurar → plugin varken
  `HYPERFRAMES_SKIP_SKILLS=1`. İkisi de kullanıcı onayıyla `settings.json` env'e kondu:
  `HYPERFRAMES_SKIP_SKILLS=1` (çift skill kopyası olmasın) ve `HYPERFRAMES_NO_TELEMETRY=1`.

Değerlendirilip ALINMAYAN: tester-army/e2e (2026-10-16). Kendi `e2e` çatısına bağlı (agent.act +
model sağlayıcı, v0.21); genel Playwright rehberi değil. Kullanıcının tek e2e kurulumu FBA'da düz
`@playwright/test` → ECC `e2e-testing` skill'i kaldı. Mobil (Expo) uçtan uca test istenirse yeniden bak.

Elenen klonlar: rhanka/graphify, mikrammullah-ponytail, gessniio/impeccable_SKILL_CLAUDE,
WAAMEngineer/ui-ux-pro-max-skill, zhongpei/autoresearch-skills, Muminur/autoresearch-*.

`skills/graphify/` plugin dışında kaldı: upstream'in Windows/PowerShell uyarlaması
(`name: graphify-windows`), upstream'de karşılığı yok — üzerine yazmak PowerShell uyumluluğunu
bozar. Motoru ayrı güncellenir: `pip install --upgrade graphifyy` (0.4.23 → 0.9.25 yapıldı;
SKILL.md'nin çağırdığı 11 modülün tüm API'leri import testiyle doğrulandı, imzalar geriye uyumlu).

`ckm:` önekli 6 skill silindi — güncel karşılıkları ui-ux-pro-max plugin'inde.

Yedekler: `~/.claude/backups/skills-pre-plugin-migration-20260725/` (9 skill) ve
`~/.claude/backups/skills-ckm-pre-remove-20260725/` (6 ckm: skill)

İlgili: [[ecc-kurulumu]]
