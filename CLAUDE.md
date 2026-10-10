# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Proje Özeti

**Padel Bireysel Mexicano** — Firebase destekli, gerçek zamanlı padel turnuva yönetimi. Tüm uygulama tek dosyada: `index.html` (düz CSS + vanilla JS ES module + Firebase ESM CDN). Build, npm bağımlılığı veya test altyapısı yok.

- **Tek dosya:** Yeni dosya oluşturma, her şey `index.html` içinde kalır.
- **Türkçe UI:** Kullanıcıya dönük tüm metinler Türkçe.
- **Mobile-first:** Uygulama telefondan, maç sırasında kullanılıyor; dokunma hedefleri ≥44px, ölçüler `rem` (büyük yazı modu `html.large-text` kök font boyutunu büyütür).

## Komutlar

```bash
# Yerelde çalıştır (ES module olduğu için file:// değil, sunucu gerekir)
python3 -m http.server 8765        # → http://localhost:8765/

# Sözdizimi kontrolü (test altyapısı yok; inline module script'i ayıklayıp node ile kontrol et)
python3 -c "import re;s=open('index.html').read();open('/tmp/chk.mjs','w').write(re.search(r'<script type=\"module\">(.*?)</script>',s,re.S).group(1))" && node --check /tmp/chk.mjs

# Deploy: main'e push → GitHub Pages (~1 dk)
git push origin main               # veya ./push_to_github.sh "fix: mesaj"
# https://mesut-outlook.github.io/Padel_Turnuva/

# Firestore kurallarını yüklemek için (firebase-tools ~/.npm-global/bin altında kurulu)
~/.npm-global/bin/firebase deploy --only firestore:rules --project padel-mexicano-turnuva
```

**Dikkat:** Yerel sunucu da canlı Firestore'a bağlanır. Localhost'ta yapılan her skor/tur değişikliği gerçek turnuva verisine yazılır. Canlı veriye dokunmadan test etmek için `firebaseConfig`'i geçici olarak boş obje yap (uygulama yerel moda düşer) ve commitlemeden geri al.

## Oyun Kuralları ve Puanlama

- Maç **24 sayıda** biter; **23-23** olursa tie-break oynanır ve **24-23** girilir.
- Oyuncu, takımının aldığı sayı kadar puan alır; kazanan takım (24) **+5 bonus** alır → 29.
- Sıralama **toplam puana** göre (ortalama kullanılmaz — kullanıcı açıkça istemedi). Sadece kurala uygun maçlar sayılır: tam olarak bir takım 24 olmalı (`matchResult()` aksi halde `invalid` döner).
- Skor girişinde kaybedenin skoru yazılınca kazanan otomatik 24 olur (`onScoreInput()`).

## Eşleştirme (`generateRound()`)

1. tur: aktif oyuncular karıştırılır (puanlar 0). Sonraki turlar:
- Önce en az maç oynamış olanlar seçilir (dinlenen oyuncu sonraki tura öncelikli girer), sonra puana göre sıralanır.
- Takımlar `#1+#N, #2+#(N-1), …`; ardışık iki takım aynı sahada → 8 oyuncu: Saha 1 `[#1+#8] vs [#2+#7]`, Saha 2 `[#3+#6] vs [#4+#5]`.
- Saha adı `courtNames[k]`'dan gelir; sadece rakamsa `Saha N`, boşsa `Kort k+1`.

## Veri ve Senkronizasyon

Tüm durum tek bir Firestore belgesinde: `artifacts/{appId}/public/data/mexicano/state` (`appId` varsayılan `default-app-id`). Aynı yapı `localStorage['padel_mexicano_backup']`'ta yedeklenir.

```js
{
  playersPool: [{ id, name }],
  tournaments: [{
    id, name, court /* tesis */, courtCount, courtNames: [string],
    date /* YYYY-MM-DD */, startTime /* HH:MM */, time /* eski sürüm uyumu için metin */,
    activePlayerIds: [id], isFinished, createdAt,
    rounds: [{ matches: [{ court, t1p1, t1p2, t2p1, t2p2 /* {id, name} */, score1, score2 /* number|null */ }] }]
  }],
  currentTournamentId
}
```

- `save()` her değişiklikte **tüm belgeyi** `setDoc` ile yazar (son yazan kazanır; alan bazlı birleştirme yok). Firestore `undefined` kabul etmez — yeni alanlarda `''`/`null` kullan.
- `onSnapshot` gelen veriyi `migrateOldData()`'dan geçirir; eski formatları (tek turnuvalı yapı, `time` metni → `date/startTime`) yerinde taşır. Yeni alan eklerken varsayılanını burada ver.
- Belge yoksa ilk bağlanan cihaz kendi `localStorage` yedeğini buluta yükler.
- Firebase'e bağlanılamazsa `goOffline()` → yalnızca `localStorage` ile çalışır ("Yerel" rozeti).
- Firestore kuralları (repoda değil, CLI ile yüklü): sadece yukarıdaki belge okunabilir/yazılabilir; yazma `playersPool` ve `tournaments` anahtarlarını içermeli. Anonim giriş Firebase'de açık değil; kod girişi dener, başarısız olursa oturumsuz devam eder. Yani linki bilen herkes yazabilir.

## Arayüz Mimarisi (`index.html` içindeki script)

- **Hash yönlendirme** (`route()`): `#/` liste · `#/yeni`, `#/yeni/kopya/<id>` yeni turnuva · `#/duzenle/<id>` düzenleme · `#/t/<id>` turnuva (bitmemişse canlı skor `renderLive()`, bitmişse özet/podyum `renderSummary()`).
- **Çizim:** `render()` aktif ekranın HTML string'ini `#app`'e basar ve odaktaki input'u/imleci geri yükler. Kullanıcı verisi (isimler) HTML'e her zaman `esc()` ile girer.
- **Olaylar:** `#app` üzerinde tek `click`/`input`/`change` dinleyicisi; butonlar `data-action="..."` ile yönlendirilir (switch bloğu).
- **Skor yazarken tam çizim yapılmaz:** mobilde klavye kapanmasın diye `refreshLiveParts()` sadece sıralama tablosunu, maç kartı sınıflarını (`paintMatch()`), sayaç ve sonraki tur butonunu günceller. Uzaktan gelen snapshot da odak bir skor kutusundaysa aynı yolu kullanır. Tam `render()` sonrası `paintAll()` çağrılmalı (kazanan/hata görünümü CSS sınıflarıyla verilir).
- Form durumu modül değişkeni `form`'da tutulur; metin input'ları yeniden çizim tetiklemez, yapı değiştiren aksiyonlar (saha sayısı, oyuncu seçimi) tetikler.
- Onaylar `<dialog id="confirmDialog">` ile (`askConfirm()`), bildirimler `showToast()` ile; `alert/confirm` kullanılmaz.
- Renkler `:root` CSS token'larında: antrasit zemin + tek vurgu rengi padel topu limonu (`--lime`). Mor/indigo "AI görünümü" paletinden kaçınılması istendi.

## Git

Commit mesajları Türkçe veya İngilizce; `feat:`, `fix:`, `style:`, `refactor:`, `chore:` önekleri. `push_to_github.sh` sadece `index.html` ve kendisini stage'ler.
