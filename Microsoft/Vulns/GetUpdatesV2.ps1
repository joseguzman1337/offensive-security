# First, ensure the 'choco' command actually exists
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey is not installed on this machine. Please run the installer." -ForegroundColor Red
    # Exit the script if choco isn't installed
    return
}

Write-Host "Checking for outdated Chocolatey packages..." -ForegroundColor Yellow

# Run 'choco outdated'. We use --limit-output to get a clean exit code.
choco outdated --limit-output

# choco outdated has specific exit codes:
# 0 = No outdated packages found
# 2 = Outdated packages were found
if ($LASTEXITCODE -eq 2) {
    Write-Host "Outdated packages found. Starting upgrade..." -ForegroundColor Green
    # The --ignore-checksums flag is a security risk and should be avoided
    # unless you are in a controlled environment and trust your sources completely.
    choco upgrade all -y
} else {
    Write-Host "All packages are up to date. Nothing to do. ✅" -ForegroundColor Green
}

# Display installed Chocolatey packages
Write-Host "`n--- Installed Chocolatey Packages ---`n" -ForegroundColor Green
choco list

# Display installed Scoop packages
Write-Host "`n--- Installed Scoop Packages ---`n" -ForegroundColor Cyan
scoop list
