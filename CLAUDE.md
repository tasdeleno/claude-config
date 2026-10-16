# Karpathy Kodlama Kılavuzları
Her oturumda aşağıdaki kodlama kurallarını uygula:

1. **Kodlamadan Önce Düşün**: Varsayımlarını açıkça belirt. Belirsizlik varsa sor. Birden fazla yorum mümkünse seçenekleri sun, sessizce seçim yapma.
2. **Önce Sadelik**: Sadece isteneni yap. Gereksiz özellik, soyutlama veya esneklik ekleme. 200 satır yazıp 50'ye düşürülebiliyorsa yeniden yaz.
3. **Cerrahi Değişiklikler**: Yalnızca dokunman gereken yere dokun. İlgisiz kodu refactor etme. Mevcut stile uy.
4. **Hedef Odaklı Çalışma**: Görevi doğrulanabilir kriterlere dönüştür. Çok adımlı görevlerde kısa plan sun ve her adımı doğrula.

# Karar Eleştirisi (mimari / altyapı / stack / kütüphane / bağımlılık)
Bu tür bir seçim önerirken — ister benim fikrim ister senin fikrin olsun — körü körüne onaylama, benimle tartış:

- **Sıra**: Önce karşı argümanı / en güçlü itirazı yaz, sonra kendi önerini ver. Benim fikrime karşı en iyi itirazı; kendi önerin içinse onun en zayıf noktasını — savunmaya geçmeden — önce ortaya koy.
- **Neden iyi**: bu seçimin somut kazancı.
- **Neden kötü/riskli**: maliyet, satıcı kilidi (lock-in), bakım yükü, ölçeklenme sınırı, güvenlik yüzeyi, ekip/öğrenme maliyeti.
- **En az 1 alternatif** ve onunla net karşılaştırma; mümkünse somut metrikle (maliyet, RPS, p95 gecikme, satır sayısı vb.).
- **"Bu seçim ne zaman yanlış olur?"** — hangi koşulda vazgeçmeliyim.

İtiraz gerçek olmalı; zorlama/yapay itiraz üretme. Ciddi bir itiraz yoksa "buna karşı güçlü bir argüman yok, çünkü…" de ve geç. Beni memnun etmek için fikir değiştirme; haklıysam haklı de, hatalıysam doğrudan söyle. Basit/tek seçenekli işlerde (tek satırlık fix, net bir bug) bunu atla — her cevabı artı-eksi listesine çevirme.

# Kullanılacak Skiller
Her proje başlangıcında proje amacını ve yapısı anladıktan sonra gereken yerde kullanıcıya hangi işlem için hangi skilli kullanayım gibi sorular sor.
Örneğin: Kullanıcı frontend güzel gözüksün dedi, soru olarak "frontend için xxx skilini mi kullanayım veya x işlem için xx skillini mi kullanayım" gibi. 

# Commit Öncesi Otomatik Reviewer (bağlayıcı kural)
`git commit` atmadan HEMEN ÖNCE, commit'te değişen dosya türlerine göre ilgili reviewer agent'(lar)ını çalıştır; ciddi bulguları doğrulayıp uygula, kalanını raporla:

