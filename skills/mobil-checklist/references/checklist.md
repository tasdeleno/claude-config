# Mobil Uygulama Checklist (Detaylı)

> Framework-**bağımsız** (Flutter / React Native / native). Parantez içi araçlar örnektir.
> Her madde: **terim** — ne / neden / nasıl. `[ ]` → `[x]`. 9 başlık.
> Backend/API tarafı için web skill'i (`proje-checklist`) kullanılır; bu skill **istemci (mobil)** odaklıdır.

---

## 1. Mimari & Platform
- [ ] **Hedef platform + min sürüm** — iOS/Android/ikisi; desteklenen en düşük OS belirli.
- [ ] **State management** — Öngörülebilir, test edilebilir yaklaşım.
- [ ] **Navigasyon yapısı** — Tutarlı route/derin bağlantı uyumlu yapı.
- [ ] **Katman ayrımı / DI** — UI / domain / data ayrımı; bağımlılık enjeksiyonu.
- [ ] **Ortam ayrımı (flavor/scheme)** — dev/staging/prod ayrı yapı + endpoint + ikon.
- [ ] **Remote config / feature flag** — Yayın olmadan davranış değişimi (opsiyonel).

## 2. UI/UX (mobil)
- [ ] **Çoklu ekran + safe area** — Farklı boyut/notch/çentik; taşma yok.
- [ ] **Tema (light/dark + sistem)** — Sistem temasına uy.
- [ ] **Erişilebilirlik** — Font ölçeklenmesi, screen reader, kontrast, dokunma hedefi ≥44pt.
- [ ] **State ekranları** — Empty / loading / error / offline göstergesi.
- [ ] **Klavye yönetimi** — Input klavye altında kalmasın; scroll/resize.
- [ ] **Lokalizasyon + RTL** — Çok dilli + sağdan-sola.
- [ ] **Hareket/haptik tutarlılığı** — Animasyon ve geri bildirim tutarlı.

## 3. Offline & Senkron
- [ ] **Yerel veri deposu** — Cache/DB (ör. local DB/secure cache).
- [ ] **Offline-first / kuyruk + retry** — Bağlantı yokken işlem kuyruğa, dönünce gönder.
- [ ] **Çakışma çözümü** — Conflict resolution stratejisi.
- [ ] **Senkron durumu** — Kullanıcıya senkron/çevrimdışı bildir.
- [ ] **Optimistic update** — Anlık tepki + başarısızlıkta geri al.

## 4. Bildirimler
- [ ] **Push kurulumu** — FCM/APNs entegrasyonu.
- [ ] **İzin akışı** — İzni doğru zamanda iste; reddi zarifçe yönet.
- [ ] **Deep / universal link** — Bildirim ve dış link doğru ekrana götürsün.
- [ ] **Bildirim tercih yönetimi** — Kullanıcı türleri açıp kapatabilsin.
- [ ] **Silent/data push** — Arka plan güncelleme (opsiyonel).

## 5. Güvenlik (mobil)
- [ ] **Secure storage** — Token/sır Keychain/Keystore'da; düz dosyada değil.
- [ ] **Certificate pinning** — MITM'e karşı sunucu sertifikası sabitleme.
- [ ] **Binary'de gömülü sır yok** — API key/secret derlenen pakette açık değil.
- [ ] **Kod obfuscation** — Tersine mühendisliği zorlaştır (ör. R8 / `--obfuscate`).
- [ ] **Transport TLS** — Tüm trafik TLS; cleartext kapalı.
- [ ] **Hassas ekran koruması** — Ekran şot/kayıt engeli (ödeme/PII ekranları).
- [ ] **API anahtarı backend'de** — Gizli işlemler client yerine sunucuda/proxy.
- [ ] 🟡 **Root/jailbreak tespiti** — Yüksek riskli uygulamalarda (opsiyonel).

## 6. Performans (mobil)
- [ ] **Başlangıç süresi** — Cold/warm start ölç + iyileştir.
- [ ] **Frame/jank bütçesi** — 60/120fps; dropped frame izle.
- [ ] **Liste performansı** — Lazy/builder; uzun listede sanallaştırma.
- [ ] **Görsel cache + boyutlandırma** — Doğru çözünürlük, bellek dostu.
- [ ] **Bellek/sızıntı yönetimi** — listener/subscription/controller temizliği.
- [ ] **App boyutu** — Split/asset optimizasyonu, kullanılmayan kaynak temizliği.
- [ ] **Pil/ağ kullanımı** — Arka plan iş, polling, konum kullanımı dengeli.
- [ ] **Rebuild/const optimizasyonu** — Gereksiz yeniden çizimi azalt (ör. Flutter const).

## 7. Test
- [ ] **Unit test** — İş mantığı.
- [ ] **Widget/component test** — UI bileşenleri.
- [ ] **Integration / E2E** — Gerçek cihaz/emülatörde akış.
- [ ] **Golden / snapshot test** — Görsel regresyon.
- [ ] **Cihaz/OS matrisi** — Farklı boyut + OS sürümü.
- [ ] **Senaryo testleri** — Offline, izin reddi, derin link, düşük bellek.

## 8. Store & Yayın
- [ ] **Store görselleri** — İkon, screenshot, açıklama, kategori.
- [ ] **Gizlilik etiketi** — App Privacy (iOS) / Data Safety (Android) doğru.
- [ ] **İzin gerekçeleri** — Info.plist / Manifest açıklamaları eksiksiz.
- [ ] **Sürümleme + zorunlu güncelleme** — Versiyon + kritik güncelleme akışı.
- [ ] **Code signing / provisioning** — İmzalama + sertifika/profil yönetimi.
- [ ] **Aşamalı yayın (staged rollout)** — Kademeli + geri çekme imkânı.
- [ ] **Beta dağıtım** — TestFlight / internal testing.

## 9. İzleme & Crash
- [ ] **Crash reporting** — Crashlytics/Sentry; crash-free oran hedefi.
- [ ] **Analytics / event** — Kritik akış + dönüşüm (gizlilik uyumlu).
- [ ] **Performans izleme** — ANR, frame, başlangıç süresi.
- [ ] **Uzaktan log** — Gizlilik uyumlu (PII/secret yok).
- [ ] **Sürüm bazlı hata takibi** — Hangi sürümde ne kırıldı.
