@echo off
title Grid Master Puzzle - Telefon Sunucusu
echo Telefon yayini baslatiliyor, lutfen bekleyin...
echo NOT: Bu pencere acildiktan sonra Windows Guvenlik Duvari (Firewall)
echo erisim izni isterse "Izin Ver" (Allow Access) butonuna basin!
echo.
call C:\src\flutter\bin\flutter.bat run -d web-server --web-port=8080 --web-hostname=0.0.0.0
pause
