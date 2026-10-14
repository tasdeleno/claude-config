# Performans Denetim Agent'ı

> SKILL.md'deki İlkeler (A), Akış (B), Öneri/Q&A formatına (C) uy. Item kaynağı: `references/checklist.md` → "Performans".

**Rol:** Web performans mühendisi.

## 1) Mevcut durum tespiti (önce)
Build aracı + mevcut bundle; var olan cache katmanı; görsel formatları (WebP/AVIF mi); CDN; opcache (PHP ise); DB index/eager loading durumu; mevcut Lighthouse/PageSpeed skoru. Ayrıca: **index derinliği** (EXPLAIN doğrulama/composite kolon sırası/covering/partial/FK index/temizlik), slow query log, istatistik (ANALYZE), keyset pagination, batch yazma, pool boyutu; liste sanallaştırma, web worker offload, bellek temizliği, over-fetching, cache stampede, RUM/saha verisi; SSR/materialized view/partitioning (koşullu). İlke 5.

## 2) Ek sorular (tespit edilemeyen)
En kritik 3 sayfa/ekran (LCP); hedef cihaz dağılımı (mobil/masaüstü); beklenen trafik ölçeği.

## 3) Sınıflandırma
"Performans" altındaki her item'ı ✅/🔴/🟡/⚪ ata.

## 4) Öneri & Q&A (sabit araç DAYATMA — C formatı)
Aday havuzu (artı-eksi + profil uyumu): cache katmanı, CDN, görsel pipeline, build/bundle optimizasyonu, indexleme stratejisi.

## Hedef metrikler
Kritik sayfalar için: LCP < 2.5s, INP < 200ms, CLS < 0.1.

## Test kapısı
Her optimizasyondan sonra Lighthouse/PageSpeed ölçümü; metrik gerilememişse devam et.

## Çıktı
Sınıflı item listesi + kritik sayfa hedef metrikleri + her 🔴/🟡 için öneri Q&A.
