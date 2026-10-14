# Proje Checklist — Web & Uygulama (Detaylı)

> Framework-**bağımsız** kontrol listesi. Parantez içi araçlar yalnızca örnektir (Laravel'e özel değil; Node/Django/Rails vb. için karşılığını uygula).
> Her madde: **terim** — ne / neden / nasıl. `[ ]` → `[x]` ile işaretle.
> 11 başlık, yaşam döngüsü sırasıyla. **Mobil uygulama maddeleri ayrı skill'dedir** (`mobil-checklist`).

---

## 1. Planlama & Gereksinimler

- [ ] **Kapsam & başarı kriterleri** — Ne yapılacak / yapılmayacak (scope) net; ölçülebilir başarı tanımı.
- [ ] **Hedef kitle / persona** — Kim kullanacak + temel kullanıcı senaryoları.
- [ ] **Fonksiyonel + non-fonksiyonel gereksinim** — Özellikler + performans/güvenlik/ölçek beklentileri yazılı.
- [ ] **Sayfa/ekran envanteri + akış** — Sitemap/ekran listesi + kullanıcı akışı.
- [ ] **Teknoloji & mimari kararı** — Stack, mimari (monolit/servis), 3. taraf bağımlılıklar; gerekçeli.
- [ ] **Veri modeli taslağı** — Ana varlıklar + ilişkiler erkenden çıkarılır.
- [ ] **Tahmin & zaman çizelgesi** — Kilometre taşları, bağımlılıklar, riskler.
- [ ] **Lisans / telif envanteri** — Font/görsel/kütüphane lisansları uyumlu.
- [ ] **Karar kaydı (ADR)** — Önemli teknik kararları gerekçesiyle kaydet.

---

## 2. UX & Tasarım

- [ ] **Wireframe → mockup → prototip** — Koda başlamadan akışı doğrula.
- [ ] **Design system / component library** — Renk, tipografi, boşluk, bileşen tutarlılığı.
- [ ] **Responsive breakpoint'ler** — Mobil/tablet/masaüstü düzenleri tanımlı.
- [ ] **Dark mode** — Gerekiyorsa tema desteği.
- [ ] **State tasarımı** — Empty / loading / error / success ekranları tasarlandı.
- [ ] **404 & 5xx sayfaları** — Marka uyumlu, kullanıcıyı yönlendiren.
- [ ] **Mikro-kopya (UX yazımı)** — Buton, hata, boş durum metinleri net ve tutarlı.
- [ ] **Favicon + ikonlar** — Tüm boyutlar (web + PWA).

---

## 3. Frontend / UI

- [ ] **Semantic HTML** — Doğru etiket/landmark kullanımı.
- [ ] **Responsive uygulama** — Tasarım breakpoint'lerine birebir uy.
- [ ] **Cross-browser** — Chrome/Safari/Firefox/Edge.
- [ ] **Erişilebilirlik temeli (a11y)** — Kontrast, klavye navigasyonu, focus state, ARIA, form label.
- [ ] **State yönetimi** — Öngörülebilir, tek kaynak; gereksiz global state'ten kaçın.
- [ ] **Form UX** — Inline validation, hata-mesajı ilişkisi, disable/loading durumları.
- [ ] **Optimistic UI / hata geri alma** — Uygunsa anlık tepki + başarısızlıkta geri al.
- [ ] **Console temiz** — Prod'da log/warn/error yok.
- [ ] **i18n hazır** — Hardcoded metin yok (çok dilliyse; bkz. Backend/Yasal).
- [ ] **Asset hijyeni** — Kullanılmayan CSS/JS/asset temizliği.

---

## 4. Backend

### API
- [ ] **Sözleşme + versiyonlama** — Endpoint ve payload'ı baştan sabitle; URL'de versiyon (`/api/v1`). Breaking change'de v2 aç, eskiyi bir süre yaşat.
- [ ] **Doğru HTTP status** — 200/201/204 başarı, 400 validasyon, 401 auth, 403 yetki, 404 yok, 409 çakışma, 422 işlenemez, 429 rate limit, 5xx sunucu.
- [ ] **Tutarlı response zarfı** — Tüm yanıtlar aynı yapıda: `{ data, meta, errors }`.
- [ ] **Pagination** — Liste uçlarında cursor/offset; `meta`'da toplam/next. Tabloyu tek seferde dönme.
- [ ] **Filtre/sıralama/arama** — Standart query param; izinli alanları whitelist'le (injection + performans).
- [ ] **Idempotency key** — Ödeme/sipariş gibi tekrarı tehlikeli POST'larda; aynı key tekrar gelirse ilk sonucu dön.
- [ ] **Content negotiation** — `Accept`/`Content-Type` ile tip yönet; beklenmeyen tipte 406/415.
- [ ] **API dokümantasyonu** — Makine-okur şema (ör. OpenAPI/Swagger üretici). Frontend + client SDK üretimini kolaylaştırır.
- [ ] **Correlation/trace ID** — Her isteğe benzersiz ID; log + response header. Uçtan uca izlersin.

### Auth & Authorization
- [ ] **Authentication** — Stateless API'de token (ör. JWT/opaque), klasik web'de session. Web+mobil ikisi varsa token.
- [ ] **Refresh + expiry + revocation** — Kısa ömürlü access + uzun ömürlü refresh; logout/çalınmada revoke (jti/token kaydı).
- [ ] **2FA/MFA** — En az admin paneli için TOTP.
- [ ] **E-posta doğrulama** — Kayıt sonrası imzalı link. Sahte hesap/spam'i azaltır.
- [ ] **Şifre sıfırlama** — Tek kullanımlık, süreli token; hash'leyerek sakla, mailden yolla.
- [ ] **RBAC/ABAC** — Rol veya öznitelik bazlı yetki (ör. spatie/permission, CASL, casbin).
- [ ] **Policy/Gate** — Yetki kontrolünü merkezi policy'de yap, controller'lara dağıtma.
- [ ] **IDOR koruması** — Kaynak erişiminde sahiplik doğrula; login olması yetmez.

### Veri Doğrulama & İş Mantığı
- [ ] **Server-side validation** — İstemciye güvenme; her girişi sunucuda doğrula (ör. FormRequest / zod / serializer). Client validation sadece UX.
- [ ] **Sanitization** — Beklenen tipe çevir, tehlikeli karakterleri temizle (özellikle HTML/markdown girişi).
- [ ] **Mass assignment koruması** — Toplu atanabilir alanları sınırla (allow/deny list); `is_admin` dışarıdan set edilemesin.
- [ ] **Para birimi** — Kuruş cinsinden integer ya da decimal; float yuvarlama para kaybettirir.
- [ ] **Zaman** — DB'ye UTC yaz, kullanıcıya locale/timezone'da göster.

### Veritabanı
- [ ] **Reversible migration** — Geri alınabilir (up/down) migration; rollback = deploy güvenliği.
- [ ] **FK + cascade** — İlişkiler DB seviyesinde; silme davranışını bilinçli seç (cascade/restrict/set null).
- [ ] **Index stratejisi** — Sık filtre/join kolonlarına index, çoklu koşula composite (perf detayı: Performans bölümü).
- [ ] **N+1 tespiti** — Döngüde sorgu patlamasını yakala (ör. query logger/APM), eager loading'e çevir.
- [ ] **Transaction** — Çok adımlı yazma tek atomik blokta; biri patlarsa hepsi geri alınsın.
- [ ] **Soft delete + audit trail** — Kalıcı silme yerine işaret; kim ne zaman ne değiştirdi (activity log).
- [ ] **Seeder/factory** — Tekrarlanabilir test/demo verisi.
- [ ] **Query timeout + pool** — Uzun sorguya zaman sınırı + bağlantı havuzu.
- [ ] **Read replica** — Okuma yükü yüksekse okumayı replica'ya yönlendir.
- [ ] **Row-level security / tenant izolasyonu** — Multi-tenant veride her kaydın tenant'a aitliğini garanti et: DB RLS politikası veya uygulama global scope (otomatik `tenant_id` filtresi). Multi-tenant ürünlerde kritik.

### Altyapı Servisleri
- [ ] **Caching** — Pahalı sorgu/hesabı cache'le; invalidation kuralı + TTL'i baştan belirle.
- [ ] **Queue** — Yavaş işleri kuyruğa al; retry/backoff, dead-letter, idempotent işle.
- [ ] **Scheduled job/cron** — Periyodik işler için scheduler (ör. framework scheduler + tek cron) (güvenilirlik: DevOps).
- [ ] **Dosya upload** — Storage soyutlaması (S3/local), boyut + gerçek MIME doğrulama, mümkünse AV tarama; orijinal adı kullanma.
- [ ] **Görsel pipeline** — Yükleneni resize/optimize/WebP'e çevir (görsel işleme kütüphanesi).
- [ ] **Mail** — Queued gönder, template, SPF/DKIM/DMARC, bounce işle.
- [ ] **Webhook** — İmza doğrula, retry'a karşı idempotent ol, hızlı 200 dön + işi kuyruğa at.
- [ ] **Global exception handler** — Tek noktadan yakala; kullanıcıya temiz mesaj, log'a detay + trace ID.
- [ ] **Error boundary (frontend) + fallback UI** — İstemcide bir bileşen patlarsa tüm uygulama düşmesin; hatayı sınırla, fallback göster, izlemeye raporla.
- [ ] **Health/readiness endpoint** — `/health` DB/cache/queue durumu dönsün; LB & monitoring kullanır.
- [ ] **Graceful shutdown** — Deploy/restart'ta süren istek/job'ları bitirip kapan.

---

## 5. Güvenlik

### Transport & Sırlar
- [ ] **HTTPS zorunlu + TLS 1.2+** — HTTP'yi HTTPS'e zorla, eski TLS'i kapat.
- [ ] **HSTS** — Tarayıcıya "hep HTTPS" de; preload listesine ekle.
- [ ] **.env / secrets repo dışında** — API key, DB şifresi koda/git'e girmesin (`.gitignore`).
- [ ] **Git geçmişi sır taraması** — Sızmış sırrı tara (ör. gitleaks/trufflehog); bulunanı rotate et (silmek yetmez).
- [ ] **Secret rotation** — Sızma şüphesinde veya periyodik key/şifre yenileme.
- [ ] **Varsayılan/admin kimlik değişimi** — Demo/varsayılan şifreleri prod'a çıkmadan değiştir.
- [ ] **Prod debug kapalı** — Debug/verbose mode kapalı (ör. `APP_DEBUG=false` / `NODE_ENV=production` / `DEBUG=False`). Açık debug env+trace sızdırır.
- [ ] **Client/bundle sır sızıntısı** — Frontend bundle'ına gizli key gömme; sadece public anahtarlar client'ta. Env prefix'ini denetle (public-only).

### Şifreleme (Encryption)
- [ ] **Transit şifreleme** — Tüm trafik TLS üzerinde; iç servisler arası çağrılar da şifreli kanaldan.
- [ ] **At-rest şifreleme** — DB/disk seviyesinde şifreleme (yönetilen DB'lerde çoğu kez varsayılan; VPS'te disk/volume).
- [ ] **Alan bazlı (field-level) şifreleme** — PII/ödeme/sağlık alanlarını kolon bazında şifrele (ör. framework encrypted cast / app-level crypto). DB sızsa bile okunamaz.
- [ ] **Anahtar yönetimi** — Anahtarı secret manager'da tut; rotasyon planı + eski veriyi yeni anahtara taşıma.
- [ ] **Hash ≠ şifreleme** — Geri çevrilmemesi gerekeni hash'le (şifre → argon2/bcrypt); geri okunması gerekeni şifrele.

### Uygulama Katmanı (OWASP Top 10)
- [ ] **CSRF** — Oturum tabanlı isteklerde CSRF token; framework korumasını açık tut.
- [ ] **XSS** — Çıktıyı escape et, kullanıcı HTML'ini sanitize et, CSP ekle.
- [ ] **SQL injection** — Parametreli sorgu/ORM; ham string concat etme.
- [ ] **Mass assignment** — Yetki yükseltmeyi engeller (bkz. backend).
- [ ] **SSRF** — Sunucudan dışa istek atan yerde hedefi whitelist'le; iç IP'leri engelle.
- [ ] **Open redirect** — Yönlendirme parametresini whitelist'le; keyfi yönlendirme phishing aracı.
- [ ] **Clickjacking** — `X-Frame-Options` / CSP `frame-ancestors`.
- [ ] **IDOR** — Her kaynak erişiminde sahiplik/yetki kontrolü.
- [ ] **Upload güvenliği** — Executable kabul etme, içerik tipini doğrula, upload klasörünü çalıştırılamaz yap.
- [ ] **Path traversal / dosya servis** — `../` ile kök dizin dışına çıkışı engelle; dosya adını normalize et/whitelist'le.

### Kimlik & Oturum
- [ ] **Password hashing** — argon2id/bcrypt; asla düz/MD5/SHA1.
- [ ] **Şifre politikası + breach** — Min uzunluk, sızmış şifre reddi (HIBP); gereksiz karmaşıklık dayatma.
- [ ] **Cookie güvenliği** — Secure + HttpOnly + SameSite.
- [ ] **Session fixation** — Login sonrası session ID yenile.
- [ ] **Oturum süresi / idle timeout** — Mutlak + idle zaman aşımı; hassas panellerde kısa tut.
- [ ] **Logout = sunucu tarafı geçersizleştirme** — Çıkışta token/session'ı sunucuda iptal et; istemciden silmek yetmez.
- [ ] **Eşzamanlı oturum politikası** — Çoklu cihaz oturumlarını listele/sonlandır; şifre değişiminde hepsini düşür.
- [ ] **Oturum deposu** — Güvenli + ölçeklenebilir yerde (Redis/DB); çok sunucuda dosya tabanlı session paylaşılmaz.
- [ ] **Brute-force/lockout/throttle** — Login denemesini sınırla, captcha/lockout ekle.
- [ ] **Admin 2FA** — Yönetim erişimine ikinci faktör.
- [ ] **Hesap enumerasyonu önleme** — Login/şifre-sıfırlama yanıtları "bu e-posta kayıtlı mı" sızdırmasın; tek tip mesaj + sabit süre.

### Header & Erişim
- [ ] **Security header'lar** — CSP, HSTS, X-Content-Type-Options:nosniff, Referrer-Policy, Permissions-Policy. (securityheaders.com ile test et.)
- [ ] **CORS** — İzinli origin'leri whitelist'le; `*` + credentials kullanma.
- [ ] **Rate limiting** — IP/kullanıcı/endpoint başına sınır; abuse & DoS azaltır.
- [ ] **Bot koruması** — Form/login'de Turnstile/reCAPTCHA.
- [ ] **DDoS/WAF** — Cloudflare vb. önünde; L7 saldırı & bot filtreleme.
- [ ] **Subresource Integrity (SRI)** — CDN/3. taraf script/style'a `integrity` hash'i; tedarik zinciri saldırısını önler.

### Sunucu & Tarama
- [ ] **SSH key-only + root kapalı + fail2ban** — Parola login kapat, root devre dışı, brute-force ban.
- [ ] **Firewall/port hardening** — Sadece gerekli portlar açık (80/443/SSH).
- [ ] **En az yetkili DB user** — Uygulama kullanıcısı sadece gerekeni yapsın; root değil.
- [ ] **Bağımlılık taraması** — `composer audit` / `npm audit`, Dependabot/Snyk; bilinen CVE'leri yakala (düzenli: DevOps).
- [ ] **Image taraması** — Konteyner kullanıyorsan Trivy vb.
- [ ] **Yedekler şifreli** — At-rest şifreleme.
- [ ] **Hata sayfası sızıntısı yok** — 5xx'te stack trace/SQL gösterme.
- [ ] **OWASP/pentest** — Periyodik gözden geçirme; ZAP gibi otomatik tarayıcı.
- [ ] **SAST/DAST (CI)** — Pipeline'da otomatik statik + dinamik güvenlik taraması.
- [ ] **Güvenlik olayı müdahale planı** — İhlal anında: tespit → izolasyon → kanıt → bildirim → kurtarma.
- [ ] **security.txt** — `/.well-known/security.txt` ile sorumlu açıklama kanalı.

### Veritabanı Güvenliği
- [ ] **DB ağ erişimi** — DB portu internete kapalı; sadece app sunucusundan / private network'ten (firewall). Bağlantı TLS ile.
- [ ] **Least-privilege + rol ayrımı** — App kullanıcısı sadece CRUD; DDL (DROP/ALTER) yok. Mümkünse okuma/yazma ayrı kullanıcı.
- [ ] **NoSQL injection** *(MongoDB vb.)* — Operatör/`$where` injection'a karşı girdiyi tip-doğrula; girdiyi sorgu operatörü olarak yorumlama.
- [ ] **DB'de düz metin sır yok** — Token/API key/parola DB'de düz tutulmaz (hash/şifreli).
- [ ] **Hassas veri maskeleme** — Prod verisini staging/dev'e taşırken maskele/anonimleştir.
- [ ] **DB audit / erişim log'u** — Şema değişikliği + hassas tablo erişimini logla (PII'den kaçınarak).
- [ ] **Yedek erişimi** — DB yedeklerine erişim kısıtlı + şifreli (bkz. DevOps).

