---
name: php-stop-check-hook
description: "PHP Stop hook (Pint + PHPStan) — ecc dışı kendi hook'umuz, neden var, nasıl kapatılır"
metadata: 
  node_type: memory
  type: project
  originSessionId: 1fd69c6d-7136-4d54-93f8-6c25f255b8b7
  modified: 2026-08-07T20:17:44.373Z
---

2026-08-07: `C:\Users\tasde\.claude\hooks\php-stop-check.js` yazıldı, `settings.json` →
`hooks.Stop` dizisinin **başına** kayıtlı.

**Neden:** ecc'nin `stop-format-typecheck.js`'i yalnızca JS/TS kapsıyor, `quality-gate.js` ise
fiilen no-op ve `.php`'yi hiç tanımıyor (bkz. [[ecc-kurulumu]]). Laravel projelerinde otomatik
hiçbir doğrulama kapısı yoktu.

**Ne yapıyor:** cwd'den yukarı `vendor/bin/pint` arar (yoksa sessiz çıkar) → git'e göre değişmiş
+ untracked `.php` dosyalarını toplar (max 50) → `pint --dirty` ile sessizce formatlar →
`phpstan.neon` varsa yalnızca o dosyalarda `phpstan analyse` çalıştırır → hata varsa
`{"decision":"block"}` döner.

**Kritik tasarım kararları:**
- Blok **oturum başına en fazla bir kez** (`~/.claude/.php-stop-check/<session_id>.txt` marker).
  Legacy hataları olan bir repoda kalıcı döngüyü bu engelliyor. `stop_hook_active` de kontrol edilir.
- Pint sonucu **blok sebebi değil** — formatlama sessizce düzeltilir.
- Her hata fail-open: exception → stderr uyarısı, exit 0.
- PHPStan bazı projelerde `--error-format=raw`'ı yok sayıp JSON döner; `parseErrors()` ikisini de
  ele alır (yoksa hata sayısı hep "1" görünüyordu — bu gerçek bir bugdı, düzeltildi).

**Kapatma:** `ECC_PHP_STOP_CHECK=off`.

**Doğrulandı (2026-08-07):** ManeviRotaTurrizmLandingPage'de kasıtlı hatalı geçici dosyayla
test edildi — blokladı, 2. çalıştırmada bloklamadı, PHP olmayan dizinde sessiz geçti.
Geçici dosya ve state silindi, tree temiz.
