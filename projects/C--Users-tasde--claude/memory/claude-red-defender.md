---
name: claude-red-defender
description: "claude-red offensive skill kurulumu — Defender'ın sqli/rce'yi neden flaglediği, gerçek malware olmadığı, düz kurulum gerekliliği"
metadata: 
  node_type: memory
  type: project
  originSessionId: e01fc092-ad7d-44a6-b50a-d362d3a4eeaf
  modified: 2026-09-17T14:55:31.162Z
---

SnailSploit/Claude-Red (claude-red): 78 offensive-security SKILL.md'lik referans külliyatı. Kullanıcının kendi projelerinde yetkili güvenlik denetimi için `~/.claude/skills`'e **düz** kuruldu (kategori dizini olmadan; tüm skill adları `offensive-*`).

**Windows Defender davranışı (non-obvious):** Real-Time Protection `offensive-sqli` ve `offensive-rce` SKILL.md'lerini `Backdoor:PHP/Perhetshell.A!dha` olarak işaretleyip erişimi blokluyor. Bu bir **içerik imza eşleşmesi** — dosyalar örnek PHP webshell/RCE payload *metni* içeriyor; çalışan backdoor DEĞİL. SKILL.md markdown'dır, çalıştırılmaz. İncelendi: canlı saldırgan altyapısı yok (hepsi `attacker.com`/`evil.com` placeholder), Claude'a yönelik gerçek prompt injection yok (mevcut "ignore previous instructions" satırları öğretici örnek).

**Why:** Kullanıcı "zararlı skill kurmak istemem" diye endişelendi; Defender "backdoor" dedi. Kök neden imza eşleşmesi, kompromis değil.

**How to apply:** Bu iki dosya Defender karantinası yüzünden yüklenemez. Kullanıcı KARARI (2026-09-17): sqli+rce kurulacak → sadece bu 2 skill klasörü için dar Defender exclusion (tüm skills klasörü DEĞİL, kapsam kaybını azaltmak için). Exclusion admin ister; kullanıcı yükseltilmiş PowerShell'de kendi çalıştırır. Kurulum kaynağı düzeltilmiş halde: 27 dosyaya frontmatter eklendi (#28), 18 uzun description ≤1024'e kırpıldı (#30).

**GÜNCELLEME KURALI (bağlayıcı, kullanıcı 2026-09-17):** claude-red OTOMATİK güncelleme almaz. Manuel + denetleyerek güncellenir — yeni sürüm çekmeden önce diff/içerik gözden geçirilir (offensive payload külliyatı olduğu için tedarik-zinciri/injection riski var). `git pull` veya toplu re-install ile sessizce güncelleme yapma; kullanıcı onayı + içerik denetimi şart.

İlgili: [[skill-kaynaklari-plugin-tabanli]]