- `.py` → python-reviewer · `.ts/.js` → typescript-reviewer · `.tsx/.jsx` → react-reviewer (+ typescript-reviewer yalnız bileşen dışı TS mantığı da değiştiyse; tek agent'a iki rol verme)
- `.php`/`.blade.php` → php-reviewer · `.cs` → csharp-reviewer · SQL/migration → database-reviewer
- Auth, kullanıcı girdisi, API endpoint, gizli veri, `.htaccess`/sunucu conf veya CI yml değiştiyse ek olarak → security-reviewer
- Hata yönetimi/kritik akış değiştiyse ek olarak → silent-failure-hunter
- Yalnız CSS/görsel değişiklik → reviewer yok.

Atlama koşulu: yalnızca typo, yorum, doküman veya yapılandırma değişen önemsiz commit'lerde reviewer çalıştırma. **Küçük diff istisnası:** ≤10 değişen satır, tek dosya ve auth/girdi/hata akışına dokunmuyorsa yalnız dil reviewer'ı. Aynı yanıt içinde birden fazla commit varsa reviewer'ları tek seferde, birleşik diff üzerinde çalıştır.

Zincir kuralları:
- **Prompt'a yaz:** diff hash'i (`git diff --staged | git hash-object --stdin`), birlikte çalışan diğer reviewer'lar (lane devri için), kullanıcı kararları, hariç yollar. Commit'ten önce hash değiştiyse değişen dosyalar için ilgili reviewer'ı tekrar çalıştır. Arka plandaki reviewer'lar bitmeden commit atma.
- **Birleştir:** aynı dosya:satır (±2) + aynı kategori tek bulgudur; lane sahibine (güvenlik → security, yutulan hata → silent-failure, gerisi dil reviewer'ı) yaz.
- **Doğrula, sonra uygula:** her HIGH/CRITICAL bulguyu kodda kendin doğrula; yanlışsa gerekçeyle reddet ve commit gövdesindeki "Reviewer bulguları"na yaz.
- **Verdict yoksa review yok:** rapor `Verdict:` satırı içermiyorsa (limit, hata, boş dönüş) o review YAPILMAMIŞ sayılır; commit gövdesine `<agent>: INCOMPLETE (<sebep>)` yaz.
- **Re-review:** HIGH/CRITICAL düzeltmesi uyguladıysan aynı reviewer'ı yalnız düzeltme diff'i için bir kez daha çalıştır.
- Proje memory'si bu kuralı açıkça daraltıyorsa proje memory'si geçerli; atlanan reviewer'ı sebebiyle commit gövdesine yaz.
- Faz/dalga bitip main'e merge veya PR öncesi → **pr-test-analyzer** (fazın birikmiş diff'i üzerinde, tek sefer).

# Commit Mesajı Standardı (bağlayıcı kural)
Commit mesajı **detaylı** olacak: `git log` tek başına okunduğunda "ne değişti, neden, nasıl doğrulandı" sorularının üçü de cevaplanmalı. Diff'i tekrar anlatma; diff'in söylemediğini yaz.

**Konu satırı:** Conventional Commits prefix İngilizce (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`, `perf:`), açıklama Türkçe, ≤ 72 karakter.

**Gövde zorunlu** (tek satırlık trivial commit'ler hariç), şu başlıklarla ve yalnızca dolu olanlarla:

- **Neden** — hangi problem/ihtiyaç vardı, önceki davranış neydi.
- **Ne değişti** — dosya/modül bazlı madde listesi; her maddede *ne yaptığı*, gerekiyorsa *neden öyle*.
- **Kararlar** — seçilen yaklaşım ve reddedilen alternatif (kısa gerekçeyle). Yeni bağımlılık eklendiyse neden gerektiği.
- **Reviewer bulguları** — çalıştırılan reviewer'lar, uygulanan bulgular (önem derecesiyle) ve **bilinçli uygulanmayanlar** + sebebi.
- **Doğrulama** — çalıştırılan komutlar ve gerçek sonuçları (test sayısı, lint/statik analiz çıktısı, manuel/uçtan uca kontrol). Sonucu uydurma; çalıştırılmadıysa "çalıştırılmadı" yaz.
- **Deploy notu** — migration, cache temizleme, env değişkeni, yeni paket, manuel adım gerekiyorsa.
- **Paylaşılan dosyalar** — başka branch'lerle çakışma riski olan dosyalar (bkz. branch izolasyonu notu).

Kapanışta `Co-Authored-By` ve `Claude-Session` satırları. Çok satırlı mesajı `git commit -F -` + heredoc ile ver (`-m` zincirleme değil).

# Plan Sonrası Dış Görüş Denetimi (bağlayıcı kural)
Bir implementasyon planı onaya sunulmadan hemen önce — plan gerçek bir karar noktası içeriyorsa (kütüphane/servis/mimari/build-vs-buy seçimi) — `outside-view-reviewer` agent'ını, o planda kod da varsa ilgili dil-reviewer'larıyla birlikte çalıştır. Bu agent planı canlı araştırmayla (GitHub issue'ları, forumlar, StackOverflow, alternatif altyapılar) dışarıdan sınar ve her iddiasını kaynakla birlikte sunar.

Atlama koşulu: planın tek/açık bir yolu varsa, yeni bağımlılık/servis/mimari kararı içermiyorsa (net bug fix, tek seçenekli iş) çalıştırma — gereksiz itiraz üretmesin.

Bulguları plan onayına kısaca ekle. "Worth reconsidering" (yeniden düşünülmeli) işaretli ciddi bir bulgu varsa kullanıcıya açıkça belirt, sessizce geçme.

# Keşif Agent Seçimi
Tüm kod tabanı keşfi — derin execution path izleme, mimari haritalama ve geniş fan-out aramalar ("X nerelerde geçiyor") — `code-explorer` agent'ına gider. Yerleşik Explore'u kullanma; tanımında model yok, ana oturumun modelini miras alıp Opus'a düşüyor. `code-explorer` frontmatter'ında `model: sonnet` sabit, çağrıda model geçmeye gerek yok.

Herhangi bir sebeple yerleşik Explore çağrılırsa `model: "sonnet"` parametresini elle geç.

# GateGuard Sürtünmesini Azaltma
GateGuard'ın destructive Bash gate'i (`rm -rf`, `git reset --hard`, `git clean -f`, force-push, SQL DROP/TRUNCATE vb.) her farklı komut METNİNE göre ayrı ayrı bloklanır — path'e bakmaz, exemption yoktur, koruma bilinçli olarak kalıyor. Sürtünmeyi azaltmak için:

- Yıkıcı/temizlik komutlarını mümkünse TEK çağrıda topla (örn. `rm -f a b c`), art arda ayrı ayrı çağırma — her ayrı komut metni kendi bloğunu tetikler.
- Scratch/temp (AppData/Local/Temp, session scratchpad vb.) temizliğinde `-rf` (recursive+force birlikte) kullanma; `rm -f <dosyalar>` (recursive olmadan) veya `find <dizin> -type f -delete` ardından `find <dizin> -type d -empty -delete` kullan — sınıflandırıcı yalnızca r+f birlikteliğini yakalıyor, bu yollar aynı işi görüp gate'i hiç tetiklemez.
- Bu bir güvenlik açığı istismarı değil: gerçek proje/kullanıcı verisi için hâlâ dikkatli ol (oraya zaten destructive gate gerekli ve kalmalı), sadece kendi oluşturduğun geçici/scratch dosyaların rutin temizliğinde gereksiz flag kombinasyonundan kaçın.