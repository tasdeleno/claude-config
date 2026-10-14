---
name: mobil-checklist
description: "Mobil uygulama projelerini (Flutter / React Native / native, framework-bagimsiz) 9 baslikta denetler, planlar ve eksikleri projeye ozel gorevlere cevirir: Mimari & Platform, UI/UX, Offline & Senkron, Bildirimler, Guvenlik, Performans, Test, Store & Yayin, Izleme & Crash. Bu skill'i; kullanici bir mobil/Flutter/iOS/Android uygulamasini yayina almadan once kontrol etmek istediginde, 'mobil checklist / uygulamada neler eksik / store oncesi kontrol / mobil guvenlik / mobil performans denetimi / push - deep link - offline - certificate pinning - secure storage - crash reporting' dediginde ya da yeni bir mobil uygulama planlarken MUTLAKA kullan - 'skill' denmese bile. Turkce calisir. Web/backend tarafi icin ayri 'proje-checklist' skill'i vardir; bu skill istemci (mobil) odaklidir."
---

# Mobil Uygulama Checklist — Denetim

Bir mobil uygulamayı **9 başlıkta** denetler, planlar ve eksikleri **projeye özel** görevlere çevirir. **Framework-bağımsızdır** (Flutter / React Native / native). Backend/API için web skill'i (`proje-checklist`) kullanılır; bu skill **istemci (mobil)** odaklıdır.

Mantık: önce **mevcut durumu** tespit et → her item'ı **dört sınıfa** ayır → araç kararını audit'ten *sonra* **artı-eksili soru-cevapla** ver → yalnızca **onaylı** işi, **sıra sıra**, **test kapılarıyla** uygula.

---

## A. Çalışma İlkeleri
1. **Kod standardı** — Tüm kod `/karpathy-guidelines`'a uygun.
2. **Göreve göre skill yükleme** — İş çıktıkça ilgili skill yüklenir.
3. **Sıralı çalışma** — Aksi istenmedikçe sıra sıra.
4. **Test kapısı** — Her orta ölçekli adımdan sonra ilgili test.
5. **Önce mevcut durum** — İtemları işaretlemeden önce projede ne var tespit et.
6. **Item sınıflandırma** — Dört sınıf (aşağıda).
7. **Sabit altyapı yok** — Araç kararı audit sonrası artı-eksili Q&A ile (C).
8. **Proje bazlı ekleme** — Yeni item/öneri eklenebilir.
9. **Onaysız değişiklik yok** — Eklemeden/değiştirmeden/silmeden önce sor.

### Sınıflandırma etiketleri
- ✅ **Mevcut** · 🔴 **Kullanılması gereken** · 🟡 **Kullanılması düşünülebilir** · ⚪ **Kapsam dışı**

## B. Akış
Profil → mevcut durum tespiti → ek sorular → sınıflandırma → öneri & Q&A → onaylı + sıralı + test kapılı uygulama.

## C. Öneri & Soru-Cevap Formatı
Sabit araç dayatma. Her öneride: item, 2-3 seçenek (+başka), her seçeneğin artı/eksisi, profil uyumu gerekçesi, "hangisini istersin?" sorusu; cevabı bekle.

---

## Nasıl ilerlenir
1. Profili topla (aşağıda) — varsa atla.
2. Mevcut durum tespiti (İlke 5).
3. Hangi başlık(lar) denetlenecek sor.
4. Her başlık için ilgili agent dosyasını OKU ve uygula.
5. Item kaynağı: `references/checklist.md`.

### Başlık → agent dosyası
| Başlık(lar) | Dosya |
|---|---|
| Mimari & Platform · Offline & Senkron · Bildirimler | `references/agents/platform.md` |
| UI/UX (mobil) | `references/agents/uiux.md` |
| Güvenlik (mobil) | `references/agents/guvenlik.md` |
| Performans (mobil) | `references/agents/performans.md` |
| Test · Store & Yayın · İzleme & Crash | `references/agents/test-yayin.md` |

### Proje profili soruları (tek mesajda sor, cevap bekle)
```
1. Framework? (Flutter / React Native / native)
2. Hedef platform + min sürüm? (iOS/Android)
3. Backend/API var mı, ne?
4. Offline ihtiyacı var mı?
5. Push/bildirim gerekiyor mu?
6. Hedef pazar / diller (RTL)?
7. Kişisel veri / ödeme topluyor mu?
8. Yayın hedefi (store/beta)?
```

---

## Referans dosyaları
- `references/checklist.md` — 9 başlıklı item kaynağı.
- `references/agents/*.md` — başlık başına denetim talimatı.
