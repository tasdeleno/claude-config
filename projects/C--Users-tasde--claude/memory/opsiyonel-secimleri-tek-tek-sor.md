---
name: opsiyonel-secimleri-tek-tek-sor
description: "Kullanıcı \"karar senin\" tarzı opsiyonel listeleri düz metin yerine tek tek seçenekli soru olarak istiyor"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 8e7ca573-ab83-4f1b-aaef-20ecf190bb5d
  modified: 2026-07-23T12:40:55.816Z
---

Kullanıcı, plana "opsiyonel / karar senin" diye bıraktığım maddeleri onaylamak yerine
"tek tek sor bana, seçeyim" dedi (ECC kurulumu, 2026-07-23).

**Why:** Kullanıcı seçimleri kendisi yapmak istiyor; uzun opsiyonel listeleri okuyup plana
itiraz etmek yerine tıklanabilir seçeneklerle karar vermeyi tercih ediyor.

**How to apply:** Birden fazla opsiyonel bileşen/karar birikince bunları AskUserQuestion ile
(multiSelect, mantıklı gruplar halinde) sun; plan dosyasına "karar senin" diye bırakma.
