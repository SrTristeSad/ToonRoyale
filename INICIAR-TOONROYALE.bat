@echo off
setlocal
cd /d "%~dp0"
set "TOON_DIR=%CD%"
set "TOONROYALE_ONLINE="
if exist "%~dp0love.exe" (
  "%~dp0love.exe" "%TOON_DIR%"
  exit /b %errorlevel%
)
if exist "%ProgramFiles%\LOVE\love.exe" (
  "%ProgramFiles%\LOVE\love.exe" "%TOON_DIR%"
  exit /b %errorlevel%
)
where love.exe >nul 2>nul
if not errorlevel 1 (
  love.exe "%TOON_DIR%"
  exit /b %errorlevel%
)
echo Instale LOVE 2D 11.5 em https://love2d.org/ para jogar.
pause
exit /b 1
