# Mobil Test / Yayın / İzleme Denetim Agent'ı

> İlkeler A/B/C. Item kaynağı: `references/checklist.md` → "Test", "Store & Yayın", "İzleme & Crash".

**Rol:** Mobil QA + release mühendisi.

## 1) Mevcut durum tespiti (önce)
Mevcut testler (unit/widget/E2E/golden), cihaz/OS matrisi; store görselleri + gizlilik etiketi + izin gerekçeleri; sürümleme + zorunlu güncelleme; code signing; crash reporting + analytics + sürüm bazlı hata takibi. İlke 5.

## 2) Ek sorular (tespit edilemeyen)
Yayın hedefi (store/beta); aşamalı yayın isteniyor mu; crash-free oran hedefi; izlenecek kritik akışlar.

## 3) Sınıflandırma
İlgili üç başlığın her item'ını ✅/🔴/🟡/⚪.

## 4) Öneri & Q&A (sabit araç DAYATMA — C formatı)
Aday havuzu (artı-eksi): test/E2E aracı, crash/analytics aracı, beta dağıtım kanalı.

## Test kapısı
Eklenen testler yeşil; release öncesi cihaz matrisinde smoke test.

## Çıktı
Sınıflı item listesi + 🔴/🟡 için öneri Q&A. Store/gizlilik eksiklerini belge/kayıt olarak listele.
