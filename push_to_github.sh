#!/bin/bash
# Padel Turnuva Tablo GitHub Push Script

clear
echo "======================================================"
echo "🎾 PADEL MEXICANO GITHUB YÜKLEME YARDIMCISI 🚀"
echo "======================================================"
echo ""

# Dizin kontrolü
cd "$(dirname "$0")"

# 1. Git Kurulum Kontrolü
if ! command -v git &> /dev/null
then
    echo "❌ HATA: Bilgisayarınızda Git yüklü görünmüyor."
    echo "Lütfen bu terminali kapatıp kendi sisteminizde şu komutla Git'i kurun:"
    echo ""
    echo "   sudo apt-get update && sudo apt-get install -y git"
    echo ""
    echo "Git kurulduktan sonra bu betiği tekrar çalıştırabilirsiniz."
    exit 1
fi

echo "✅ Git kurulu."

# 2. Git Deposunu Hazırlama
if [ ! -d ".git" ]; then
    echo "🔧 Git deposu bu klasörde başlatılmamış. Başlatılıyor..."
    git init
    git branch -M main
fi

# 3. Uzak Depoyu Tanımlama (Remote Origin)
echo "🔗 GitHub uzak depo bağlantısı kuruluyor..."
git remote remove origin 2>/dev/null
git remote add origin https://github.com/Mesut-Outlook/Padel_Turnuva.git

# 4. Değişiklikleri Taahhüt Etme (Commit)
echo "📝 Dosyalar sahneleniyor..."
git add index.html push_to_github.sh

echo "💾 Değişiklikler commit ediliyor..."
git commit -m "feat: turnuva yönetimi, oyuncu havuzu, kort saati bilgileri ve premium arayüz güncellemesi"

# 5. Push (GitHub'a Yükleme)
echo ""
echo "------------------------------------------------------"
echo "💡 ÖNEMLİ BİLGİ:"
echo "GitHub'a yükleme yapabilmek için birazdan sorulacak şifre kısmında"
echo "GitHub ana şifreniz yerine 'Personal Access Token (PAT)' girmelisiniz."
echo "GitHub artık normal şifreleri push işlemlerinde kabul etmemektedir."
echo "Token'ınız yoksa: GitHub -> Settings -> Developer Settings -> Personal Access Tokens"
echo "yolunu izleyerek 'repo' yetkili bir token üretebilirsiniz."
echo "------------------------------------------------------"
echo ""

echo "🚀 GitHub deposuna yükleniyor (git push)..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "======================================================"
    echo "🎉 TEBRİKLER! Kodlarınız başarıyla GitHub'a yüklendi!"
    echo "🔗 https://github.com/Mesut-Outlook/Padel_Turnuva"
    echo "======================================================"
else
    echo ""
    echo "❌ YÜKLEME BAŞARISIZ!"
    echo "Lütfen GitHub kullanıcı adınızı veya Token şifrenizi kontrol edip tekrar deneyin."
fi
