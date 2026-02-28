@echo off
echo Git kontrol ediliyor...
if not exist .git (
    echo Git deposu olusturuluyor...
    git init
)

echo Git kimliği ayarlanıyor (Yerel)...
git config user.email "nejat@example.com"
git config user.name "Nejat"

echo Dosyalar ekleniyor...
git add .
git commit -m "Automated commit for online AAB build" 2>nul

echo Remote ayarlanıyor...
git remote remove origin 2>nul
git remote add origin https://github.com/necoyego/colorblast1.git

echo Dosyalar gönderiliyor...
git branch -M main
git push -u origin main

echo.
echo Islem tamamlandi. Yukarida hata var mi kontrol edin.
pause
