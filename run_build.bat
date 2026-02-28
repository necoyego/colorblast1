@echo off
echo Initializing Android platform...
call C:\src\flutter\bin\flutter.bat create --platforms android .
if %errorlevel% neq 0 (
    echo Flutter create failed!
    exit /b %errorlevel%
)
echo Building App Bundle...
call C:\src\flutter\bin\flutter.bat build appbundle
if %errorlevel% neq 0 (
    echo Flutter build failed!
    exit /b %errorlevel%
)
echo Build successful!
