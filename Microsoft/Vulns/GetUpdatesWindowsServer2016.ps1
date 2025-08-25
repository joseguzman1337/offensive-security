#Requires -RunAsAdministrator

# === Configuration ===
$ScoopDir = 'C:\Base\'
$ScoopGlobalDir = 'C:\Global'

# === Execution Policy (Temporary) ===
Write-Host "Setting execution policy..." -ForegroundColor Yellow
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# === Enable Developer Mode ===
Write-Host "Enabling developer mode..." -ForegroundColor Yellow
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1" 2>$null

# === Install Scoop ===
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    try {
        Write-Host "Installing Scoop package manager..." -ForegroundColor Yellow
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-RestMethod get.scoop.sh -OutFile 'install.ps1'
        .\install.ps1 -RunAsAdmin -ScoopDir $ScoopDir -ScoopGlobalDir $ScoopGlobalDir -NoProxy
    }
    catch {
        Write-Error "Scoop installation failed: $_"
    }
    finally {
        Remove-Item 'install.ps1' -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "Scoop is already installed." -ForegroundColor Green
}

# === Reset Execution Policy (Security Hardening) ===
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# === Install Winget via Scoop ===
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Installing winget via Scoop..." -ForegroundColor Yellow
    scoop install winget
    
    # Refresh PATH to ensure winget is available
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Host "Winget is already installed." -ForegroundColor Green
}

# === Winget Upgrades ===
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "Running winget upgrades..." -ForegroundColor Yellow
    winget upgrade --all --include-unknown --include-pinned --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
} else {
    Write-Host "Winget not available. Skipping upgrades." -ForegroundColor Red
}

# === Chocolatey Maintenance (Conditional) ===
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "Checking Chocolatey packages..." -ForegroundColor Yellow
    choco outdated --limit-output
    
    if ($LASTEXITCODE -eq 2) {
        Write-Host "Outdated packages found. Starting upgrade..." -ForegroundColor Green
        choco upgrade all -y
    } else {
        Write-Host "All Chocolatey packages are up to date. ✅" -ForegroundColor Green
    }
    
    Write-Host "`n--- Chocolatey Packages ---" -ForegroundColor Green
    choco list -l
} else {
    Write-Host "Skipping Chocolatey (not installed)" -ForegroundColor Yellow
}

# === Scoop Packages List ===
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "`n--- Scoop Packages ---" -ForegroundColor Cyan
    scoop list
} else {
    Write-Host "Skipping Scoop package list (Scoop not available)" -ForegroundColor Red
}

Write-Host "`nScript completed!" -ForegroundColor Green
