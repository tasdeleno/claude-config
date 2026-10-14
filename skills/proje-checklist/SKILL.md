---
name: proje-checklist
description: "Web/app projelerini (her framework, Laravel'e ozel degil) 11 baslikta denetler, planlar ve eksikleri projeye ozel gorevlere cevirir: Planlama, UX, Frontend, Backend, Guvenlik, Performans, SEO, Test-Dogrulama, DevOps, Analitik, Yasal. Kullanici 'projede neler eksik / deploy oncesi kontrol / proje checklist / bu projeyi gozden gecir / guvenlik-performans-test-SEO denetimi' dediginde, yeni proje planlarken, ya da auth, sifreleme, oturum yonetimi, rate limiting, input validation, row-level security, database index/guvenlik, guvenli loglama, cron, CI/CD, branch duzeni, yedekleme, monitoring, dependency scanning, deployment veya KVKK/yasal uyumlulugu degerlendirirken MUTLAKA kullan - 'skill' denmese bile. Turkce calisir. Mobil uygulamalar icin ayri 'mobil-checklist' skill'i vardir."
---

# Proje Checklist — Web & Uygulama Denetimi

Bir web/app projesini **11 başlıkta** (yaşam döngüsü sırasıyla) denetler, planlar ve eksikleri **projeye özel** görevlere çevirir. **Framework-bağımsızdır** — Laravel, Node, Django, Rails vb. fark etmez; `references/checklist.md`'deki parantez içi araçlar yalnızca örnektir.

Temel mantık: önce projede neyin **zaten var olduğunu** tespit et → her item'ı projeye göre **dört sınıfa** ayır → araç/altyapı kararını audit'ten *sonra* **artı-eksili soru-cevapla** ver → yalnızca **onaylı** işi, **sıra sıra**, **test kapılarıyla** uygula.

---

## A. Çalışma İlkeleri (her zaman uygula)

1. **Kod standardı** — Üretilen tüm kod `/karpathy-guidelines`'a uygun yazılır. Kod yazmadan önce bu kılavuzu uygula.
2. **Göreve göre skill yükleme** — Skiller baştan toplu değil, iş çıktıkça o işe uygun olan yüklenir.
3. **Sıralı çalışma** — Aksi açıkça istenmedikçe işler sıra sıra, tek tek yapılır. Bir adım bitmeden sonrakine geçme.
4. **Test kapısı** — Her orta ölçekli işlemden sonra o işe uygun testler koşulur (her agent dosyasındaki "Test kapısı"). Geçmeden ilerleme.
5. **Önce mevcut durum** — İtemlar değerlendirilmeden ÖNCE projede neyin zaten var olduğu tespit edilir (kod/dizin/config/paket taraması). Mevcut durumu bilmeden item işaretleme.
6. **Item sınıflandırma** — İtemlar projeden projeye değişir. Her item dört sınıftan birine atanır (aşağıda).
7. **Sabit altyapı yok** — İtemlar için sabit servis/araç DAYATILMAZ. Araç kararı audit'ten SONRA, artı/eksili soru-cevapla verilir; seçim kullanıcınındır (bkz. C).
8. **Proje bazlı ekleme** — Checklist sabit değil; projeye özgü yeni item/öneri eklenebilir.
9. **Onaysız değişiklik yok** — Bir özelliği eklemeden/değiştirmeden/silmeden önce MUTLAKA sor. Varsayım yapma.

### Sınıflandırma etiketleri
- ✅ **Mevcut** — projede zaten var / uygulanmış
- 🔴 **Kullanılması gereken** — proje için gerekli ama eksik
- 🟡 **Kullanılması düşünülebilir** — opsiyonel / koşullu fayda
- ⚪ **Kapsam dışı** — bu projeyle uyumsuz / gereksiz

---

## B. Akış (her başlık bu sırayla)

