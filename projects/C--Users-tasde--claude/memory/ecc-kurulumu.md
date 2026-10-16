---
name: ecc-kurulumu
description: "ECC (affaan-m/ECC) cherry-pick kurulumu — konum, kurulanlar, kaçış kapıları"
metadata: 
  node_type: memory
  type: project
  originSessionId: 8e7ca573-ab83-4f1b-aaef-20ecf190bb5d
  modified: 2026-10-16T03:52:59.385Z
---

2026-07-23: ECC reposu cherry-pick yöntemiyle kuruldu (tam plugin DEĞİL).

- **Klon konumu:** `C:\Users\tasde\.claude\plugins\ecc` (resolve-ecc-root.js bu yolu tanır;
  başka yere taşınırsa hook'lar "could not resolve ECC plugin root" verir). `npm install` yapıldı.
- **Kurulanlar:** 18 skill (react/laravel/python aileleri, llm-trading-agent-security,
  council, strategic-compact, article-writing, e2e/browser-qa, docker/deployment-patterns),
  12 agent (dil reviewer'ları + silent-failure-hunter + resolver'lar + code-explorer[sonnet]),
  `/cost-report` komutu, TAM hook seti + ecc-statusline (settings.json'da).
- **CLAUDE.md kuralları (2026-07-23 eklendi):** (1) commit öncesi değişen dile göre reviewer
  agent'ı zorunlu; (2) derin özellik analizi → code-explorer, geniş fan-out → yerleşik Explore.
  *(Sonradan değişti: güncel CLAUDE.md "Keşif Agent Seçimi" tüm keşfi code-explorer'a veriyor,
  Explore yalnız `model: sonnet` ile — CLAUDE.md geçerli.)*
- **Yedek:** `settings.json.bak-pre-ecc` — hook öncesi hali.
- **Kaçış kapıları:** `ECC_DISABLED_HOOKS=<id>` (örn. `pre:bash:gateguard-fact-force`),
  `ECC_HOOK_PROFILE=minimal`, `ECC_GATEGUARD=off`. Hook'ları tamamen kaldırmak = settings.json'dan
  `hooks` + `statusLine` anahtarlarını silmek.
- **GateGuard davranışı:** oturumun ilk Bash komutundan ve dosya başına ilk Edit/Write'tan önce
  kanıt/tespit sunulmasını ister — bloklarsa tespitleri yazıp aynı komutu tekrarla.
- **GateGuard DOĞRULAMA YAPMAZ (2026-08-07 ölçüldü):** 2. denemede yalnızca state dosyasındaki
  işarete bakar, sunulan fact'lerin içeriğini hiç denetlemez. Hız kasisi, doğrulayıcı değil.
- **`quality-gate.js` fiilen no-op:** sonucu sadece `ECC_QUALITY_GATE_STRICT=true` ise loglar
  (set değil) ve `.php` hiç kapsamaz. Tek gerçek doğrulayıcı `stop-format-typecheck.js` (JS/TS-only).
- **2026-08-07 eklenenler:** 5 agent (code-architect, performance-optimizer, tdd-guide,
  pr-test-analyzer, doc-updater) + `/update-codemaps`, `/update-docs` komutları;
  PHP boşluğunu kapatmak için ecc dışı kendi hook'umuz [[php-stop-check-hook]].
- **ECC agent'ları skill'lere atıf yapar — agent'ı kurarken atıf yaptığı skill'i de kur.**
  2026-08-08'de 7 kırık atıf bulundu (tdd-workflow, backend/frontend-patterns, dotnet-patterns,
  csharp-testing, postgres-patterns, coding-standards); hepsi ecc'de vardı, kuruldu. Agent
  "detay için şu skill'e bak" deyip skill yoksa agent detaysız kalıyor — sessiz bir başarısızlık.
- **ECC agent'ları iki kalite katmanında gelir:** reviewer'lar/resolver'lar dolu (600-2000 kelime,
  somut pattern + tanı komutu), süreç agent'ları iskelet (285-600 kelime, jenerik başlık listesi).
  2026-08-08'de pr-test-analyzer, code-architect, tdd-guide derinleştirildi; refactor-cleaner ve
  doc-updater'ın JS-only komutları stack-algılamalı yapıldı; 17'sine de doğrulama disiplini eklendi.
- Bilinçli KURULMAYANLAR: rules kopyası, hookify, instinct/continuous-learning, MCP kataloğu,
  seo/design/brand skill'leri (mevcut plugin/skill'lerle çakışıyor).
- **2026-08-20 güncelleme (v2.0.0 → v2.2.0, 124 commit):** klon `git merge --ff-only origin/main`
  + `npm install` (js-yaml 4.3.1). Kurulu 18 skill'in `SKILL.md`'si upstream'in yeni haliyle
  değiştirildi (hepsi temiz kopyaydı, yerel düzenleme yoktu; yedek
  `~/.claude/backups/skills-pre-ecc-update-20260820/`). **17 agent kasıtlı güncellenmedi:**
  upstream'deki tek fark `tools: ["Read",…]` → `tools: Read, …` frontmatter formatı; ikisi de
  çalışıyor, 2026-08-08 derinleştirmelerini korumak için üzerine yazılmadı — sonraki
  güncellemede de bu farkı gerçek değişiklik sanma.
  Yeni kurulanlar: `rag-pipeline-reviewer` agent + `contract-first`, `api-design`,
  `ai-regression-testing` skilleri (son ikisi contract-first'ün atıf yaptığı skiller).
  Kurulmayan yeni ECC skilleri: dev-team, council-multi-model, living-docs-governance,
  unified-memory, terminal-opener, nasiko-control-plane, ito-baskets/inference/training.
- **2026-10-16 iyileştirme turu** (rapor: `~/.claude/reports/agent-skill-iyilestirme-raporu.md`, eval: `~/.claude/evals/reviewers/run.py`):
  7 kullanılmayan agent (code-architect, tdd-guide, refactor-cleaner, performance-optimizer,
  build-error-resolver, react-build-resolver, rag-pipeline-reviewer) `git mv` ile
  `backups/agents-archive-20261016/`'ya taşındı — 404 transcript'te 0 çağrı, sebep CLAUDE.md'de
  tetikleyici olmaması; geri almak tek `git mv`, ama kural yazmadan geri getirmek yine 0 çağrı demek.
  8 reviewer'a ortak "Read-only Contract & Execution Limits" + "Findings Format & Verdict" bloğu
  eklendi; skill atıfları `Read <tam yol>`'a çevrildi (reviewer'larda Skill aracı yok, atıflar ölüydü).
  laravel-security ECC origin/main'den güncellendi (+authorize-before-temporaryUrl düzeltmesi;
  yedek `backups/skills-pre-ecc-update-20261016/`). ECC klonu `fetch` edildi ama pin hâlâ
  `9ac593b5`; `ecc-local.patch` pin'e temiz uygulanıyor ve yerelde uygulanmış — pin yükseltilirse
  upstream PR #3107 kapsamıyla karşılaştırmadan düşürme. doc-updater `model: sonnet` bilinçli
  (09-23 haiku denemesi 77-132 tur harcadı).
