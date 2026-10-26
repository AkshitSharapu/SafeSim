@echo off
setlocal
cd /d "%~dp0"
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter is not on PATH. Open this folder in a terminal where flutter doctor works.
  pause
  exit /b 1
)
call flutter pub get
if errorlevel 1 goto failed
if not exist "web\sqlite3.wasm" goto setupdb
if not exist "web\sqflite_sw.js" goto setupdb
goto launch
:setupdb
call dart run sqflite_common_ffi_web:setup
if errorlevel 1 goto failed
if not exist "web\sqlite3.wasm" goto failed
if not exist "web\sqflite_sw.js" goto failed
:launch
echo.
echo When the server is ready, open http://localhost:7357 in your normal Chrome window.
echo Keep this terminal open. Use this same URL each time to retain worker records.
echo Unity runs separately in the Unity Editor for this review.
echo.
call flutter run -d web-server --web-hostname localhost --web-port 7357
if errorlevel 1 goto failed
exit /b 0
:failed
echo.
echo Setup or launch failed. Send the FIRST error above; do not delete browser data.
pause
exit /b 1
