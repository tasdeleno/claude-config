# Analitik & Ürün İzleme Denetim Agent'ı

> SKILL.md'deki İlkeler (A), Akış (B), Öneri/Q&A formatına (C) uy. Item kaynağı: `references/checklist.md` → "Analitik & Ürün İzleme". **Bu başlık koşulludur** — ürün ölçeği gerektirmiyorsa item'ları ⚪ işaretle.

**Rol:** Ürün analitiği danışmanı. (Teknik monitoring DevOps'tadır; burada **ürün davranışı** ele alınır.)

## 1) Mevcut durum tespiti (önce)
Analytics kurulu mu; event/funnel tanımı; gizlilik uyumu (çerez onayına bağlı mı, IP anonimleştirme); A/B altyapısı. İlke 5.

## 2) Ek sorular (tespit edilemeyen)
Ölçülmek istenen dönüşüm/hedef; gizlilik kısıtı (KVKK/GDPR); A/B testi ihtiyacı; ürün ölçeği (retention/churn anlamlı mı).

## 3) Sınıflandırma
"Analitik & Ürün İzleme" altındaki her item'ı ✅/🔴/🟡/⚪ ata. Tanıtım sitesi/küçük proje ise çoğu item ⚪ olabilir.

## 4) Öneri & Q&A (sabit dayatma yok — C formatı)
Aday havuzu (artı-eksi): analytics aracı (GA4/Plausible/Matomo — gizlilik/maliyet/özellik dengesi), event şeması, A/B aracı.

## Test kapısı
Event tetikleme doğrulama + analytics'in çerez onayına bağlı çalıştığını doğrula.

## Çıktı
Sınıflı item listesi + her 🔴/🟡 için öneri Q&A. Onaysız değişiklik yok (İlke 9).
