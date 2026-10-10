# Padel Turnuva — CLAUDE.md

## Proje Özeti

**Padel Bireysel Mexicano** — tek HTML dosyasından oluşan, Firebase destekli gerçek zamanlı padel turnuva yönetim uygulaması.

- **Tek dosya mimarisi:** Tüm uygulama `index.html` içinde (HTML + Tailwind CSS + vanilla JS + Firebase ESM imports).
- **Backend:** Firebase Firestore (realtime) + Firebase Auth (anonim veya custom token).
- **Deploy:** GitHub Pages üzerinden (`push_to_github.sh` ile push, repo: `Mesut-Outlook/Padel_Turnuva`).

## Oyun Kuralları (Mexicano)

- Her maç **24 sayıda** biter.
- **23-23** olursa tie-break oynanır, sisteme **24-23** girilir.
- Kazanan takımın her oyuncusu **+5 bonus puan** alır (toplam 29 puan).

## Veri Yapısı (Firestore)

```js
{
  playersPool: [{ id, name }],           // Global oyuncu havuzu
  tournaments: [{
    id, name, court, courtCount,         // Turnuva bilgileri
    time, activePlayerIds,               // Aktif oyuncular
    rounds: [{ id, number, matches: [    // Turlar
      { id, court, team1: [pid], team2: [pid], score1, score2 }
    ]}],
    createdAt, isFinished
  }],
  currentTournamentId: string
}
```

## Temel Özellikler

| Özellik | Açıklama |
|---|---|
| Canlı sıralama tablosu | Firestore `onSnapshot` ile anlık |
| Oyuncu eşleştirme | Dinamik, puana göre dengeli (Mexicano mantığı) |
| Çok turnuva desteği | Aynı oyuncu havuzundan birden fazla turnuva |
| Son turu geri al | Tur silinebilir (onay diyaloğu ile) |
| Büyük yazı modu | `localStorage` ile kalıcı, CSS `html.large-text` (rem ölçekleme) |
| Offline yedek | `localStorage` ile `padel_mexicano_backup` |

## Geliştirme Kuralları

- **Tek dosya:** Yeni dosya oluşturma, her şey `index.html` içinde kalmalı.
- **Bağımlılık yok:** npm/build tooling kullanılmaz; düz CSS, Firebase ESM CDN.
- **Türkçe UI:** Kullanıcıya dönük tüm metinler Türkçe.
- **Mobile-first:** Viewport `max-scale=1.0, user-scalable=0`, tüm değişiklikler mobilde test edilmeli.
- **Firebase:** proje `padel-mexicano-turnuva`; config `index.html` içinde (runtime `__firebase_config` varsa o kullanılır). Kurallar sadece `artifacts/{appId}/public/data/mexicano/state` belgesini açar; anonim giriş isteğe bağlı.

## Kod Yapısı (index.html)

```
<head>        — Google Fonts, CSS token'ları (:root), rem tabanlı stiller (büyük yazı: html.large-text)
<body>        — #toast, #app (tüm ekranlar JS ile çizilir), <dialog id="confirmDialog">
<script>      — Firebase init, migrasyon, puanlama, hash yönlendirme, render fonksiyonları, olay yönetimi
```

Ekranlar (hash route): `#/` turnuvalar listesi · `#/yeni` (ve `#/yeni/kopya/<id>`) yeni turnuva ·
`#/duzenle/<id>` düzenleme · `#/t/<id>` turnuva (bitmemişse canlı skor, bitmişse özet/podyum).

Turnuvada ek alanlar: `date` (YYYY-MM-DD), `startTime` (HH:MM); `time` eski sürüm uyumu için doldurulur.

## Kritik JS Fonksiyonları

- `migrateOldData()` — eski veriyi yeni formata taşır (eski `time` metninden `date`/`startTime` çıkarır)
- `standings()` — sıralama; toplam puan, sadece kurala uygun maçlar sayılır
- `generateRound()` — Mexicano eşleştirme (puana göre #1+#N vs #2+#N-1)
- `onScoreInput()` — skor girişi; kaybedenin skoru girilince kazanan otomatik 24, anında kaydeder
- `save()` — Firestore'a yazar + lokal backup
- `render()` / `refreshLiveParts()` — tam çizim / skor yazarken odak bozmadan kısmi güncelleme

## Git & Deploy

```bash
# Manuel push
./push_to_github.sh

# GitHub Pages URL
https://mesut-outlook.github.io/Padel_Turnuva/
```

Commit mesajları Türkçe veya İngilizce olabilir; `feat:`, `fix:`, `style:`, `refactor:` prefix'leri kullanılır.
