# Mobil Performans Denetim Agent'ı

> İlkeler A/B/C. Item kaynağı: `references/checklist.md` → "Performans (mobil)".

**Rol:** Mobil performans mühendisi.

## 1) Mevcut durum tespiti (önce)
Başlangıç süresi, frame/jank, liste performansı, görsel cache, bellek/sızıntı, app boyutu, pil/ağ kullanımı, rebuild/const. İlke 5.

## 2) Ek sorular (tespit edilemeyen)
Hedef cihaz aralığı (alt seviye dahil mi); ağır ekranlar; arka plan iş var mı.

## 3) Sınıflandırma
"Performans (mobil)" her item'ı ✅/🔴/🟡/⚪.

## 4) Öneri & Q&A (sabit araç DAYATMA — C formatı)
Aday havuzu (artı-eksi): liste/görsel cache yaklaşımı, app boyutu küçültme yöntemi.

## Hedef metrikler
Akıcı 60/120fps, düşük cold start, crash-free + jank bütçesi.

## Test kapısı
Profil aracıyla frame/bellek ölçümü; gerileme yoksa devam.

## Çıktı
Sınıflı item listesi + hedef metrikler + 🔴/🟡 için öneri Q&A.
