```ShellSession
Set-ExecutionPolicy Bypass -Scope Process -Force; $ProgressPreference='SilentlyContinue'; try {Import-Module PSWindowsUpdate -ErrorAction Stop} catch {Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force; Set-PSRepository -Name PSGallery -InstallationPolicy Trusted; Install-Module PSWindowsUpdate -Force; Import-Module PSWindowsUpdate}; Get-WindowsUpdate -MicrosoftUpdate -IgnoreReboot -AcceptAll
```
