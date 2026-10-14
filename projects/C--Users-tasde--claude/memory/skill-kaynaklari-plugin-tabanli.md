---
name: skill-kaynaklari-plugin-tabanli
description: "Skiller artık marketplace/plugin ile yönetiliyor; güncelleme claude plugin update ile yapılır, elle kopyalama değil"
metadata: 
  node_type: memory
  type: project
  originSessionId: cc40078c-b1d5-4098-aa0a-6e5539bacaf9
  modified: 2026-07-24T22:10:20.693Z
---

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
