---
name: siberselma-sadece-bilgi
description: SiberSelma MCP aktif tarama/pentest araçları çalıştırılmaz; yalnızca bilgi/danışma araçları kullanılabilir
metadata: 
  node_type: memory
  type: feedback
  originSessionId: e01fc092-ad7d-44a6-b50a-d362d3a4eeaf
  modified: 2026-09-17T15:34:39.098Z
---

SiberSelma MCP sunucusunun (`mcp__SiberSelma__*`) **aktif/tarama araçlarını çalıştırma.** Hedefe istek gönderen veya tarama yapan hiçbiri: run_nuclei_scan, run_zap_baseline, run_basic_pentest, batch_scan_attack_surface, check_tls, check_cors, check_security_headers, check_email_auth, find_subdomains, check_subdomain_takeover, find_exposed_secrets, check_dependencies, check_breach, check_threat, check_history, analyze_project_vulnerabilities, analyze_llm_app, generate_security_report.

**Serbest (yalnızca bilgi/danışma):** search_cyber_wiki, get_attack_techniques, get_remediation_plan, fetch_security_news.

**Why:** Kullanıcı 2026-09-17'de red-audit bir güvenlik denetimi sırasında SiberSelma'yı çalıştırmaya kalkınca açıkça "bir daha kullanmasın, sadece bilgisine başvursun" dedi. Denetim offensive-* skilleri + yerel araçlarla yapılmalı, SiberSelma sadece referans.

**How to apply:** Her güvenlik/denetim işinde geçerli; red-audit skill'inin guardrail'ine de işlendi. İlgili: [[red-audit-kullanim]]
