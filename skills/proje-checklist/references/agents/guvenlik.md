# Güvenlik Denetim Agent'ı

> SKILL.md'deki İlkeler (A), Akış (B), Öneri/Q&A formatına (C) uy. Item kaynağı: `references/checklist.md` → "Güvenlik".

**Rol:** Uygulama güvenliği uzmanı.

## 1) Mevcut durum tespiti (önce)
HTTPS/SSL; security header'lar; `.env`/secrets'ın repo ve **git GEÇMİŞİ** durumu; auth + 2FA; **oturum yönetimi** (timeout/logout geçersizleştirme/eşzamanlı/oturum deposu); **şifreleme** (transit/at-rest/field-level/anahtar yönetimi); rate limit; CORS; bağımlılık tarama; **güvenli loglama** (yapısal/maskeleme/log injection/tamper-evident/erişim kontrolü/audit/PII yok); sunucu erişimi (SSH/firewall). Ayrıca: client/bundle sır sızıntısı, SRI, path traversal, hesap enumerasyonu, SAST/DAST (CI), security.txt; **veritabanı güvenliği** (DB ağ erişimi/least-privilege/NoSQL injection/maskeleme/DB audit); GraphQL güvenliği (koşullu). İlke 5.

## 2) Ek sorular (tespit edilemeyen)
CDN/WAF var mı; bot koruması; secrets nerede tutuluyor; hassas veri sınıfı (ödeme/sağlık/kimlik/iletişim); admin paneli halka açık URL'de mi.

## 3) Sınıflandırma
"Güvenlik" altındaki her item'ı ✅/🔴/🟡/⚪ ata.

## 4) Öneri & Q&A (sabit araç DAYATMA — C formatı)
Aday havuzu (artı-eksi + profil uyumu): WAF/CDN, bot koruması, secrets yönetimi, security header seti, şifreleme yaklaşımı, sunucu hardening, DB güvenliği yaklaşımı, güvenli loglama yığını.

## Özel kurallar
- `.env`/admin kimlik bilgisi repoda/git geçmişinde VAR MI doğrula; bulursan "rotate et, silmek yetmez" + 🔴.
- Hiçbir güvenlik ayarını sormadan değiştirme (İlke 9).

## Test kapısı
Güvenlik değişikliğinden sonra header testi (securityheaders/ZAP) + auth regresyon yeşil olmadan ilerleme.

## Çıktı
Sınıflı item listesi + her 🔴/🟡 için öneri Q&A.
