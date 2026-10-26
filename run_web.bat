@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo       VIORA Maison de Beaute - Flutter Web Launcher
echo ========================================================
echo.

where flutter >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [INFO] Found Flutter SDK in PATH.
    goto RUN_FLUTTER
)

REM Check common installation directories
if exist "C:\flutter\bin\flutter.bat" (
    set "PATH=C:\flutter\bin;%PATH%"
    echo [INFO] Found Flutter SDK at C:\flutter\bin
    goto RUN_FLUTTER
)
if exist "%USERPROFILE%\flutter\bin\flutter.bat" (
    set "PATH=%USERPROFILE%\flutter\bin;%PATH%"
    echo [INFO] Found Flutter SDK at %USERPROFILE%\flutter\bin
    goto RUN_FLUTTER
)
if exist "%LOCALAPPDATA%\flutter\bin\flutter.bat" (
    set "PATH=%LOCALAPPDATA%\flutter\bin;%PATH%"
    echo [INFO] Found Flutter SDK at %LOCALAPPDATA%\flutter\bin
    goto RUN_FLUTTER
)
if exist "C:\src\flutter\bin\flutter.bat" (
    set "PATH=C:\src\flutter\bin;%PATH%"
    echo [INFO] Found Flutter SDK at C:\src\flutter\bin
    goto RUN_FLUTTER
)

REM Version compatible search for C:\flutter*
for /d %%D in ("C:\flutter*") do (
    if exist "%%D\flutter\bin\flutter.bat" (
        set "PATH=%%D\flutter\bin;!PATH!"
        echo [INFO] Found Flutter SDK at %%D\flutter\bin
        goto RUN_FLUTTER
    )
    if exist "%%D\bin\flutter.bat" (
        set "PATH=%%D\bin;!PATH!"
        echo [INFO] Found Flutter SDK at %%D\bin
        goto RUN_FLUTTER
    )
)

echo [!] Flutter SDK was not found in PATH or standard folders.
echo     To run natively:
echo     1. Download Flutter from https://docs.flutter.dev/get-started/install/windows
echo     2. Extract to C:\flutter and add C:\flutter\bin to your System PATH.
echo.
echo     You can also open this workspace directly inside Antigravity IDE:
echo     "C:\Users\agnes\AppData\Local\Programs\Antigravity IDE\bin\antigravity-ide.cmd" "%~dp0"
echo.
pause
exit /b 1

:RUN_FLUTTER
echo [1/3] Getting Flutter dependencies...
call flutter pub get
if %ERRORLEVEL% neq 0 (
    echo [!] flutter pub get failed. Please review error above.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [2/3] Launching VIORA on Flutter Web (Chrome)...
echo [INFO] Running on http://localhost:8080 with Firebase reactive layer active.
call flutter run -d chrome --web-port 8080 --web-renderer canvaskit

pause