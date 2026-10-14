---
name: red-audit
description: "Kullanicinin KENDI projesinde ve/veya KENDI sunucusunda (VPS) uctan uca guvenlik/zafiyet denetimi yonlendiricisi. Kullanici teknik terim bilmeden dogal Turkce ile istedigi zaman devreye girer. Tetikleyiciler: 'guvenlik denetimi', 'aciklari kontrol et', 'projemi tara', 'zafiyet taramasi', 'guvenlik acigi var mi', 'projemi denetle', 'sizma testi', 'hangi guvenlik kontrollerini yapmaliyim', 'butun aciklari kontrol et', 'projem guvenli mi', 'sunucumu denetle', 'VPS guvenligi', 'security audit', 'pentest my project', 'server security check'. Bu skill projenin/sunucunun saldiri yuzeyini otomatik tespit eder, hangi offensive-* skillerin gerektigine kendisi karar verir, ilgili olanlari (gerekiyorsa alt-agentlarla paralel) calistirir ve onceliklendirilmis Turkce bir bulgu raporu uretir. Kullanicinin yetkili oldugu kendi kodu/sunucusu icin salt-okuma denetim; canli exploit calistirmaz."
---

# Red-Audit — Güvenlik Denetimi Yönlendiricisi

Kullanıcı teknik terim bilmiyor. Görevin: doğal dildeki "projemi denetle / açıkları bul" isteğini, projeye özel bir güvenlik denetimine çevirmek. Kullanıcıya hangi skilli seçeceğini SORMA — sen karar ver, sadece planı kısaca onaya sun.

## Kapsam & guardrail (önce bunu uygula)
- Yalnızca **kullanıcının kendi projesi** (mevcut çalışma dizini) denetlenir. Bu yetkilidir.
- Varsayılan: **salt-okuma kod denetimi**. Canlı bir hedefe gerçek exploit/istek gönderme. Kullanıcı açıkça bir hedef URL + yetki verirse ayrı değerlendirilir.
- **SiberSelma (`mcp__SiberSelma__*`) aktif araçlarını ÇALIŞTIRMA** — hedefe istek/tarama gönderen hiçbirini (run_nuclei_scan, run_zap_baseline, run_basic_pentest, batch_scan_attack_surface, check_tls/cors/security_headers/email_auth, find_subdomains, check_subdomain_takeover, find_exposed_secrets, analyze_*, run_*). Yalnızca **bilgi/danışma** araçları serbest: search_cyber_wiki, get_attack_techniques, get_remediation_plan, fetch_security_news. Denetimi offensive-* skilleri + yerel araçlarla yap.
- Bulguları abartma; her bulgu `dosya:satır` + neden + düzeltme içermeli.

## Sunucu (VPS) katmanı
Kullanıcı "sunucumu denetle / VPS güvenliğim" gibi bir şey isterse (kod değil, altyapı denetimi):
- `scripts/vps-audit.sh` kullanılır — Ubuntu/Debian VPS'lerde SSH config, firewall (UFW/firewalld/iptables/nftables), fail2ban/CrowdSec, başarısız girişler, sistem güncellemeleri, açık portlar, sudo logging, parola politikası, SUID dosyaları kontrol eden salt-okuma bash script'i.
- Çalıştırmadan önce **hedef sunucuyu ve kullanıcının o sunucuda yetkili olduğunu netleştir** (kendi VPS'i mi, SSH erişimi var mı). Belirsizse sor.
- Çalıştırma: `ssh <user>@<host> 'sudo bash -s' < scripts/vps-audit.sh` (script'i sunucuya kopyalamaya gerek yok, stdin'den akar). Root/sudo gerektirir; kullanıcıdan onay al.
- Script kendi raporunu basar; bunu offensive-* bulgu formatına (`önem + açıklama + düzeltme`) çevirip Adım 5'teki gibi sun.
- Proje denetimiyle karıştırma: bu katman kod değil, işletim sistemi/ağ seviyesini kontrol eder — ikisi birlikte istenebilir ama ayrı raporlanır.

## Adım 1 — Saldırı yüzeyini tespit et
Projeyi oku ve hangi açık sınıflarının GEÇERLİ olduğunu belirle:
- Stack/framework: `composer.json`, `package.json`, `requirements.txt`, `*.csproj`, framework dosyaları.
- Yüzeyler: DB sorguları (SQLi), kullanıcı girdisi→HTML (XSS), dosya yükleme, komut/shell çağrısı (RCE/command injection), template render (SSTI), `unserialize`/deserialization, auth/login/JWT/OAuth, yetkilendirme & obje erişimi (IDOR), dış istek (SSRF), XML parse (XXE), API/GraphQL endpoint'leri, redirect, iş mantığı/ödeme akışı, sırlar (`.env`, hardcoded key), bağımlılık zafiyeti, CI/CD, container/cloud config.
- Projede OLMAYAN yüzeyi denetleme (statik site → SQLi/RCE atla).

## Adım 2 — Skill eşle
Tespit edilen her yüzeyi ilgili kurulu skille bağla (`~/.claude/skills/offensive-*`), örn:
DB→`offensive-sqli` · komut/upload/deser/template→`offensive-rce`/`offensive-file-upload`/`offensive-deserialization`/`offensive-ssti` · girdi→çıktı→`offensive-xss`/`offensive-xxe`/`offensive-ssrf`/`offensive-open-redirect` · auth→`offensive-jwt`/`offensive-oauth`/`offensive-idor`/`offensive-business-logic` · API→`offensive-api-security`/`offensive-graphql` · sır/bağımlılık/pipeline→`offensive-cicd-secrets`/`offensive-supply-chain` · cloud/container→`offensive-cloud`/`offensive-k8s-attacks`/`offensive-container-escape`.

## Adım 3 — Kısa plan sun
Kullanıcıya düz Türkçe 3-6 satır: "Projende şu yüzeyleri buldum → şu kontrolleri yapacağım." Onay bekle (kullanıcı "hepsini denetle / başla" dediyse doğrudan geç).

## Adım 4 — Çalıştır (ölçekli)
- **Küçük yüzey (≤2 sınıf) → inline** yap, alt-agent açma. İlgili `offensive-*/SKILL.md`'yi oku, metodolojiyi koda uygula.
- **Geniş "hepsini denetle" → alt-agentlarla paralel fan-out**, ama **gruplu ve en fazla ~5 agent**. Yüzeyleri temaya göre grupla (örn: 1) Injection & RCE, 2) Auth & yetkilendirme, 3) Girdi/çıktı & client, 4) API & config/sır). Her alt-agent (`general-purpose`) tek gruba odaklanır; prompt'unda: ilgili `offensive-*/SKILL.md` dosyalarını oku, bu proje kodunu o metodolojiyle salt-okuma denetle, `dosya:satır + önem + düzeltme` formatında bulgu döndür. Bağımsız gruplar → tek mesajda paralel başlat.
- Yalnızca projede var olan yüzey için agent aç; boş grup için açma.

## Adım 5 — Rapor
Alt-agent bulgularını tek raporda birleştir: önem sırasına göre (Kritik→Düşük), her bulgu `dosya:satır`, kısa açıklama (terimsiz, kullanıcı anlayacak dille), ve somut düzeltme. Sonunda 1-2 cümle özet + önerilen ilk aksiyon.
