@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================================
rem  TELEIOS - Empaqueta todos los ejecutables DEBUG que se pueden generar en Windows
rem
rem  Uso:
rem    build-debug.bat            analiza + tests + Windows + Android
rem    build-debug.bat rapido     omite analisis y tests
rem    build-debug.bat instalar   ademas instala el APK en el telefono conectado (adb)
rem    (se pueden combinar: build-debug.bat rapido instalar)
rem
rem  Salida: dist\debug\
rem    TELEIOS-windows-debug-<fecha>.zip   (descomprimir y abrir teleios.exe)
rem    TELEIOS-android-debug-<fecha>.apk   (instalar en el telefono)
rem
rem  iOS y macOS requieren una Mac (o Codemagic). Linux requiere Linux.
rem  Web no se empaqueta: los modulos privados no corren en el navegador.
rem ============================================================================

set "ROOT=%~dp0"
set "APP=%ROOT%app"
set "DIST=%ROOT%dist\debug"
set "DEFINES=--dart-define-from-file=config/dev.json"

set "SKIP_CHECKS=0"
set "INSTALL=0"
for %%A in (%*) do (
  if /I "%%A"=="rapido" set "SKIP_CHECKS=1"
  if /I "%%A"=="instalar" set "INSTALL=1"
)

where flutter >nul 2>&1
if errorlevel 1 (
  echo [ERROR] No se encontro "flutter" en el PATH.
  exit /b 1
)

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmm"') do set "STAMP=%%i"

set "WIN_STATUS=no generado"
set "APK_STATUS=no generado"
set "FAILED=0"

pushd "%APP%"

echo.
echo === 1/4 Dependencias ===
call flutter pub get
if errorlevel 1 goto :abort

if "%SKIP_CHECKS%"=="1" (
  echo.
  echo === 2/4 Analisis y tests: OMITIDOS (modo rapido^) ===
) else (
  echo.
  echo === 2/4 Analisis y tests ===
  call flutter analyze
  if errorlevel 1 goto :abort
  call flutter test
  if errorlevel 1 goto :abort
)

if not exist "%DIST%" mkdir "%DIST%"

echo.
echo === 3/4 Windows (.exe) ===
call flutter build windows --debug %DEFINES%
if errorlevel 1 (
  set "WIN_STATUS=FALLO"
  set "FAILED=1"
) else (
  set "WIN_ZIP=%DIST%\TELEIOS-windows-debug-%STAMP%.zip"
  powershell -NoProfile -Command "Compress-Archive -Path 'build\windows\x64\runner\Debug\*' -DestinationPath '!WIN_ZIP!' -Force"
  if errorlevel 1 (
    set "WIN_STATUS=FALLO al comprimir"
    set "FAILED=1"
  ) else (
    set "WIN_STATUS=!WIN_ZIP!"
  )
)

echo.
echo === 4/4 Android (.apk) ===
call flutter build apk --debug %DEFINES%
if errorlevel 1 (
  set "APK_STATUS=FALLO"
  set "FAILED=1"
) else (
  set "APK_OUT=%DIST%\TELEIOS-android-debug-%STAMP%.apk"
  copy /Y "build\app\outputs\flutter-apk\app-debug.apk" "!APK_OUT!" >nul
  set "APK_STATUS=!APK_OUT!"
  if "%INSTALL%"=="1" call :install_apk "!APK_OUT!"
)

popd

echo.
echo ============================================================
echo  RESUMEN
echo ============================================================
echo  Windows : %WIN_STATUS%
echo  Android : %APK_STATUS%
echo  iOS/macOS/Linux: no se pueden compilar desde Windows
echo.
echo  Windows: descomprime el .zip y abre teleios.exe
echo           (las builds debug solo corren en PCs con Visual Studio;
echo            para otras PCs se necesita una build release)
echo  Android: copia el .apk al telefono y abrelo (permite "origenes desconocidos"),
echo           o usa: build-debug.bat rapido instalar
echo ============================================================

if "%FAILED%"=="1" exit /b 1
exit /b 0

:install_apk
where adb >nul 2>&1
if errorlevel 1 (
  echo [AVISO] adb no esta en el PATH; instala el APK manualmente.
  exit /b 0
)
adb get-state >nul 2>&1
if errorlevel 1 (
  echo [AVISO] No hay telefono conectado por USB con depuracion activada.
  exit /b 0
)
echo Instalando en el telefono...
adb install -r "%~1"
exit /b 0

:abort
popd
echo.
echo [ERROR] Se detuvo el proceso. Revisa el mensaje de arriba.
exit /b 1
