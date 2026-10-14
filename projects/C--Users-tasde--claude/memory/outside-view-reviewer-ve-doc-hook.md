---
name: outside-view-reviewer-ve-doc-hook
description: "Plan sonrasi disaridan (GitHub/forum/SO) elestiren outside-view-reviewer agent'i + is bitince anlamli kod degisikliginde doc-updater'i zorlayan Stop hook'u kuruldu"
metadata: 
  node_type: memory
  type: project
  originSessionId: 4142db0e-ef96-444b-bacf-cec4a3a4c73e
  modified: 2026-09-21T13:51:20.478Z
---

2026-09-21'de iki kalici otomasyon eklendi:

**`~/.claude/agents/outside-view-reviewer.md`** — planı dışarıdan (GitHub issue/repo,
forum, StackOverflow canlı arama) sınayan agent. `council` (salt içsel dört-ses tartışma,
dış araştırma yok) ve `search-first` (kod yazmadan önce kütüphane arar, bitmiş planı
sınamaz) ile karışmasın diye ayrı tutuldu — bu üçü birbirini tamamlıyor, biri diğerinin
yerine geçmiyor. Tools: Read/Grep/Glob/Bash(`gh` icin)/WebSearch/WebFetch, model: sonnet.

**Bağlayıcı CLAUDE.md kuralı** ("Plan Sonrası Dış Görüş Denetimi", Commit Öncesi Otomatik
Reviewer kuralının hemen altında): plan gerçek bir karar noktası (kütüphane/servis/mimari/
build-vs-buy) içeriyorsa bu agent dil-reviewer'larıyla birlikte otomatik çalışır. Atlama
koşulu commit-reviewer kuralıyla aynı mantık: tek seçenekli/net işlerde çalıştırma.

**`~/.claude/hooks/doc-update-reminder.js`** (global Stop hook, `settings.json` →
`hooks.Stop`) — oturumda anlamlı kaynak kod değişikliği varsa (doküman/config/lock
dosyaları hariç tutuluyor: `.md .json .yaml .toml .lock` + `package-lock.json` vb.)
Claude durmadan önce `doc-updater` agent'ını (/update-docs, /update-codemaps) çalıştırmaya
zorlanır. Dedupe: değişen dosya listesi + diff içeriğinin sha256'sı oturum bazlı state
dosyasında (`~/.claude/hooks-state/doc-update-reminder/<session_id>.json`) tutulur —
aynı diff için bir daha sormaz, yeni kaynak değişikliği gelince tekrar bloklar. Ayrıca
`data.stop_hook_active` kontrolü var (aynı stop-zincirinde döngüye girmesin).
`DOC_UPDATE_STOP_CHECK=off` ile kapanır. `~/.claude/hooks/php-stop-check.js` ile aynı
üslupta yazıldı (Turkce yorum, fail-open, stdin JSON okuma).

**Neden agent'a devredildi, inline yapılmadı:** doc-updater zaten var ve 2026-08-08'de
derinleştirildi (bkz. [[ecc-kurulumu]]); codemap/doc regen çok dosyalı bir iş, ana session
context'ini şişirmeden delege etmek doğru. Inline sadece tek satırlık trivial doc
düzeltmelerinde mantıklı olurdu, "iş bitince genel doc update" kapsamı buna girmiyor.

**Test notu:** Windows'ta Node `spawnSync` cwd'si POSIX-stil yol (`/c/Users/...`) ile
ENOENT verir — hook `data.cwd`'yi Claude Code'un verdiği gibi (Windows-stil `C:\...`)
bekler, git-bash `pwd` çıktısıyla test ederken bu tuzağa düşülmesin.

**council ile zincirleme reddedildi:** outside-view-reviewer'ın "worth reconsidering"
bulgularını council'e (kompakt context olarak) taşıma önerisi kullanıcıya sunuldu,
bilinçli olarak istenmedi — "tek outside iyi". outside-view-reviewer tek başına yeterli
sayılıyor, gelecekte bu zincirlemeyi tekrar önerme.

İlgili: [[ecc-kurulumu]], [[kesif-ajani-karsilastirmasi]]