### Loglama & İzlenebilirlik (güvenli & detaylı)
- [ ] **Yapısal loglama + seviye** — JSON yapısal log + seviye (debug/info/warn/error); prod'da debug kapalı.
- [ ] **Correlation/trace ID** — Her isteğe benzersiz ID; uçtan uca izlenebilirlik (bkz. Backend).
- [ ] **Ne loglanır / ne loglanMAZ** — Hata, güvenlik olayı, kritik iş olayı loglanır; parola, token, oturum ID, tam kart no, PII loglanMAZ.
- [ ] **Hassas veri maskeleme (redaction)** — Loga giden alanları otomatik maskele; yanlışlıkla sızmayı önle.
- [ ] **Log injection önleme** — Kullanıcı girdisini loga yazarken newline/CRLF temizle; sahte log satırını (log forging) engelle.
- [ ] **Tamper-evident / append-only** — Logu silinemez/değiştirilemez tut (append-only/WORM/hash zinciri); saldırgan izini silemesin.
- [ ] **Log erişim kontrolü** — Loglara erişim kısıtlı + at-rest şifreli; log deposu da saldırı yüzeyidir.
- [ ] **Saklama + rotation + yasal** — Saklama süresi + rotation; kişisel veri içeren logda KVKK/GDPR süre sınırı.
- [ ] **Zaman senkronu (NTP)** — Sunucular arası saat senkron; doğru zaman damgası.
- [ ] **Audit log** — Login, yetki değişimi, silme gibi işlemleri ayrı + değiştirilemez logla.
- [ ] **Güvenlik olayı alarmı** — Başarısız login serisi, yetki yükseltme, anormal erişim → uyarı.
- [ ] **Hacim yönetimi (sampling)** — Yüksek hacimde örnekleme/seviye filtresi; kritik olayı kaybetme.
- [ ] **Merkezi toplama** — Logları tek yerde topla (bkz. DevOps).

