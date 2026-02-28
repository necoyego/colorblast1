@echo off
chcp 65001 >nul
echo =======================================================
echo Google Play İcin Imza Dosyasi (Keystore) Olusturucu
echo =======================================================
echo.
echo Lutfen asagidaki sorulari yanitlayin.
echo Sifreyi (password) yazarken ekranda gorunmeyecektir, yazip ENTER'a basin.
echo Sifrenizi (password) LUTFEN UNUTMAYIN! (Ornek: 123456 yapabilirsiniz)
echo Diger sorulara (Isim, Sehir vs.) rastgele cevaplar verebilirsiniz.
echo.

set KEYSTORE_FILE=upload-keystore.jks
set ALIAS_NAME=upload

:: Eski dosyalari sil
if exist %KEYSTORE_FILE% del %KEYSTORE_FILE%
if exist keystore_base64.txt del keystore_base64.txt

keytool -genkey -v -keystore %KEYSTORE_FILE% -keyalg RSA -keysize 2048 -validity 10000 -alias %ALIAS_NAME%

if exist %KEYSTORE_FILE% (
    echo.
    echo Harika! %KEYSTORE_FILE% dosyasi olusturuldu.
    echo GitHub'a yukleyebilmeniz icin metne (Base64) ceviriliyor...
    
    certutil -encode %KEYSTORE_FILE% keystore_base64.txt >nul
    
    echo.
    echo =======================================================
    echo ISLEM TAMAMLANDI! LUTFEN OKUYUN:
    echo =======================================================
    echo 1. 'keystore_base64.txt' dosyasini acin.
    echo 2. Basindaki ve sonundaki eksi (----) isaretli yazilari ALMADAN
    echo    Sadece ORTADAKI karisik metin blogunu kopyalayin.
    echo.
    echo 3. GitHub deponuza gidin: Settings -^> Secrets and variables -^> Actions
    echo 4. "New repository secret" (Yeni Sir) diyerek sunlari ekleyin:
    echo.
    echo    Sir 1 -^> Name: KEYSTORE_BASE64  (Secret: kopyaladiginiz yazi)
    echo    Sir 2 -^> Name: KEY_ALIAS        (Secret: upload)
    echo    Sir 3 -^> Name: KEY_PASSWORD     (Secret: az once sectiginiz sifre)
    echo    Sir 4 -^> Name: STORE_PASSWORD   (Secret: az once sectiginiz sifre)
    echo.
    echo Sirleri ekledikten sonra bana haber verin, onaylayip kodu gonderecegiz!
    pause
) else (
    echo.
    echo Hata: Imza dosyasi olusturulamadi (keytool bulunamadi).
    pause
)
