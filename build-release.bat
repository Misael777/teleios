@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================================
rem  TELEIOS - Empaqueta los ejecutables RELEASE (para instalar en cualquier equipo)
rem
rem  Uso:
rem    build-release.bat            analiza + tests + Windows + Android
rem    build-release.bat rapido     omite analisis y tests
rem    build-release.bat instalar   ademas instala el APK en el telefono conectado (adb)
rem
rem  Salida: dist\release\
rem    TELEIOS-windows-<version>-<fecha>.zip   portable: descomprimir y abrir teleios.exe
rem    TELEIOS-android-<version>-<fecha>.apk   firmado con la llave de release
rem    symbols-<fecha>\                        para descifrar trazas de errores (no compartir)
rem
rem  Usa config/prod.json: la base de datos es distinta a la de las builds debug.
rem
rem  Primera vez: crea la llave de firma de Android en app\android\keys\.
rem  >>> RESPALDA esa carpeta y app\android\key.properties fuera del repo. <<<
rem  Sin esa llave no podras actualizar la app en los telefonos donde ya este instalada.
rem ============================================================================

set "ROOT=%~dp0"
set "APP=%ROOT%app"
set "DIST=%ROOT%dist\release"
set "DEFINES=--dart-define-from-file=config/prod.json"

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
for /f "tokens=2 delims= " %%v in ('findstr /B "version:" "%APP%\pubspec.yaml"') do set "VERSION=%%v"
set "VERSION=%VERSION:+=_b%"
set "SYMBOLS=%DIST%\symbols-%STAMP%"

set "WIN_STATUS=no generado"
set "APK_STATUS=no generado"
set "FAILED=0"

pushd "%APP%"

echo.
echo === 1/5 Llave de firma Android ===
if exist "android\key.properties" (
  echo Llave existente: android\key.properties
) else (
  call :create_keystore
  if errorlevel 1 goto :abort
)

echo.
echo === 2/5 Dependencias ===
call flutter pub get
if errorlevel 1 goto :abort

if "%SKIP_CHECKS%"=="1" (
  echo.
  echo === 3/5 Analisis y tests: OMITIDOS (modo rapido^) ===
) else (
  echo.
  echo === 3/5 Analisis y tests ===
  call flutter analyze
  if errorlevel 1 goto :abort
  call flutter test
  if errorlevel 1 goto :abort
)

if not exist "%DIST%" mkdir "%DIST%"

echo.
echo === 4/5 Windows (.exe portable) ===
call flutter build windows --release %DEFINES% --obfuscate --split-debug-info="%SYMBOLS%\windows"
if errorlevel 1 (
  set "WIN_STATUS=FALLO"
  set "FAILED=1"
) else (
  rem Runtime de Visual C++ junto al .exe (despliegue local permitido por Microsoft):
  rem asi abre en PCs que no tienen instalado el "Visual C++ Redistributable".
  for %%D in (msvcp140.dll vcruntime140.dll vcruntime140_1.dll) do (
    if exist "%SystemRoot%\System32\%%D" copy /Y "%SystemRoot%\System32\%%D" "build\windows\x64\runner\Release\" >nul
  )
  set "WIN_ZIP=%DIST%\TELEIOS-windows-%VERSION%-%STAMP%.zip"
  powershell -NoProfile -Command "Compress-Archive -Path 'build\windows\x64\runner\Release\*' -DestinationPath '!WIN_ZIP!' -Force"
  if errorlevel 1 (
    set "WIN_STATUS=FALLO al comprimir"
    set "FAILED=1"
  ) else (
    set "WIN_STATUS=!WIN_ZIP!"
  )
)

echo.
echo === 5/5 Android (.apk firmado) ===
call flutter build apk --release %DEFINES% --obfuscate --split-debug-info="%SYMBOLS%\android"
if errorlevel 1 (
  set "APK_STATUS=FALLO"
  set "FAILED=1"
) else (
  set "APK_OUT=%DIST%\TELEIOS-android-%VERSION%-%STAMP%.apk"
  copy /Y "build\app\outputs\flutter-apk\app-release.apk" "!APK_OUT!" >nul
  set "APK_STATUS=!APK_OUT!"
  if "%INSTALL%"=="1" call :install_apk "!APK_OUT!"
)

popd

echo.
echo ============================================================
echo  RESUMEN (release %VERSION%)
echo ============================================================
echo  Windows : %WIN_STATUS%
echo  Android : %APK_STATUS%
echo  Simbolos: %SYMBOLS%  (guardalos, no los compartas)
echo.
echo  Windows: descomprime el .zip en cualquier carpeta y abre teleios.exe.
echo           Windows SmartScreen puede avisar "editor desconocido" (no esta
echo           firmado con certificado): "Mas informacion" ^> "Ejecutar de todas formas".
echo  Android: si el telefono tiene instalada una version DEBUG, desinstalala antes
echo           (firmas distintas). OJO: desinstalar borra los datos de esa version.
echo ============================================================

if "%FAILED%"=="1" exit /b 1
exit /b 0

:create_keystore
where keytool >nul 2>&1
if errorlevel 1 (
  echo [ERROR] No se encontro "keytool" (viene con el JDK^). Instala un JDK 17.
  exit /b 1
)
if not exist "android\keys" mkdir "android\keys"
for /f %%p in ('powershell -NoProfile -Command "-join ((48..57)+(65..90)+(97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})"') do set "KS_PASS=%%p"
echo Creando llave de firma (RSA 4096, valida ~27 anios^)...
keytool -genkeypair -noprompt -keystore "android\keys\teleios-release.jks" -storetype PKCS12 ^
  -keyalg RSA -keysize 4096 -validity 10000 -alias teleios ^
  -storepass "!KS_PASS!" -keypass "!KS_PASS!" -dname "CN=TELEIOS, O=TELEIOS" >nul
if errorlevel 1 (
  echo [ERROR] keytool fallo al crear la llave.
  exit /b 1
)
(
  echo storePassword=!KS_PASS!
  echo keyPassword=!KS_PASS!
  echo keyAlias=teleios
  echo storeFile=keys/teleios-release.jks
) > "android\key.properties"
echo.
echo  ******************************************************************
echo  *  LLAVE CREADA: app\android\keys\teleios-release.jks            *
echo  *  y su contrasena en app\android\key.properties                 *
echo  *                                                                *
echo  *  RESPALDALAS AHORA en un lugar seguro (no en el repo).         *
echo  *  Si las pierdes, no podras actualizar la app instalada:        *
echo  *  habria que desinstalarla y se perderian los datos locales.   *
echo  ******************************************************************
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
