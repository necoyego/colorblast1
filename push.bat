@echo off
echo Git kontrol ediliyor...
if not exist .git (
    echo Git deposu olusturuluyor...
    git init
)

echo Git kimliği ayarlanıyor...
git config user.email "necoyego@example.com"
git config user.name "necoyego"

echo Dosyalar ekleniyor...
git add .
git commit -m "Automated commit for online AAB build" 2>nul

echo Remote ayarlaniyor (Kullanici: necoyego)...
git remote remove origin 2>nul
:: Kullanıcı adını URL'ye ekleyerek doğru kullanıcı ile giriş yapılmasını zorunlu kılıyoruz.
git remote add origin https://necoyego@github.com/necoyego/colorblast1.git

echo.
echo ************************************************************
echo Luften Dikkat: Birazdan bir giris ekrani acilabilir.
echo 1. GitHub kullanici adiniz: necoyego
echo 2. Sifre olarak "Personal Access Token (PAT)" kullanmaniz gerekebilir.
echo ************************************************************
echo.

echo Dosyalar gönderiliyor...
git branch -M main
git push -u origin main

echo.
echo Islem tamamlandi. Yukarida hata var mi kontrol edin.
pause
