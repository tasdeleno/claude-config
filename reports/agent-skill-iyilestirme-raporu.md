# Agent + Skill Filosu — Geliştirme ve İyileştirme Raporu

**Tarih:** 2026-10-16 · **Kapsam:** `~/.claude/agents/` altındaki 19 agent + en çok kullanılan 10 skill · **Yöntem:** `/autoresearch:improve` (derin, 24 iterasyon, saturasyonla durdu) + `/autoresearch:scenario` (3 seed, 135 senaryo, 12/12 boyut) + GitHub/doküman araştırması + `outside-view-reviewer` ile upstream stratejisi denetimi. 4 paralel ajan; ölçümler 404 transcript ve 329 subagent koşusundan.

> Bu rapor **öneridir**; hiçbir agent/skill dosyası değiştirilmedi. Ham veriler: `autoresearch/improve-261016-0403/` ve `autoresearch/scenario-261016-0403/`. PRD'ler aynı dizinde `prd-*.md`.

**Sayım düzeltmesi:** İlk planda verilen çağrı sayıları (149/138/119…) transcript'te her çağrının iki satırda geçmesinden dolayı **iki kat** sayılmıştı. Bu raporda tool_use kimliğiyle tekilleştirilmiş sayılar kullanılıyor.

---

## 1. Yönetici özeti

**Genel hüküm:** Reviewer'ların *muhakemesi* iyi (dosya:satır, somut arıza senaryosu, yaygın `[UNVERIFIED]`), sorunların neredeyse tamamı **agent tanımlarında ve zincir kuralında**: davranış sınırı yok, stack uyumsuz, çıktı formatı tutulmuyor, aynı bulgu üç raporda çıkıyor. Kullanılmayan 8 agent'ın tek ortak sebebi CLAUDE.md'de tetikleyici olmaması — "Use PROACTIVELY" ifadesi 404 transcript'te **sıfır** çağrı üretti.

### İlk 10 öneri (etki × efor)

| # | Öneri | Etki | Efor | Kanıt |
|---|---|---|---|---|
| 1 | Reviewer/explorer/outside-view'e **salt-okuma + çalıştırma sınırı** ekle | Yüksek (güvenlik) | S | php-reviewer repoya test yazdı; security-reviewer `taskkill /IM httpd.exe`; outside-view müşteri prod'una curl; code-explorer `artisan tinker` |
| 2 | `PONYTAIL_SUBAGENT_MATCHER` ile ponytail'i subagent'lardan çıkar | Orta | XS (tek satır) | 329/329 koşuya ~1.3k token; bir reviewer injection sanıp reddetti |
| 3 | security-reviewer'a Laravel dalı + Anthropic hard-exclusions | Yüksek | M | 60 koşuda 0 `composer audit`; rate-limit HIGH sayılıyor |
| 4 | database-reviewer motor algılama (MySQL/SQLite) | Orta | S | Ana oturum 9/14 prompt'ta "hedef MySQL" düzeltmesi yazdı |
| 5 | Zincir kuralları: lane tablosu, `Verdict:` satırı, doğrula-sonra-uygula, INCOMPLETE, re-review | Yüksek | M | %39 tekrar; 47 HIGH'a 7 re-review; 6 limit mesajı "rapor" sanıldı |
| 6 | Araç politikası: Stop hook sonucunu kabul et, ESLint `--ext`'i düzelt | Orta | S | 41/69 "çalıştırmadım"; `--ext` ESLint 9'da geçersiz |
| 7 | Kırık skill/komut atıflarını `Read <tam yol>`'a çevir | Orta | S | Reviewer'larda Skill aracı yok → 255 koşuda 0 SKILL.md okuması |
| 8 | red-audit/checklist description'larını Türkçe karakterle yaz; eski synced proje-checklist'i kapat | Orta | S | "açıkları denetle" → yanlış skill tetiklendi |
| 9 | Doc Stop hook: quotePath + imza + worktree düzeltmesi; doc-updater'ı onar | Orta | S | 83 tetikleme → 4 koşu (%5) |
| 10 | Reviewer **eval seti** (5 fixture + 2 FP tuzağı) — mimari değişikliklerden önce | Yüksek (ölçüm) | M | Bugün değişikliklerin etkisini ölçen hiçbir şey yok |

Tam kademeli liste (Must / Nice / Moonshot): `autoresearch/improve-261016-0403/improvement-plan.md`.

---

## 2. Agent kartları (19)