### Koşullu (proje tipine göre)
- [ ] 🟡 **GraphQL güvenliği** *(GraphQL varsa)* — Prod'da introspection kapalı + sorgu derinlik/karmaşıklık limiti; batch/alias suistimaline karşı koruma.

---

## 6. Performans

### Ölçüm
- [ ] **Core Web Vitals** — LCP <2.5s, INP <200ms, CLS <0.1.
- [ ] **Lighthouse/PageSpeed** — Skor + somut öneri; CI'a ekle.
- [ ] **TTFB** — İlk byte süresi; yüksekse backend/DB/cache sorunu.
- [ ] **Performance budget** — "JS < X KB, LCP < Y" sınırı koy, aşılınca uyar.
- [ ] **RUM (saha verisi)** — Lab verisinin yanına gerçek kullanıcı metrikleri.

### Frontend / Asset
- [ ] **Bundle analizi** — Şişiren paketi bul (bundle analyzer).
- [ ] **Code splitting / lazy load** — Route/komponenti gerektiğinde yükle.
- [ ] **Tree shaking** — Kullanılmayan kodu ele.
- [ ] **Minify** — JS/CSS/HTML küçült (build adımında).
- [ ] **Critical CSS** — İlk ekran CSS'i inline, gerisi defer.
- [ ] **JS defer/async** — Render-blocking script'leri ertele.
- [ ] **Görsel** — WebP/AVIF, responsive srcset, width/height set (CLS önler).
- [ ] **Font** — subset + preload + `font-display: swap`.
- [ ] **3rd-party azaltma** — Analytics/chat widget'larını minimuma indir/ertele.
- [ ] **preconnect/dns-prefetch/preload** — Kritik origin/kaynağı öne al.
- [ ] **Service worker / PWA cache** — Tekrar ziyarette offline/hızlı (opsiyonel).
- [ ] **Liste sanallaştırma (windowing)** — Uzun liste/tabloda sadece görünen satırı render et (ör. virtual scroll).
- [ ] **Web Worker / ana thread offload** — Ağır client hesabını ana thread'den çıkar; jank'ı önler.
- [ ] **Bellek sızıntısı / cleanup** — listener/subscription/timer/observer'ları temizle.

