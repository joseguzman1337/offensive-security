This guide will install and prepare your Windows for Penetration Testing, step-by-step

#

1. Close PowerShell

2. Download & Install PowerShell

   https://github.com/PowerShell/PowerShell/releases/

3. Open PowerShell as administrator

4. Allow the execution of the scripts inside of PowerShell

```bash
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
```

5. Enable Developer Mode in Windows

```bash
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"
```

6. Gets PowerShell repositories.

```bash
Get-PSRepository
```

7. Install Azure Az Module

```bash
Install-Module -Name Az -AllowClobber -Scope AllUsers
```

8. Install Visual Code & GitHub Desktop, Bash, SCM & LFS

9. Install scoop A command-line installer for Windows scoop.sh

```bash
irm get.scoop.sh -outfile 'install.ps1'
```

10. The administrator executes the installation script (change the partition as Your preference).

```bash
.\install.ps1 -RunAsAdmin -ScoopDir 'C:\Base\' -ScoopGlobalDir 'C:\Global' -NoProxy
```

#

```bash
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#

10. Open a new Powershell Windows without admin privileges and Install the DevSecOps tools

```bash
scoop install wget curl adb apktool aws-iam-authenticator aws-vault aws azure-cli azure-functions-core-tools azure-ps circleci-cli cmake cmder-full composer kompose kubectl minikube docker git lua-for-windows make maven neofetch radare2 ruby s3deploy helm terraform youtube-dl docker-compose php go grep nano winget
```

#

```bash
scoop bucket add extras
```

#

```bash
scoop update
```

11. Open PowerShell as administrator to Upgrade packages with WinGet

```bash
powershell -ExecutionPolicy Bypass -NoProfile -Command "& { winget upgrade --all  --include-unknown --include-pinned --accept-source-agreements --disable-interactivity }"
```

12. Open PowerShell as administrator to Install scoop project Pentest-Windows PST https://github.com/arch3rPro/PST-Bucket

```bash
scoop bucket add ar https://github.com/arch3rPro/PST-Bucket
```

#

Add to Windows Defender these two folders C:\Base\ & D:\Global\ to exclude from antivirus scans

#

```bash
scoop install afrog antsword av_evasion_tool behinder beroot broxy burpsuite-np ct dalfox DeimosC2 dig dirbuster dnsx ehole ffuf fscan girsh gitrob goby godzilla goproxy govenom hetty hackbrowserdata httpx hydra interactsh jar-analyzer jndinjector john-the-ripper katana kscan ksubdomain layerdomainfinder masscan mateuszex maye mdut mimikatz myexploit naabu natpass nimscan nps nuclei ObserverWard oneforall pagodo peass-ng phpenv platypus portforward PowerRun PrintNotifyPotato proguard pyxis quake_rs quasar rad rubick rustcat scan4all scaninfo screentogif shellcodeloader sliver socat subfinder suo5 super-xray termite transfer txportmap venom vscan w3cschool webpathbrute webshell_generate websocat windynamicdesktop xray yakit ysomap -g
```