Sütunlar: **K** = gerçek koşu sayısı · **Karar** · en önemli sorunlar (kanıtlı) · ilk öneri · **G** = güven. Diff taslakları `reviewers-agent-cards.md` ve `process-agent-cards.md`'de.

### 2a. Reviewer zinciri (commit öncesi)

| Agent | K | Karar | Gözlenen sorunlar | GitHub'daki en iyi muadil → alınacak teknik | İlk öneri | G |
|---|---|---|---|---|---|---|
| **typescript-reviewer** | 75 | TUT + düzelt | `eslint --ext` geçersiz (`:29,105`); PR/merge-readiness adımı pre-commit'te anlamsız; `/react-review` kırık atıf; raporu dosyaya yazıp "yazıldı" döndü; `File:` formatlı rapor 0/75 | [AC pr-review-toolkit code-reviewer](https://github.com/anthropics/claude-code/blob/main/plugins/pr-review-toolkit/agents/code-reviewer.md) → güven ≥80, linter'ın yakalayacağını raporlama | Lint → `npm run lint --if-present`; yalnız değişen satır bloklar | Yüksek |
| **php-reviewer** | 69 | TUT + düzelt | Onay PHPStan'a bağlı ama 41/69 "çalıştırmadım"; aynı anda Stop hook'un koştuğu araçları 12×phpstan/7×pint tekrar; `tests/Feature/ZZZScratch…` yazıp sildi; Livewire `#[Rule]` eski; `ponytail:` yorumunu risk kabulü sayıyor | ECC php-reviewer (blob SHA klonla aynı, upstream değişmemiş); AC'den güven eşiği | Verdict'te `tools: ran | relied on Stop hook`; read-only blok; Livewire 3/4 `#[Validate]/#[Locked]` | Yüksek |
| **security-reviewer** | 60 | TUT + yeniden yönlendir | npm/Express odaklı, 0 `composer audit`; rate-limit HIGH (`:68`); `security-review` atfı kırık + yerleşik `/security-review` ile isim çakışması; `.htaccess` review'unda Apache açıp `taskkill //F //IM httpd.exe` | [anthropics/claude-code-security-review](https://github.com/anthropics/claude-code-security-review/blob/main/.claude/commands/security-review.md) → HARD EXCLUSIONS, 1-10 güven <8 düşür, FP-filtre alt görevi | Stack algılama + Laravel dalı + exclusions + execution limits | Yüksek |
| **silent-failure-hunter** | 28 | TUT + derinleştir | En değerli bulguları üreten reviewer; ama tanım en ince (68 satır), severity tanımı yok; bir önerisi düzeltilmiş P2 hatasını geri getirecekti; `*.log` scout-block'a takılıyor | [AC silent-failure-hunter (130 satır, orijinal)](https://github.com/anthropics/claude-code/blob/main/plugins/pr-review-toolkit/agents/silent-failure-hunter.md) → "Hidden Errors", prod'da mock fallback yasağı, severity tanımları | "Belgelenmiş karara/teste karşı mı?" kontrolü + Laravel `rescue()/report()/Cache::add` kalıpları | Orta-yüksek |
| **database-reviewer** | 14 | TUT + yeniden yönlendir | PostgreSQL/Supabase (RLS, `auth.uid()`, psql); projeler MySQL 8 + SQLite; `database-migrations` kırık, `mysql-patterns` atıfsız; 0 `EXPLAIN` | Muadiller incelenmedi [varlık]; asıl açık iç uyumsuzluk | Step 0 motor algılama; MySQL strict mode / utf8mb4 Türkçe collation; `migrate --pretend` | Yüksek |
| **react-reviewer** | 8 | TUT + RN bölümü | Kullanımın %100'ü React Native/Expo, kurallar Next.js/RSC; `rules/react/*`, `/react-*` yok; ana oturum bir kez "TS reviewer'ı da sen ol" diye rolleri birleştirdi | ECC react-reviewer; sahiplik tablosu (`:19-34`) zincirdeki tek iyi lane modeli | RN/Expo bölümü (iOS `announceForAccessibility`, 44pt/48dp, `expo-secure-store`); web kuralları koşullu | Orta |
| **python-reviewer** | 1 | TUT, dokunma | Örneklem yok; Pythonic stil maddeleri HIGH | — | Stil maddelerini MEDIUM'a indir; Windows `python` notu | Düşük |
| **csharp-reviewer** | 0 | TUT (CLAUDE.md'de `.cs` kuralı var) | Kullanım yok, stack'te C# yok | — | Yalnız ortak blok (read-only + Verdict) | Düşük |

### 2b. Süreç agent'ları

| Agent | K | Karar | Gözlenen sorunlar | İlk öneri | G |
|---|---|---|---|---|---|
| **outside-view-reviewer** (tamamen yerel) | 23 | TUT + güvenlik | En iyi maliyet/fayda (medyan 0.46M token, ~20 kaynak/rapor). Ama web okuyan tek agent ve Prompt Defense yok; Bash kısıtsız → müşteri prod'una curl, `php -r`; snippet'i kaynak sanma; CVE'yi agregatörden alma | "Untrusted content & tool limits" bloğu; her "worth reconsidering" için ≥1 açılmış sayfa; CVE için NVD/GHSA; Verdict başa | Yüksek |
| **code-explorer** | 17 | TUT + sınır | "Salt okuma" iken `artisan tinker` ve node WebSocket simülasyonu koştu; Dependencies bölümü 15 raporun 7'sinde; "kısa" istenen raporlar 9-21K karakter; tur bütçesi yok | Bash'i **silmeden** salt-okuma komut listesi (memory'deki ölçüm korunuyor); Dependencies + Doğrulama zorunlu; ≤6K/≤12K karakter | Yüksek |
| **doc-updater** | 4 | TUT, hook ile yeniden tasarla | 08-08 derinleştirmesi dosyada yok (Verification Discipline 0, JS-only komutlar); en pahalı süreç agent'ı (medyan 7.93M cache-read, 107 tur); Stop hook 83 tetikleme → 4 koşu | Hook düzeltmesi (bkz. §4) + "Varsayılan mod" + stack komutları + bütçe | Orta-yüksek |
| **pr-test-analyzer** | 0 | **CLAUDE.md'ye tetikleyici EKLE** | Hiçbir reviewer'ın sormadığı "yanlış olsa hangi test kırılırdı?" sorusunu soruyor; `origin/HEAD` varsayımı yerel-only repolarda boş diff | Faz/dalga sonu, merge/PR öncesi tek sefer; `git merge-base` fallback. İlk 3 koşuda "critical gap" çıkmazsa arşivle | Orta |
| **code-architect** | 0 | ARŞİVLE | Plan modu + code-explorer + outside-view + Karar Eleştirisi ile örtüşüyor; kullanılmayanların en kalitelisi | Precedent fikrini code-explorer'a taşı | Orta |
| **tdd-guide** | 0 | ARŞİVLE (tdd-workflow skill kalır) | 583 test koşusu inline; Write yetkili alt agent implementasyon sahipliğini böler | — | Orta-yüksek |
| **refactor-cleaner** | 0 | ARŞİVLE | Karpathy #3 ve commit kuralıyla çelişiyor ("Commit after each batch") | Dynamic-reference listesini (`:60-76`) php/ts reviewer'a taşı | Orta-yüksek |
| **performance-optimizer** | 0 | ARŞİVLE | 464 satır jenerik; perf işi `pagespeed-plan`/`web-perf` skill'leriyle yapılıyor | — | Orta |
| **build-error-resolver** | 0 | ARŞİVLE | TS-only, kırık atıflar (`architect`, `planner`), `rm -rf node_modules package-lock.json`; 14 build hatası inline çözüldü | — | Yüksek |
| **react-build-resolver** | 0 | ARŞİVLE | Kapsamında Metro/Expo yok; tek React projesi Expo | React web projesi açılırsa geri al | Yüksek |
| **rag-pipeline-reviewer** | 0 | ARŞİVLE | RAG projesi yok; kırık handoff'lar (`mle-reviewer`, `docs-lookup`) | Vektör deposu eklenirse geri al | Yüksek |

Arşivleme tek komut ve tek `git mv` ile geri alınabilir (`agents/` dışına, `backups/agents-archive-20261016/`). **Ne zaman yanlış olur:** CLAUDE.md'ye bir tetikleme kuralı yazmaya değecek kadar o işi tekrar tekrar yapıyorsan — o gün agent'ı geri getir *ve* kuralı yaz; kuralsız geri getirmek yine sıfır çağrı demek.

---

## 3. Skill kartları (10)

| Skill | Sahiplik | K* | Sorunlar | İlk öneri | G |
|---|---|---|---|---|---|
| **impeccable** | Plugin (pbakaus/impeccable) | 11 | Kurulu 4.3.1, upstream cli-v4.6.0; Orca/headless'te live mod kırılgan | `claude plugin update`; proje kuralları CLAUDE.md'ye, cache'e değil | Yüksek |
| **ui-ux-pro-max** | Plugin | 3 | 2.13.0 → 2.15.0; impeccable ile rol çakışması | CLAUDE.md: "impeccable = üretim/craft, ui-ux-pro-max = veri/palet sorgusu" | Orta |
| **autoresearch** | Plugin | ~5 | Kurulu = latest; description kısa (76 karakter); çıktı dizini dakika granülü; scout-block hook'u reviewer'ların `node_modules`/`*.log` erişimini engelliyor | Güncelleme yok; scout-block için `.ckignore` istisnası | Yüksek |
| **orchestration** | Yerel (junction → `.agents/skills`, Orca) | 3 | Junction dotfiles'a girmez → laptopta yok | `setup.ps1`'e junction kurulumu | Orta-yüksek |
| **red-audit** | Yerel | 2 | **"açıkları denetle" → laravel-security tetiklendi**; description ASCII Türkçe; kullanıcı "terim bilmediğim için tetiklenmez" dedi | Türkçe karakterli günlük tetikleyiciler; "Laravel'de de önce red-audit" notu; alt agent'lara offensive-* tam yolları | Yüksek |
| **mobil-checklist** | Yerel | 1 | ASCII Türkçe; yalnız açık çağrıyla kullanıldı | Türkçe description, en güçlü tetikleyici başa | Orta |
| **proje-checklist** | Yerel + claude.ai synced kopya | 1 | **İki sürüm birden yükleniyor**: yerel 11 başlık + synced eski 6 başlık (çelişen description) | claude.ai Skills panelinde eskisini kapat | Yüksek |
| **laravel-security** | Yerel (ECC temiz kopya) | 1 | Upstream'de +22 satır güvenlik düzeltmesi (s3 disk + authorize) var, yerelde yok; 948 satır (kılavuz <500) | ECC'den güncelle (yerel edit 0 → güvenle ezilir); sonra `references/`'a böl | Yüksek |
| **i18n-sync** | Yerel (upstream'e eşit) | 1 | Description tamamen İngilizce | TR tetikleyici ("eksik çeviriler", "yeni dil ekle") | Orta-yüksek |
| **healthcare-phi-compliance** | Yerel (ECC, description yerelleştirilmiş) | 1 | KVKK description'da yok, kullanıcının fiili bağlamı KVKK | "KVKK" tetikleyicisi | Orta-yüksek |

\* Skill sayıları ana oturum transcript'lerinden (alt agent'lar hariç).

**Filo geneli skill notu:** 76 `offensive-*` skill, skill listeleme bütçesinin (~%1 bağlam) büyük kısmını tüketiyor; az kullanılan skill'lerin description'ı kırpılıp otomatik tetiklenmesi zorlaşabilir (MEDIUM güven). Yerel skill oldukları için `skillOverrides` ile name-only'ye çekilebilir — red-audit bunları zaten tam yolla çağırıyorsa kayıp yok.

---

## 4. Filo geneli bulgular

1. **Zincir yalnız prose ile işliyor.** Aynı oturumdaki reviewer çiftlerinin **%39**'u aynı dosya:satırı raporluyor (php↔security 17, php↔ts 15). HIGH bulgu içeren 47 rapora karşılık 7 re-review. 6 koşu limit mesajı döndürdü ve bunu "review yapılmadı" diye işaretleyen bir mekanizma yok. Önemsiz olmayan commit'lerin ~%26'sı reviewer'sız (kaba ölçüm). → PRD-3.
2. **Bulgular doğrulanmadan uygulanıyor.** `CLAUDE.md:25` "ciddi bulguları uygula" diyor; Anthropic'in resmi code-review'u bulgu başına doğrulayıcı koşturuyor. → PRD-3.
3. **ponytail personası her subagent'a giriyor** (329/329). Plugin'in kendi `PONYTAIL_SUBAGENT_MATCHER` seçeneği var (`ponytail-subagent.js:8-11`). → PRD-1.
4. **Windows kabuk hataları tekrar ediyor:** `python3` yok, bash'te `%TEMP%`, bash'te PowerShell cmdlet'i, `Masaüstü` yolunda mojibake, ters bölü yenmiş `rm` yolu. Tek bir SubagentStart hook'u ile 5 satırlık ortam notu enjekte etmek 19 dosyayı düzenlemekten ucuz (N4).
5. **Frontmatter'da `effort`, `maxTurns`, `color` hiç kullanılmıyor.** `settings.json`'da `claude-sonnet-5.effortLevel: xhigh` kaydı var; reviewer effort'unu açıkça sabitlemek gerekebilir (alt agent'ın oturum effort'unu miras alıp almadığı belgede açık değil — doğrulanmadı).
6. **Model seçimi doğru.** Reviewer'ları haiku'ya taşımak önerilmiyor: superpowers ölçümünde haiku 2-3× tur harcadı.
7. **Doc Stop hook çoğunlukla gürültü:** `doc-update-reminder.js:35` `core.quotePath` yüzünden Türkçe adlı `.md`'yi kaynak sayıyor (test reposunda yeniden üretildi); `:49` imzası her edit'te değişip tekrar blokluyor; worktree'lerde 8-12 tekrar. 83 tetikleme → 4 koşu.
8. **Hook çakışması:** autoresearch'ün scout-block hook'u reviewer'ların `node_modules/.bin`, `build/`, `*.log`, Expo `.d.ts` erişimini engelliyor.
9. **Negatif bulgular (sorun değil):** CRLF (`git ls-files --eol` LF), agent description bütçesi (4.4k karakter, eşiğin çok altında), VoltAgent/wshobson reviewer'ları bizimkilerden zayıf (Write/Edit araçlı, yetenek listesi tarzı).
10. **Memory tutarsızlıkları:** `ecc-kurulumu.md` "geniş fan-out → yerleşik Explore" diyor, `CLAUDE.md:59` ise Explore'u yasaklıyor; doc-updater'ın sonnet'e geçişi bilinçli mi kayıtlı değil.

---

## 5. Upstream güncelleme stratejisi (kontrolünde olmayan varlıklar)

**Soru:** Upstream'den gelen agent/skill'ler güncellendiğinde yerel iyileştirmelerini nasıl korursun?

### 5.1 Ölçüm (D ajanı; dış görüş tarafından düzeltildi)

| Varlık sınıfı | Yerel ayrışma | Upstream bu dosyalara dokundu mu? | Risk |
|---|---|---|---|
| 18 ECC agent'ı (`agents/`) | ~589 satır (+11 … +140) | Pin `9ac593b5` → HEAD arası 1133 commit'te **hayır** (aynı yol üzerinden ölçüldü) | Düşük |
| 35 ECC skill'i | 0 (temiz kopya) | çoğu hayır; **laravel-security +22** | Yok — güncelle |
| `bootstrap/ecc-local.patch` (gateguard) | — | Upstream aynı sorunu PR #3107 ile çözdü | **Koşullu**, aşağıya bak |
| Plugin cache (impeccable, ui-ux-pro-max, autoresearch) | 0 | — | Yok |
| Tamamen yerel (outside-view, red-audit, checklist'ler, orchestration) | %100 | upstream yok | Yok |

**Düzeltme 1 — patch "ölü" değil.** D ajanı `git apply --check`'in başarısız olmasını "patch artık uygulanmıyor" diye yorumladı. Kontrol ettim: patch yerel klonda **zaten uygulanmış** (`git apply --check --reverse` temiz) ve pinlenmiş `9ac593b5`'e **temiz uygulanıyor**. Laptop bootstrap'i bugünkü haliyle çalışır. Patch yalnız pin, #3107'nin merge commit'i `7b7dfc6`'yı içeren bir sürüme yükseltilirse gereksizleşir — ve outside-view'e göre o zaman bile körlemesine düşürmemek gerekir: upstream çözümü `clickhouse-client`, `mongosh` ve tartışmalı `env -S`/`--argv0` biçimlerini kapsamıyor olabilir. Önce iki kapsamı karşılaştır.

**Düzeltme 2 — `skillOverrides` bir hata değil, tasarım.** D ajanı plugin skill'lerinde `skillOverrides`'ın çalışmamasını açık bir bug (#89724) gibi sundu; resmi doküman bunu belgelenmiş davranış olarak yazıyor: "Plugin skills are not affected. Manage them through /plugin."

**Doğrulanmış gerçekler** (dış görüş, kaynaklı):
- Aynı isimli yerel skill plugin skill'ini **gölgelemez**, ikisi de yüklenir ([skills doc](https://code.claude.com/docs/en/skills)).
- Agent'larda durum **tersi**: yerel `~/.claude/agents/` aynı isimli plugin agent'ını bastırır ([sub-agents doc](https://code.claude.com/docs/en/sub-agents)). Yani 18 ECC agent'ı için ayrı koruma makinesine gerek yok.
- Kendi fork'unu `owner/repo#ref` veya `sha` pinli marketplace girişiyle eklemek belgelenmiş; `version` alanı sabitse güncelleme gelmez ([host-marketplace](https://code.claude.com/docs/en/plugins/host-marketplace)).

### 5.2 Karar (Karar Eleştirisi formatı)

#### A) ECC kökenli agent ve skill'ler
- **En güçlü itiraz:** "pin→HEAD = 0" ölçümü yalnız aynı yoldaki değişikliği görür; upstream dosyaları taşırsa ya da toplu format değişikliği yaparsa sessizce 0 görünür, ve geçmiş ölçüm geleceği garanti etmez. Ayrıca D'nin önerdiği `diffecc.py` yazılmamış bir yer tutucu.
- **Öneri:** Klonda bir `local` branch tut ve `git merge origin/main` ile gerçek 3-yollu birleştir; script yazma, yerine iki komut:
  ```bash
  git -C plugins/ecc diff --stat <eski-pin>..origin/main -- agents/ skills/
  git -C plugins/ecc log --stat --diff-filter=R <eski-pin>..origin/main -- agents/ skills/   # taşıma/yeniden adlandırma
  ```
  Sonuç kuralı: upstream değişti + yerel 0 → kopyala (laravel-security); upstream değişti + yerel >0 → `git merge-file` ile elle; upstream değişmedi → dokunma.
- **Neden iyi:** Bugünkü veride çakışma 0, güncelleme başına birkaç dakika; dosyalar zaten dotfiles reposunda versiyonlu, geri dönüş `git checkout`.
- **Risk:** Elle kopyalama adımı unutulabilir; tek koruma memory'deki prosedür notu.
- **Alternatif:** ECC'yi tam plugin olarak kurmak → yerel agent'lar plugin olanları zaten bastırdığı için çalışır, ama ECC'nin tüm hook/skill setini (bilinçli kurulmayanlar dahil) geri getirir. Bugünkü cherry-pick kararıyla çelişiyor.
- **Ne zaman yanlış olur:** Upstream agent dosyalarını aktif değiştirmeye başlarsa (bir sonraki ölçümde pin→HEAD > 0 çıkan agent sayısı artarsa) → ECC'yi fork'la ve `local` branch'i fork'ta tut.

#### B) Plugin skill'leri (impeccable, ui-ux-pro-max, autoresearch)
- **En güçlü itiraz:** CLAUDE.md "overlay" kuralı deterministik değil; plugin skill'i her zaman yüklü kalır ve kural ile çelişirse model ikisini birden görür.
- **Öneri:** Cache'te yerel düzenleme yapma (yeni sürüm dizini gelince kaybolur). Davranış tercihlerini CLAUDE.md'ye yaz, genel değeri olan düzeltmeyi upstream'e PR olarak gönder, düzenli `claude plugin update` çalıştır.
- **Neden iyi:** Sıfır bakım, çakışma yok, upstream düzeltmeleri otomatik gelir.
- **Alternatif (ağır özelleştirme gerekirse):** Plugin'i `/plugin` ile kapat ve skill'i `~/.claude/skills/`'e vendor et (graphify-windows deseni) — çifte yüklemeyi çözen tek temiz yol. Ya da kendi fork'unu `ref`+`sha` pinli girişle ekle (rebase zorunlu değil, sürüm sabitlenir; `version` alanını sil).
- **Ne zaman yanlış olur:** Plugin metninde senin iş akışını bozan bir hata varsa ve upstream PR'ı kabul etmiyorsa → vendor et.

#### C) Tamamen yerel varlıklar
Buna karşı güçlü bir argüman yok: upstream yok, koruma sorunu yok. Doğrudan düzenle, dotfiles reposunda versiyonla. İstisnalar: claude.ai synced eski proje-checklist'i kapat; orchestration gibi junction skill'leri `setup.ps1`'e ekle.

### 5.3 Güncelleme prosedürü (aylık / ihtiyaç halinde)
```powershell
# 1) Yedek
Copy-Item -Recurse ~/.claude/skills ~/.claude/backups/skills-pre-ecc-$(Get-Date -f yyyyMMdd)
# 2) ECC
git -C ~/.claude/plugins/ecc fetch origin
git -C ~/.claude/plugins/ecc diff --stat 9ac593b5..origin/main -- agents/ skills/
git -C ~/.claude/plugins/ecc log --oneline 9ac593b5..origin/main -- scripts/hooks/gateguard-fact-force.js
#    hook değiştiyse: yerel patch ile #3107 kapsamını karşılaştır, sonra pin'i yükselt ve patch'i ya düşür ya da yeniden yaz
#    yeni pin → bootstrap/setup.ps1 $eccSha
# 3) Değişen + yerelde dokunulmamış skill'leri kopyala (bugün: laravel-security)
# 4) Plugin'ler
claude plugin marketplace update
claude plugin update impeccable@impeccable
claude plugin update ui-ux-pro-max@ui-ux-pro-max-skill
# 5) Memory: yeni pin SHA, değişen dosyalar, patch kararı
```

---

## 6. Önerilen uygulama sırası

1. **Hemen (tek satırlık, risksiz):** ponytail matcher · ESLint `--ext` · kırık atıflar · laravel-security'yi güncelle · eski synced proje-checklist'i kapat.
2. **Eval seti (PRD-4 C)** — baseline al.
3. **PRD-1 + PRD-2** (reviewer temeli + stack uyumu) → eval ile ölç.
4. **PRD-3** (zincir kuralları) → 10 commit gözlem.
5. **PRD-4 A/B** (skill tetikleme, doc hook) + 7 agent'ı arşivle + pr-test-analyzer kuralı.
6. **Eval verisi olursa:** Moonshot'lar — `/review-chain` komutu + commit hook zorlaması, diff dosyası paylaşımı / reviewer birleştirme (superpowers'ta −%37 token), yerleşik `/code-review low` karşılaştırması, ECC `commit-reviewer`.

### Kararlar (2026-10-16, kullanıcı)
- silent-failure-hunter: scratchpad'de, ağsız deney script'i **serbest**.
- security-reviewer: login/şifre sıfırlama/OTP'de rate-limit eksikliği **MEDIUM**.
- Küçük diff istisnası: **≤10 satır**, tek dosya, auth/girdi/hata akışı yok → yalnız dil reviewer'ı (ilk 10 commit'te gözle).
- Doc hatırlatması Stop'ta kalıyor; codemap yoksa **yalnız .md + memory** — **uygulandı** (`hooks/doc-update-reminder.js`, `agents/doc-updater.md`).
- Eval seti tekrar sayısı: açık.

---

## 6b. Uygulama durumu (2026-10-16)

**Uygulandı:**
- 8 reviewer'a ortak "Read-only Contract & Execution Limits" + "Findings Format & Verdict" bloğu (güven ≥80, en fazla 8 bulgu, `Verdict:` satırı, `ponytail:` yorumu bulguyu silmez).
- php-reviewer: Stop hook'un koştuğu pint/phpstan tekrarlanmıyor; onay kriteri "tools run | relied on Stop hook"; stil maddeleri MEDIUM; Livewire 3/4; silme diff'lerinde dynamic-reference kontrolü.
- typescript-reviewer: pre-commit varsayılan, ESLint 9 uyumlu lint, React lane devri. react-reviewer: platform algılama + React Native/Expo bölümü, `AsyncStorage` token kuralı.
- security-reviewer: stack algılama, Laravel checklist, `composer audit`, hard exclusions, login/şifre sıfırlama/OTP rate-limit → MEDIUM.
- database-reviewer: motor algılama (MySQL 8 / SQLite / PostgreSQL), MySQL strict mode ve migration kuralları.
- silent-failure-hunter: mock fallback, kullanıcı geri bildirimi, Laravel/JS kalıpları, severity tanımları, scratchpad'de ağsız deney izni.
- outside-view-reviewer: untrusted content + tool limits, snippet ≠ kaynak, CVE için NVD/GHSA, Verdict başa. code-explorer: salt-okuma komut listesi, Dependencies + Doğrulama zorunlu, bütçe.
- Bütün skill atıfları `Read <tam yol>` (kırık atıf: 0).
- CLAUDE.md zincir kuralları: lane, birleştirme, doğrula-sonra-uygula, Verdict yoksa INCOMPLETE, re-review, diff hash, ≤10 satır istisnası, pr-test-analyzer tetikleyicisi.
- 7 agent arşivlendi (`backups/agents-archive-20261016/`); pr-test-analyzer merge-base düzeltmesi.
- 5 skill description'ı Türkçe karakterli; red-audit > laravel-security önceliği; laravel-security ECC'den güncellendi.
- Doc Stop hook: codemap yoksa yalnız .md + memory; dosya-kümesi imzası; quotePath. doc-updater "Mode" bölümü.
- `PONYTAIL_SUBAGENT_MATCHER=^(general-purpose|claude|fork)$`.
- Eval seti: `evals/reviewers/run.py` (6 hata + 2 tuzak, 1 tekrar).

**Eval (önce → sonra):** hit 6/6 → 6/6 · yanlış alarm 0/2 → 0/2 · Verdict 0/8 → 8/8 · repoya yazma 0 → 0 · maliyet 0,53 $ → 0,64 $ · süre 367 sn → 283 sn. Fixture'lar bugünkü reviewer'lar için kolay; set gerileme koruması işlevi görüyor.

**Kullanıcıya kalan:** claude.ai → Skills'te eski 6 başlıklı `proje-checklist`'i kapat.
**Yapılmadı (Moonshot / sonraya):** `/review-chain` komutu, commit hook zorlaması, reviewer birleştirme, Windows ortam notu için SubagentStart hook, frontmatter `effort`/`maxTurns`, plugin güncellemeleri (impeccable, ui-ux-pro-max).

## 7. Güven ve sınırlar
- Oranlar (%39 tekrar, 41/69, %26 reviewer'sız commit) regex/sezgisel sayım; yön net, kesin değer değil.
- python/csharp reviewer kartları n=1 / n=0.
- impeccable "129 PR/30 gün" ve ECC "1133 commit" rakamları tek ajan ölçümü; dış görüş tekrar doğrulamadı.
- Rakip matrisinde `[varlık]` işaretli dosyaların yalnız varlığı doğrulandı, içeriği okunmadı.
- doc-updater'daki derinleştirmenin ne zaman kaybolduğu doğrulanmadı (dotfiles reposunun geçmişi 19eb680'den başlıyor).

## 8. Kaynaklar
**Resmi doküman:** [sub-agents](https://code.claude.com/docs/en/sub-agents) · [skills](https://code.claude.com/docs/en/skills) · [hooks](https://code.claude.com/docs/en/hooks) · [model-config](https://code.claude.com/docs/en/model-config) · [plugin-evals](https://code.claude.com/docs/en/plugin-evals.md) · [code-review-local](https://code.claude.com/docs/en/code-review-local.md) · [host-marketplace](https://code.claude.com/docs/en/plugins/host-marketplace) · [marketplace-reference](https://code.claude.com/docs/en/plugins/marketplace-reference) · [skill best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
**Anthropic referans uygulamaları:** [code-review komutu](https://github.com/anthropics/claude-code/blob/main/plugins/code-review/commands/code-review.md) · [pr-review-toolkit](https://github.com/anthropics/claude-code/tree/main/plugins/pr-review-toolkit) · [claude-code-security-review](https://github.com/anthropics/claude-code-security-review) · [feature-dev code-explorer/architect](https://github.com/anthropics/claude-code/tree/main/plugins/feature-dev/agents)
**Topluluk:** [obra/superpowers task-scoped review spec](https://github.com/obra/superpowers/blob/main/docs/superpowers/specs/2026-06-09-sdd-task-scoped-review-dispatch-design.md) · [superpowers receiving-code-review](https://github.com/obra/superpowers/blob/main/skills/receiving-code-review/SKILL.md) · [wshobson/agents](https://github.com/wshobson/agents) · [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) · [qodo pr-agent config](https://github.com/qodo-ai/pr-agent/blob/main/pr_agent/settings/configuration.toml) · [CR-Bench (ICLR 2026)](https://www.iclr.cc/virtual/2026/10017268) · [ESLint 9 migration](https://eslint.org/docs/next/use/migrate-to-9.0.0)
**Upstream:** [ECC](https://github.com/affaan-m/ECC) · [ECC #3024](https://github.com/affaan-m/ECC/issues/3024) · [ECC PR #3107](https://github.com/affaan-m/ECC/pull/3107) · [Claude Code #89724](https://github.com/anthropics/claude-code/issues/89724)
**Yerel kanıt:** `autoresearch/scenario-261016-0403/{reviewers,process,skills}-*.md` (transcript dosya adları ve alıntılarla), `upstream-strategy.md`, `autoresearch/improve-261016-0403/research-findings.md`, `competitor-matrix.md`.