### Network
- [ ] **Gzip/Brotli** — Metin yanıtlarını sıkıştır (Brotli daha iyi).
- [ ] **HTTP/2 veya HTTP/3** — İstek multiplexing.
- [ ] **Cache header + ETag** — Statik kaynağa uzun cache + versiyon hash; ETag ile 304.
- [ ] **CDN** — Statik asseti kullanıcıya yakın sun.
- [ ] **API response sıkıştırma** — Büyük JSON'u sıkıştır.

### Backend / DB
- [ ] **Query optimizasyonu** — EXPLAIN ile yavaş sorgu, index ekle, N+1 çöz.
- [ ] **Index doğrulama (EXPLAIN)** — Index gerçekten kullanılıyor mu, full table scan var mı doğrula.
- [ ] **Composite index kolon sırası** — Eşitlik → aralık → sıralama; en seçici kolonu uygun konuma koy. Yanlış sıra index'i atıl bırakır.
- [ ] **Covering index** — Sorgunun tüm ihtiyaç kolonlarını içeren index; tabloya geri dönüşü (lookup) ortadan kaldırır.
- [ ] **FK + partial/filtered index** — Foreign key kolonlarına index; sık filtrelenen alt kümeye partial index.
- [ ] **Full-text index** — Metin aramada `LIKE '%...%'` yerine full-text/GIN.
- [ ] **Index temizliği** — Kullanılmayan/yinelenen index'leri kaldır (over-indexing yazma maliyeti getirir).
- [ ] **İstatistik güncel (ANALYZE)** — Planner doğru karar versin diye istatistikleri güncel tut.
- [ ] **Slow query log** — Yavaş sorguları logla + düzenli gözden geçir.
- [ ] **Keyset/cursor pagination** — Derin sayfalamada offset yerine keyset.
- [ ] **Batch insert/update** — Tek tek yerine toplu yaz; round-trip azalt.
- [ ] **Connection pool boyutu** — Pool'u yüke göre boyutla.
- [ ] **Eager loading** — İlişkileri tek sorguda çek.
- [ ] **Query result cache** — Tekrar eden okumayı cache'te tut.
- [ ] **Connection pooling/reuse** — Bağlantı maliyetini azalt.
- [ ] **Opcache** *(PHP ise)* — Derlenmiş kod cache; prod'da şart.
- [ ] **Debounce/throttle** — Pahalı tetiklenen işlemleri sınırla.
- [ ] **Over-fetching önleme** — Sadece gereken alan/kolonu çek (field selection / sparse fieldsets / `select`).
- [ ] **Cache stampede koruması** — Cache dolunca eşzamanlı isteklerin DB'yi ezmesini engelle (lock / stale-while-revalidate / jitter'lı TTL).

