@echo off
echo Git kontrol ediliyor...
if not exist .git (
    echo Git deposu olusturuluyor...
    git init
)

echo Gereksiz dosyalar temizleniyor...
git rm --cached android/local.properties 2>nul
git rm --cached .flutter-plugins 2>nul
git rm --cached .flutter-plugins-dependencies 2>nul

echo Git kimliği ayarlanıyor...
git config user.email "necoyego@example.com"
git config user.name "necoyego"

echo Dosyalar ekleniyor...
git add .
git commit -m "Fix: Ignore newlines when decoding base64 keystore" 2>nul

echo Remote ayarlaniyor...
git remote remove origin 2>nul
git remote add origin https://necoyego@github.com/necoyego/colorblast1.git

echo Dosyalar gönderiliyor...
git branch -M main
git push -u origin main --force

echo.
echo Islem tamamlandi. GitHub Actions sayfasini yenileyin.
pause
