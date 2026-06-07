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
| Son turu geri al | Tur silinebilir (`deleteLastRoundBtn`) |
| Büyük yazı modu | `localStorage` ile kalıcı, CSS `body.large-text` |
| Offline yedek | `localStorage` ile `padel_mexicano_backup` |

## Geliştirme Kuralları

- **Tek dosya:** Yeni dosya oluşturma, her şey `index.html` içinde kalmalı.
- **Bağımlılık yok:** npm/build tooling kullanılmaz; Tailwind CDN, Firebase ESM CDN.
- **Türkçe UI:** Kullanıcıya dönük tüm metinler Türkçe.
- **Mobile-first:** Viewport `max-scale=1.0, user-scalable=0`, tüm değişiklikler mobilde test edilmeli.
- **Firebase config:** `__firebase_config` ve `__app_id` runtime'da inject edilir; yoksa boş obje / default değerlerle offline modda çalışır.

## Kod Yapısı (index.html)

```
<head>        — Tailwind config, Google Fonts, global CSS (large-text modu dahil)
<body>        — Toast, ana kart, liderlik tablosu, turlar, aksiyon butonları
  Modals:     — settingsModal (3 tab), confirmModal
<script>      — Firebase init, state yönetimi, render fonksiyonları, event listenerlar
```

## Kritik JS Fonksiyonları

- `migrateOldData()` — eski tek-turnuvalı veriyi yeni formata taşır
- `renderLeaderboard()` — sıralama; önce puan, eşitlikte sayı farkı
- `renderRounds()` — tur kartlarını, skor inputlarını çizer
- `generateRound()` — Mexicano eşleştirme algoritması (puana göre çiftler)
- `saveScores()` — Firestore'a yazar + lokal backup
- `applyEasyReadingMode()` — büyük yazı modunu açar/kapar

## Git & Deploy

```bash
# Manuel push
./push_to_github.sh

# GitHub Pages URL
https://mesut-outlook.github.io/Padel_Turnuva/
```

Commit mesajları Türkçe veya İngilizce olabilir; `feat:`, `fix:`, `style:`, `refactor:` prefix'leri kullanılır.
