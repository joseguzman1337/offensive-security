# Set execution policy (choose one option)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
# OR for more restrictive:
# Set-ExecutionPolicy RemoteSigned -Force

# Enable developer mode (if needed)
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"

# Install Scoop package manager
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
irm get.scoop.sh -outfile 'install.ps1'
.\install.ps1 -RunAsAdmin -ScoopDir 'C:\Base\' -ScoopGlobalDir 'C:\Global' -NoProxy

# Set execution policy back to more secure setting
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Install winget via Scoop
scoop install winget

# Run winget upgrades
powershell -ExecutionPolicy Bypass -NoProfile -Command "& { winget upgrade --all --include-unknown --include-pinned --accept-source-agreements --disable-interactivity }"
