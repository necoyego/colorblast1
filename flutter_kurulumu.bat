@echo off
title Flutter Alternatif Kurulum Araci (CMD)
color 0E
echo ===========================================================
echo = Flutter CMD Kurulum Araci (PowerShell Gerektirmez)      =
echo ===========================================================
echo.
echo 1) Flutter SDK indiriliyor... (Lutfen bekleyin, yuzdelik ilerlemeyi takip edin)
curl.exe -L -o "%USERPROFILE%\Downloads\flutter_windows.zip" "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.3-stable.zip"

echo.
echo 2) Dosyalar C:\src\ icerisine cikariliyor... (Lutfen bittigini soyleyene kadar bekleyin)
if not exist "C:\src" mkdir "C:\src"
tar.exe -xf "%USERPROFILE%\Downloads\flutter_windows.zip" -C "C:\src"

echo.
echo 3) Gecici indirme dosyalari temizleniyor...
del /q "%USERPROFILE%\Downloads\flutter_windows.zip"

echo.
echo ===========================================================
echo = KURULUM DOSYALARA BASARIYLA CIKARILDI!                  =
echo ===========================================================
echo Sisteminizi yeniden baslatmadan da oyunu test edebilirsiniz.
echo Şimdi hemen oyunu Chrome üzerinden baslatacagim...
echo.
echo Oyun derleniyor ve hazirlaniyor...
call C:\src\flutter\bin\flutter.bat pub get
call C:\src\flutter\bin\flutter.bat run -d chrome

pause
