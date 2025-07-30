Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
or
Set-ExecutionPolicy RemoteSigned -Force
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"
irm get.scoop.sh -outfile 'install.ps1'
.\install.ps1 -RunAsAdmin -ScoopDir 'C:\Base\' -ScoopGlobalDir 'C:\Global' -NoProxy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
scoop install winget
winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements --disable-interactivity