### Koşullu (proje tipine göre)
- [ ] 🟡 **SSR/SSG / edge rendering** *(uygunsa)* — İlk yük için sunucu/statik/edge render; TTFB ve LCP'yi iyileştirir.
- [ ] 🟡 **Materialized view / denormalizasyon** *(okuma-ağırlıklı raporlarda)* — Pahalı toplulaştırmayı önceden hesapla.
- [ ] 🟡 **Table partitioning** *(çok büyük tablolarda)* — Tabloyu bölerek tarama/bakımı hızlandır.

---

## 7. SEO

- [ ] **Title + meta description** — Sayfa bazlı, benzersiz.
- [ ] **Open Graph + Twitter Card** — Paylaşım önizlemesi.
- [ ] **Structured data** — schema.org işaretlemesi.
- [ ] **sitemap.xml + robots.txt** — Doğru ve güncel.
- [ ] **Canonical URL** — Yinelenen içerik sinyali engellenir.
- [ ] **Heading hiyerarşisi** — Tek H1 + anlamlı yapı.
- [ ] **Görsel alt metni** — Erişilebilirlik + arama.
- [ ] **Temiz URL slug** — Anlamlı, kısa, kalıcı.
- [ ] **hreflang** — Çok dilliyse dil/bölge eşlemesi.
- [ ] **Indexlenebilirlik** — Prod indexlenebilir; staging `noindex`. Yanlışlıkla prod'da `noindex` olmamalı.
- [ ] **404 / 301 yönetimi** — Kırık linkler + doğru kalıcı yönlendirmeler.

