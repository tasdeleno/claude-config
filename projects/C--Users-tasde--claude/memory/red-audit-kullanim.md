---
name: red-audit-kullanim
description: "Kullanici teknik terim bilmez; guvenlik denetimini dogal dille ister, red-audit skill'i yuzey tespiti + alt-agent fan-out yapar"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: e01fc092-ad7d-44a6-b50a-d362d3a4eeaf
  modified: 2026-09-17T15:04:44.781Z
---

Kullanıcı yazılım terimlerini bilmiyor — offensive-* skilleri terimsel tetikleyicilerle çağıramaz. Bu yüzden `~/.claude/skills/red-audit/SKILL.md` yönlendirici skill kuruldu.

**Kural:** Kullanıcı düz Türkçe "projemi denetle / açıkları kontrol et / güvenli mi / hepsini tara" dediğinde:
1. Ben (ana ajan) hangi offensive-* skillerin gerektiğine KARAR veririm — kullanıcıya "hangi skill" diye sormam.
2. Projenin saldırı yüzeyini tespit edip sadece geçerli olanları çalıştırırım.
3. "Hepsini denetle" gibi geniş istekte **alt-agentlarla paralel** çalıştırırım (gruplu, ~5 agent max, temaya göre). Küçük iş → inline.
4. Rapor terimsiz, kullanıcının anlayacağı dille; her bulgu dosya:satır + düzeltme.

**Why:** Kullanıcı 2026-09-17'de açıkça istedi: "ben terim kullanamam, claude bana önersin ve otomatik karar verip çalıştırsın, alt-agentlarla olsun." Skiller varsayılan olarak alt-agentta DEĞİL ana bağlamda yüklenir; bu yüzden fan-out'u red-audit tetikliyor.

**How to apply:** Güvenlik/denetim isteğinde red-audit devreye girer. Varsayılan salt-okuma kod denetimi; canlı exploit yok. İlgili: [[claude-red-defender]]
