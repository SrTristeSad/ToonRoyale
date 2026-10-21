@echo off
setlocal EnableExtensions
cd /d "%~dp0"
set "ASSET_ZIP=%~1"
if not defined ASSET_ZIP (
  for %%F in ("%~dp0Tiny Swords (Free Pack)*.zip") do (
    if exist "%%~fF" set "ASSET_ZIP=%%~fF"
  )
)
if not defined ASSET_ZIP (
  echo [ARTE] Arraste seu ZIP Tiny Swords ^(Free Pack^) sobre este .bat
  echo [ARTE] Ou copie o ZIP para a pasta ToonRoyale e execute novamente.
  pause
  exit /b 1
)
if not exist "%ASSET_ZIP%" (
  echo [ERRO] ZIP nao encontrado: "%ASSET_ZIP%"
  pause
  exit /b 1
)
where node.exe >nul 2>nul
if errorlevel 1 (
  echo [ERRO] Node.js nao encontrado. Instale Node.js para importar o pacote.
  pause
  exit /b 1
)
if not exist "node_modules\adm-zip" (
  call npm install --omit=dev --no-audit --no-fund
  if errorlevel 1 (
    echo [ERRO] Nao foi possivel instalar as dependencias.
    pause
    exit /b 1
  )
)
node tools\import-tiny-swords.mjs "%ASSET_ZIP%"
if errorlevel 1 (
  pause
  exit /b 1
)
echo [OK] Tiny Swords pronto. Abra INICIAR-TOONROYALE.bat.
pause