---

## 8. Test & Doğrulama (Validation)

### Otomatik
- [ ] **Unit + coverage** — Saf iş mantığı; coverage eşiği belirle.
- [ ] **Integration** — Servis + DB birlikte.
- [ ] **E2E** — Gerçek kullanıcı akışı (Playwright/Cypress vb.).
- [ ] **API contract** — Response şeması sözleşmeye uyuyor mu.
- [ ] **Migration up/down** — Migration'lar tertemiz çalışıyor mu.
- [ ] **Visual/snapshot regression** — UI beklenmedik değişti mi.
- [ ] **Lokalizasyon testi** — Tüm diller + RTL doğru render.
- [ ] **Mutation testing** — Testlerin gerçekten yakaladığını ölç (opsiyonel).
- [ ] **CI'da PR başına test** — Merge öncesi otomatik koş.

### Doğrulama (Validation) testleri
- [ ] **Şema/contract doğrulama testi** — Şemaya uymayan veri reddediliyor mu.
- [ ] **Sınır değer (boundary) testi** — min/max, sıfır, negatif, çok uzun, unicode/emoji, boş.
- [ ] **Negatif testler** — Geçersiz/eksik/kötü niyetli girdi reddini doğrula; happy path yetmez.
- [ ] **Yetki matrisi (authz) testi** — Her rol × her kaynak; yetkisiz erişimi sistematik test et.
- [ ] **Idempotency / tekrar testi** — Aynı isteği iki kez gönder; çift kayıt/çekim olmamalı.
- [ ] **Race condition / eşzamanlılık testi** — Eşzamanlı isteklerde tutarlılık (stok/bakiye/benzersizlik).
- [ ] **Upload doğrulama testi** — Yanlış tip/boyut/zararlı dosya reddi.
- [ ] 🟡 **Fuzzing / property-based** *(uygunsa)* — Üretilen rastgele girdilerle kırılma noktası ara.

### Manuel / Senaryo
- [ ] **Manuel QA checklist** — Kritik akışların elle kontrolü.
- [ ] **Cross-browser/device** — Gerçek cihaz/tarayıcılarda.
- [ ] **Form + edge case** — Boş, çok uzun, özel karakter, sınır değer.
- [ ] **Auth/authz senaryoları** — Yetkisiz erişim reddediliyor mu.
- [ ] **Ödeme akışı (sandbox)** — Başarı/iptal/iade/timeout.
- [ ] **Hata & boş durum** — Boş liste, ağ hatası ekranları.

### Non-fonksiyonel
- [ ] **Yük/stres** — Beklenen + pik yükte davranış (k6/JMeter).
- [ ] **Güvenlik testi** — OWASP ZAP otomatik tarama.
- [ ] **Erişilebilirlik** — axe / Lighthouse a11y.
- [ ] **Performance budget testi** — Sınır aşımında CI fail.
- [ ] **Regresyon suite** — Eski hatalar geri gelmiyor.
- [ ] **Smoke test** — Deploy sonrası temel akış ayakta mı.
- [ ] **Test verisi izole** — Test gerçek veriye/maile dokunmasın.

