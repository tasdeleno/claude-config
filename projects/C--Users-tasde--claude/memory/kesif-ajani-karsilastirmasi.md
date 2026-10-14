---
name: kesif-ajani-karsilastirmasi
description: "code-explorer'ın Bash + zorunlu şablon tasarımı ölçülmüş bir Explore karşılaştırmasına dayanıyor; bu iki özellik keyfi değil"
metadata: 
  node_type: memory
  type: project
  originSessionId: df5bdaab-a8a5-49ca-b263-c81fbc512bcb
  modified: 2026-07-28T10:34:15.446Z
---

2026-07-28'de aynı görev (ECC Bash hook zinciri trace) yerleşik `Explore` ve `code-explorer` ajanlarına aynı modelle (Sonnet 5) verildi. Sonuç: token/süre farkı önemsiz (%7), ama iki ajan iki farklı sebeple ayrıştı — Explore Bash'i olduğu için iddialarını doğrulayabildi ve çeliştikleri 2 noktada haklı çıktı; code-explorer ise zorunlu şablon bölümleri (Dependencies, Key Files) yüzünden Explore'un hiç bakmadığı alanları taradı.

`agents/code-explorer.md` bu ikisinin harmanı olarak yeniden yazıldı: `tools`'a Bash eklendi, gövdeye Kanıt Kuralı + `[doğrulanmadı]` işareti + Doğrulama çıktı bölümü kondu, şablonun kapsam zorlaması korundu.

**Why:** Bash ve zorunlu şablon bölümleri kozmetik değil; her biri ölçülmüş bir hata modunu kapatıyor. Bash olmadan ajan "emin görünen ama yanlış" ifadeler üretiyor (karşılaştırma testinde 2 kez oldu), şablon olmadan bağımlılık haritası gibi bölümleri tamamen atlıyor.

**How to apply:** `agents/code-explorer.md`'yi sadeleştirirken Bash'i tools'tan çıkarma, Dependencies/Doğrulama bölümlerini şablondan silme. Yönlendirme kuralı [[ecc-kurulumu]] ile aynı yerde, `CLAUDE.md`'deki "Keşif Agent Seçimi" başlığında.