1. **Profil** — Proje profilini bir kez topla (zaten toplanmışsa tekrar sorma).
2. **Mevcut durum tespiti** — İlgili başlıkla projede neyin zaten var olduğunu çıkar (kod/config tara; erişemediğini sor). İlke 5.
3. **Ek sorular** — Sadece tespit edilemeyen, karara etki eden bilgileri sor; cevabı bekle.
4. **Sınıflandırma** — `references/checklist.md`'deki ilgili başlığın her item'ını dört sınıfa ayır + gerekirse projeye özel item ekle.
5. **Öneri & Q&A** — 🔴/🟡 itemlar için araç seçeneklerini artı-eksisiyle sun, kullanıcıya sor, seçimini bekle (format C).
6. **Onaylı uygulama** — Yalnızca onaylanan işi yap; her değişiklik öncesi sor (İlke 9). Kod `/karpathy-guidelines` (İlke 1). Sıra sıra (İlke 3). Her orta ölçekli adımdan sonra test kapısı (İlke 4).

---

## C. Öneri & Soru-Cevap Formatı

Sabit araç dayatma — seçenek sun, gerekçele, sor. Her öneride:
- **Item / eksik:** hangi açığı kapatıyor
- **Seçenekler:** 2-3 aday + "başka bir şey" ihtimali
- **Her seçenek için Artı / Eksi:** kısa, dürüst
- **Profil uyumu:** hosting/bütçe/ölçeğe göre hangisini neden önerdiğin (seçim kullanıcının)
- **Soru:** "Hangisini tercih edersin?" — cevabı bekle, sonra uygula

**Örnek:**
> **Item:** Kuyruk altyapısı — 🔴
> - **Redis tabanlı** → + en hızlı, + izleme; − ek servis/bellek
> - **Veritabanı tabanlı** → + basit, ekstra servis yok; − yüksek yükte yavaş
> - **Yönetilen kuyruk** → + ölçeklenir, bakım yok; − maliyet + bağımlılık
> **Profil uyumu:** Tek VPS + orta trafik → Redis pratik. **Soru:** Hangisini istersin?

---

## Nasıl ilerlenir

1. **Profili topla** (aşağıdaki sorular) — zaten varsa atla.
2. **Mevcut durum tespiti** yap (İlke 5).
3. Kullanıcıya **hangi başlık(lar)ı** denetlemek istediğini sor (tek / birkaç / hepsi).
4. Seçilen **her başlık için ilgili agent dosyasını OKU** ve harfiyen uygula.
5. **Item kaynağı:** `references/checklist.md` (her başlığın detaylı item listesi).

Birden fazla başlık seçildiyse İlke 3 gereği sıra sıra: bir başlığı bitir, sonra diğerine geç.

### Başlık → agent dosyası
| Başlık | Dosya |
|---|---|
| Planlama & Gereksinimler | `references/agents/planlama.md` |
| UX & Tasarım | `references/agents/ux-tasarim.md` |
| Frontend / UI | `references/agents/frontend-ui.md` |
| Backend | `references/agents/backend.md` |
| Güvenlik | `references/agents/guvenlik.md` |
| Performans | `references/agents/performans.md` |
| SEO | `references/agents/seo.md` |
| Test & Doğrulama | `references/agents/test.md` |
| Deployment & DevOps | `references/agents/devops.md` |
| Analitik & Ürün İzleme *(koşullu)* | `references/agents/analitik.md` |
| Yasal & Uyumluluk | `references/agents/yasal.md` |

### Proje profili soruları (tek mesajda sor, cevap bekle)

```
1. Backend dili/framework + sürüm?
2. Frontend stack?
3. Veritabanı?
4. Hosting / sunucu?
5. Repo & branch yapısı?
6. Hedef pazar / kullanıcı ülkesi?
7. Kişisel veri veya ödeme topluyor mu? (ne)
8. Çok dilli mi? (diller)
9. Beklenen trafik / ölçek?
```

Sorulardan sonra (erişim varsa) proje dizinini/paket dosyalarını tara ve mevcut durumu çıkar (İlke 5). Erişim yoksa eksikleri sor. **Framework'e göre maddeleri uyarlama agent'ın işidir; bu skill yalnız Laravel için değildir.**

---

## Referans dosyaları
- `references/checklist.md` — 11 başlıklı detaylı item kaynağı (framework-bağımsız).
- `references/agents/*.md` — başlık başına denetim talimatı.
