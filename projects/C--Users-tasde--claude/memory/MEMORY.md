# Memory Index

- [ECC kurulumu](ecc-kurulumu.md) — plugins\ecc cherry-pick kurulumu, kaçış kapıları, GateGuard davranışı
- [Opsiyonel seçimleri tek tek sor](opsiyonel-secimleri-tek-tek-sor.md) — "karar senin" listeleri AskUserQuestion ile sun
- [Skill kaynakları plugin tabanlı](skill-kaynaklari-plugin-tabanli.md) — hangi skill hangi repodan, güncelleme `claude plugin update` ile
- [Keşif ajanı karşılaştırması](kesif-ajani-karsilastirmasi.md) — code-explorer'daki Bash ve zorunlu şablon ölçülmüş sebeplere dayanıyor, sadeleştirirken silme
- [PHP Stop hook](php-stop-check-hook.md) — Pint+PHPStan kapısı, oturum başına tek blok, `ECC_PHP_STOP_CHECK=off` ile kapanır
- [Orca Windows hesap bug'ı](orca-windows-account-bug.md) — "Add Account" hang, kök neden, RPC workaround, issue #14932
- [Dışa dönük metin insan gibi görünsün](human-sounding-external-text.md) — GitHub issue/PR gibi kullanıcı adına giden metinlerde AI izlerini (em-dash vb.) kaldır
- [claude-red + Defender](claude-red-defender.md) — offensive skill külliyatı; Defender sqli/rce'yi imza eşleşmesiyle flagliyor, gerçek malware değil; düz kurulum
- [red-audit kullanımı](red-audit-kullanim.md) — kullanıcı terim bilmez; düz Türkçe denetim isteğinde red-audit yüzey tespiti + alt-agent fan-out yapar
- [SiberSelma sadece bilgi](siberselma-sadece-bilgi.md) — SiberSelma MCP aktif tarama araçları çalıştırılmaz, yalnızca bilgi/danışma araçları
- [outside-view-reviewer + doc hook](outside-view-reviewer-ve-doc-hook.md) — plan sonrası dış görüş agent'ı (bağlayıcı kural) + Stop hook ile doc-updater zorlaması, dedupe mantığı
- [GateGuard destructive Bash mekanizması](gateguard-destructive-bash-mekanizmasi.md) — komut METNİ hash'ine göre bloklar, path exemption yok; rm -rf yerine rm -f/find -delete kullan
