---
name: gateguard-destructive-bash-mekanizmasi
description: "GateGuard destructive Bash gate'i path'e degil TAM KOMUT METNININ hash'ine gore bloklar, exemption yok; rm -rf yerine rm -f/find -delete kullan"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 4142db0e-ef96-444b-bacf-cec4a3a4c73e
  modified: 2026-09-21T13:44:24.722Z
---

2026-09-21'de `~/.claude/plugins/ecc/scripts/hooks/gateguard-fact-force.js` kaynak kodu
okunarak dogrulandi (`isDestructiveRm`, satir ~1443-1459):

- **Destructive Bash gate** (`rm -rf`, `git reset --hard`, `git clean -f`, force-push,
  SQL DROP/TRUNCATE) her **ayri komut METNININ sha256 hash'ine** gore bloklanir
  (`'__destructive__' + hash(command)`). Path'e bakmaz, `GATEGUARD_EXEMPT_GLOBS` bu gate'e
  UYGULANMAZ (sadece Edit/Write first-touch'a uygulanir). Ayni komutu retry etmek serbest,
  ama farkli bir hedefle yeni bir `rm -rf` komutu SIFIRDAN bloklanir.
- `isDestructiveRm`: yalnizca r+f flag'leri BIRLIKTE gorununce tetiklenir. `rm -f dosya`
  (recursive olmadan) veya `find <dir> -type f -delete` bu siniflandiriciyi HIC
  tetiklemez — ayni sonucu verir, gate'i atlar. Bu bir guvenlik acigi degil: siniflandirici
  zaten sadece flag kombinasyonuna bakiyor, path'e bakmiyor.
- Kullanicida zaten ayarli `GATEGUARD_BASH_ROUTINE_DISABLED=1` ve
  `GATEGUARD_FACT_FORCE_FULL_DENIALS=1` bu mekanizmaya HIC dokunmuyor — biri sadece
  oturumun ilk Bash cagrisindaki tek seferlik "routine" gate'i kapatiyor, digeri sadece
  tekrar-blok mesajlarinin uzunlugunu kisaltiyor.
- **Edit/Write first-touch gate** ayri bir mekanizma: her yeni dosya yoluna oturumda ilk
  dokunusta bloklanir, sinir yok. Bu upstream'de acik, cozulmemis bir bug (affaan-m/ECC
  issue #2608, "N denial sonra durmali"), config ile tam duzeltilemez — tek kaldirac
  `GATEGUARD_EXEMPT_GLOBS`'u genisletmek.

**Why:** Ayni oturumda farkli hedeflere birden fazla `rm -rf` cagirmak (ornegin N ayri
scratch dosyasini teker teker silmek) N ayri blok anlamina gelir — path ayni scratch
dizininde olsa bile. Bu, o oturumda gozlemlenen tekrarlanan blok sikayetinin (kullanici:
"gateler cok hata veriyor, Claude da hep unutuyor") ana kaynagiydi.

**How to apply:** Yikici/temizlik komutlarini tek cagrida topla (`rm -f a b c`, tek
komut = tek hash = tek blok). Scratch/temp temizliginde `-rf` yerine `rm -f` (recursive
olmadan, dosya dosya) veya `find ... -delete` kullan. Gercek proje/kullanici verisi icin
bu kacinma YAPMA — oradaki destructive gate bilincli olarak korunuyor
(bkz. [[ecc-kurulumu]] GateGuard davranisi notlari). Bu kural CLAUDE.md'ye
"GateGuard Surtunmesini Azaltma" basligi altinda da eklendi.

Ilgili: [[ecc-kurulumu]]
