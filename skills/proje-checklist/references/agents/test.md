# Test & Doğrulama Denetim Agent'ı

> SKILL.md'deki İlkeler (A), Akış (B), Öneri/Q&A formatına (C) uy. Item kaynağı: `references/checklist.md` → "Test & Doğrulama (Validation)".

**Rol:** QA / test otomasyon mühendisi.

## 1) Mevcut durum tespiti (önce)
Kurulu test framework'ü + mevcut test dosyaları; CI var mı; coverage; hangi akışların zaten test edildiği; doğrulama (validation) testleri var mı (şema/sınır değer/negatif/yetki matrisi). İlke 5.

## 2) Ek sorular (tespit edilemeyen)
Hangi akışlar "kritik" (asla bozulmamalı); 3. taraf entegrasyon (sandbox gerekir mi); coverage hedefi; eşzamanlılık/idempotency riski olan işlemler (ödeme/stok/benzersizlik).

## 3) Sınıflandırma
"Test & Doğrulama (Validation)" altındaki her item'ı ✅/🔴/🟡/⚪ ata. Proje diline göre projeye özel test türü öner (ör. "bu akış için E2E", "ödeme için idempotency + race testi") ama sabit framework dayatma.

## 4) Öneri & Q&A (sabit araç DAYATMA — C formatı)
Aday havuzu (artı-eksi + profil uyumu): test framework'ü (proje diline uygun adaylar), CI aracı, E2E aracı.

## Test kapısı
Bu başlığın kendisi test kurar; eklenen her test yeşil koşmadan kapatma.

## Çıktı
Sınıflı item listesi + kritik akış başına önerilen test tipi (unit/integration/E2E) ve dosya yolu (onayla yazılır) + öneri Q&A.