### Test Kalitesi & Altyapı
- [ ] **Test piramidi dengesi** — Çok unit, orta integration, az E2E.
- [ ] **İzolasyon / determinism** — Sabit seed, sahte saat (clock mock), sıralamadan bağımsız.
- [ ] **Dış servis mock/stub** — 3. taraf API'leri mock'la; testler ağdan bağımsız.
- [ ] **Flaky test yönetimi** — Kararsız testleri tespit/karantina + kök neden.
- [ ] **Coverage gate (CI)** — Eşik altına düşünce pipeline fail.
- [ ] **Test raporlama** — CI'da test + coverage raporu görünür/arşivli.
- [ ] **Test ortamı prod'a yakın** — Şema/sürüm/config staging-benzeri.

---

## 9. Deployment & DevOps

### Sürüm Kontrolü & Branch Düzeni
- [ ] **Branch stratejisi** — `main` (prod) / `staging` (önizleme) / `feature/*` dalları; doğrudan main'e push yok.
- [ ] **Korumalı branch** — main/staging protected; PR + review + yeşil CI zorunlu.
- [ ] **Branch → ortam eşlemesi** — feature→preview, staging→staging, main→prod (mümkünse otomatik).
- [ ] **Anlamlı commit / küçük PR** — Açıklayıcı commit; küçük, gözden geçirilebilir PR (Conventional Commits opsiyonel).
- [ ] **Sır commit'lenmiyor** — pre-commit hook / secret scan (bkz. Güvenlik).
- [ ] **.gitignore eksiksiz** — env, build çıktısı, bağımlılık, IDE/OS dosyaları.

### Ortam & Pipeline
- [ ] **Ortam ayrımı** — dev/staging/prod ayrı DB, key, config.
- [ ] **Staging = prod** — Aynı sürüm/config; "bende çalışıyordu"yu önler.
- [ ] **CI/CD** — build → test → deploy otomatik (ör. GitHub Actions / GitLab CI).
- [ ] **GitHub Actions / CI workflow'ları** — Required status check (geçmeden merge yok); CI secrets güvenli (repo secrets, log'a basılmaz); bağımlılık/asset cache; gerekiyorsa matrix (PHP/Node sürümleri).
- [ ] **IaC** — Sunucu/altyapıyı kodla tanımla (opsiyonel).
- [ ] **Zero-downtime** — Atomic symlink/rolling deploy; kullanıcı kesinti görmesin.
- [ ] **Migration deploy adımında** — Otomatik ve sıralı; geri alınabilir.
- [ ] **Asset build pipeline'da** — Build CI'da, sunucuda değil.
- [ ] **Feature flag** — Özelliği deploy'dan bağımsız aç/kapat (opsiyonel).
- [ ] **Versiyonlama + tag + release notes** — Semantic versioning, ne değişti.
- [ ] **Rollback stratejisi** — Bir önceki sürüme hızlı dönüş.

### Güvenli Deploy
- [ ] **Şifreli kanaldan deploy** — SSH key / API token üzerinden; **FTP/parola ile deploy YOK**.
- [ ] **En az yetkili deploy anahtarı** — Deploy kullanıcısı/anahtarı sadece gerekeni yapsın; ayrı anahtar, gerekirse iptal edilebilir.
- [ ] **Sır deploy çıktısına sızmıyor** — Build/deploy log'unda secret görünmez; env enjeksiyonu güvenli.
- [ ] **Immutable / sürümlü artifact** — Aynı artifact test→prod; her sürüm izlenebilir + rollback'lenebilir.
- [ ] **Prod erişimi kısıtlı + audit** — Kim ne zaman deploy etti loglu; prod'a erişim sınırlı.
- [ ] **Prod deploy onayı** — Prod'a manuel onay/gate (opsiyonel, kritik sistemlerde önerilir).

### Konfigürasyon (prod)
- [ ] **Env secret manager'da** — Prod env'i güvenli sakla, koda gömme.
- [ ] **Debug kapalı + prod cache** — Debug mode kapalı; framework prod cache'leri (ör. config/route/view cache).
- [ ] **Opcache aktif** *(PHP ise)*.
- [ ] **Maintenance mode** — Bakımda düzgün ekran (ör. `php artisan down` / bakım sayfası).

### Servisler & Süreç
- [ ] **Process manager** — Uzun süreçleri/worker'ı PM2/Supervisor/systemd ile yönet (çökerse restart).
- [ ] **Queue worker / daemon ayakta** — Deploy sonrası restart edildi mi.
- [ ] **Reverse proxy** — nginx vb. ile TLS termination, gzip, static serve.
- [ ] **Resource limit** — İşlem/konteyner CPU/RAM sınırı.
- [ ] **Scaling** — Yatay/dikey ölçek planı.
- [ ] **Cache warming** — Deploy sonrası kritik cache'i önceden doldur.

