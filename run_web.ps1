<#
.SYNOPSIS
    VIORA Maison de Beauté - Flutter Web Runner
.DESCRIPTION
    Launches the Flutter Web application with Chrome/Edge target and Firebase services.
#>

Write-Host "========================================================" -ForegroundColor DarkYellow
Write-Host "      VIORA Maison de Beauté - Flutter Web Runner" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor DarkYellow

$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue

if (-not $flutterCmd) {
    $searchPaths = @(
        "C:\flutter\bin",
        "$env:USERPROFILE\flutter\bin",
        "$env:LOCALAPPDATA\flutter\bin",
        "C:\src\flutter\bin"
    )

    # Version compatible search for C:\flutter*
    $versionedPaths = Get-ChildItem -Path "C:\" -Filter "flutter*" -Directory -ErrorAction SilentlyContinue | ForEach-Object { "$($_.FullName)\flutter\bin", "$($_.FullName)\bin" }
    if ($versionedPaths) {
        $searchPaths += $versionedPaths
    }

    foreach ($p in $searchPaths) {
        if (Test-Path "$p\flutter.bat") {
            $env:PATH = "$p;" + $env:PATH
            Write-Host "[INFO] Detected Flutter at $p" -ForegroundColor Green
            $flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
            break
        }
    }
}

if (-not $flutterCmd) {
    Write-Warning "Flutter SDK not found in PATH or standard directories."
    Write-Host "Install Flutter: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Cyan
    Write-Host "Or launch this project in Antigravity IDE: antigravity-ide C:\Users\agnes\.gemini\antigravity\scratch\maison_salon_app" -ForegroundColor Magenta
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "[1/2] Resolving dependencies..." -ForegroundColor Cyan
flutter pub get

Write-Host "[2/2] Launching on Flutter Web..." -ForegroundColor Cyan
flutter run -d chrome --web-port 8080 --web-renderer canvaskit