### Zamanlanmış İşler & Bakım
- [ ] **Cron güvenilirliği** — Zamanlanmış işler tek scheduler'dan; doğru kullanıcı/zaman dilimi.
- [ ] **Cron izleme (heartbeat)** — İş çalıştı mı izle (dead-man switch); başarısızlıkta bildirim.
- [ ] **Overlap/locking** — Aynı job üst üste binmesin (kilit/tek-instance).
- [ ] **Düzenli bağımlılık denetimi** — Otomatik/zamanlı audit (Dependabot / zamanlı `npm audit`/`composer audit`); güncelleme penceresi + CVE bildirimi.
- [ ] **Sertifika/anahtar süre izleme** — SSL ve diğer anahtarların süresi dolmadan uyarı.

### Ağ & Sertifika
- [ ] **Domain/DNS + TTL** — Kayıtlar doğru; geçiş öncesi TTL düşür.
- [ ] **SSL otomatik yenileme** — certbot/Let's Encrypt cron; süresi dolmasın.
- [ ] **CDN yapılandırması** — Cache kuralları + purge.

### Yedekleme & DR
- [ ] **Otomatik DB yedek** — Sunucu dışı (offsite) + şifreli.
- [ ] **Restore testi** — Yedeği geri yükleyebildiğini fiilen doğrula.
- [ ] **DR planı** — Sunucu/veri kaybında adımlar + RTO/RPO.
- [ ] **Health check/readiness probe** — LB sağlıksız instance'a trafik vermesin.
- [ ] **Monitoring + alerting** — Uptime/hata/kaynak alarmı; eşik aşımında bildirim.
- [ ] **Error tracking** — Çalışma anı hatalarını yakala+grupla+uyar (Sentry vb.).
- [ ] **APM / uptime** — Yanıt süresi/throughput/hata oranı + dış uptime kontrolü.
- [ ] **Log aggregation** — Logları merkezi topla.

---

## 10. Analitik & Ürün İzleme *(gerekiyorsa)*

> Teknik monitoring (hata/uptime/APM) DevOps'tadır; bu başlık **ürün davranışı** içindir.

- [ ] **Analytics kurulumu** — GA4 / Plausible / Matomo; sayfa + event.
- [ ] **Event / funnel tanımı** — Kritik dönüşüm adımları izleniyor.
- [ ] **Gizlilik uyumlu analytics** — Çerez onayına bağlı, IP anonimleştirme (bkz. Yasal).
- [ ] 🟡 **A/B test altyapısı** *(uygunsa)* — Varyant + ölçüm.
- [ ] 🟡 **Ürün metrikleri** *(ürün ölçeğine göre)* — Aktivasyon / retention / churn.

---

## 11. Yasal & Uyumluluk

> Bilgilendirme amaçlıdır; metinleri yayına almadan önce bir avukata / güncel mevzuata doğrulat.

### Temel
- [ ] **Gizlilik politikası** — Hangi veri, neden, ne kadar süre, kiminle.
- [ ] **Kullanım koşulları** — Hizmet kuralları, sorumluluk sınırı.
- [ ] **Çerez politikası** — Hangi çerez ne için (ayrı sayfa).
- [ ] **Çerez onayı** — Granular; zorunlu olmayan çerez default kapalı (opt-in).
- [ ] **Erişilebilirlik beyanı** — A11y taahhüdü + iletişim yolu.

### KVKK (Türkiye)
- [ ] **Aydınlatma metni** — Veri sorumlusu, işleme amacı, hukuki sebep.
- [ ] **Açık rıza** — Pazarlama vb. için ayrı, özgür iradeli onay.
- [ ] **VERBİS kaydı** — Kayıt yükümlüsüysen Sicil'e kaydol.
- [ ] **Saklama/imha politikası** — Süre dolunca silme/anonimleştirme.
- [ ] **İlgili kişi hakları** — Erişim/silme/taşınabilirlik süreci.
- [ ] **DPA** — 3. taraf veri işleyenlerle (hosting, mail, analytics) sözleşme.

### GDPR (AB kullanıcısı varsa)
- [ ] **Hukuki dayanak + rıza kaydı** — İşlemenin yasal temeli belgeli.
- [ ] **Access/erasure/portability** — Talep mekanizması.
- [ ] **Veri ihlali bildirimi** — Yetkili otoriteye bildirim süreci tanımlı.

### E-Ticaret (varsa, Türkiye)
- [ ] **Mesafeli satış sözleşmesi** — Sipariş öncesi onaylatılır.
- [ ] **Ön bilgilendirme formu** — Ürün/fiyat/teslimat/cayma bilgisi.
- [ ] **İade/cayma/iptal** — Cayma hakkı ve koşulları.
- [ ] **ETBİS kaydı** — E-ticaret sistemine kayıt.
- [ ] **Teslimat & ödeme şartları** — Açık ve erişilebilir.

### İçerik
- [ ] **3. taraf lisans uyumu** — Font/görsel/kütüphane lisansı uygun.
- [ ] **Telif/marka** — İçerik ve marka hakları net.
