## Create NetHunter Installer

Tested 24 August 2023

Kali GNU/Linux Rolling | 2023.3.5

Linux kali 4.19.215-PrimeKernel v8.5 #1 SMP PREEMPT Mon Jul 17 11:16:15 CST 2023 aarch64

Packages: 5558 (dpkg)

Space Required = 73 GB

Storage Capacity Recommended = 256 GB or 128 GB minimum


## 1. Download from here 

https://www.kali.org/get-kali/#kali-mobile

The NetHunter Lite ARM64 (Full) and flash it as a module with Magisk


## 2. Upgrade Kali Linux Nethunter

```
apt-get autoclean && apt install -f && apt install aptitude -y && apt install neofetch -y && apt -f install && apt autoremove -y && apt-get clean cache && apt update && apt-get autoclean && apt-get clean cache && apt update -y && apt full-upgrade -y --allow-downgrades && dpkg --configure -a && grub-mkconfig && cd && aptitude upgrade --full-resolver -y && apt autoremove -y && neofetch
```

## 3. Activate Kali Linux Nethunter Ninja


```ShellSession
echo -ne "\033]0;Updating\007" && clear;apt update && apt install kali-linux-nethunter kali-linux-labs kali-tools-top10 kali-linux-default kali-linux-large kali-linux-everything kali-linux-arm kali-desktop-core kali-desktop-gnome kali-desktop-lxde kali-desktop-xfce kali-tools-802-11 kali-tools-bluetooth kali-tools-crypto-stego kali-tools-database kali-tools-forensics kali-tools-fuzzing kali-tools-gpu kali-tools-hardware kali-tools-information-gathering kali-tools-passwords kali-tools-post-exploitation kali-tools-reporting kali-tools-reverse-engineering kali-tools-rfid kali-tools-sdr kali-tools-sniffing-spoofing kali-tools-social-engineering kali-tools-voip kali-tools-vulnerability kali-tools-web kali-tools-windows-resources kali-tools-wireless kali-linux-firmware gnome-theme-kali hollywood-activate i3-dotfiles jalview kaboxer kali kali-desktop-i3-gaps kali-desktop-kde kali-desktop-mate kali-linux-firmware kali-root-login kali-screensaver kali-themes-purple kali-themes-mobile kali-wallpapers-mobile-2023 kali-win-kex kalibrate-rtl-dbgsym kwin-style-kali kwin-style-kali-dbgsym libskarnet2.13 linux-support-6.3.0-kali1 lokalize mkalias offsec-awae offsec-exp100 offsec-exp301 offsec-pen300 offsec-pwk php-symfony-lokalise-translation-provider rmail sirikali skalibs-dev skalibs-doc t-coffee texlive-xetex cmatrix libdrm-dev speedtest-cli -y && apt-get autoclean && apt install -f && apt install aptitude -y && apt install neofetch -y && apt -f install && apt autoremove -y && apt-get clean cache && apt update && apt-get autoclean && apt-get clean cache && apt update -y && apt full-upgrade -y --allow-downgrades && dpkg --configure -a &&  grub-mkconfig && cd && aptitude upgrade --full-resolver -y && apt autoremove -y && neofetch && apt install aptitude -y && aptitude install locales -y && locale-gen en_US.UTF-8 && localedef -i en_US -f UTF-8 en_US.UTF-8 && export LANGUAGE=en_US.UTF-8 && export LANG=en_US.UTF-8 && export LC_ALL=en_US.UTF-8 && locale-gen en_US.UTF-8 && apt-get update -y && apt-get full-upgrade -y && aptitude install wget -y && apt-get install python3 python3-venv python3-pip -y && apt-get autoclean && apt-get clean cache && apt update -y && aptitude install kali-linux-default kali-linux-everything kali-linux-large -y && apt-get full-upgrade -y && apt-get autoclean && apt install -f && apt install aptitude -y && apt install neofetch -y && apt -f install && apt autoremove -y && apt-get clean cache && apt update && apt-get autoclean && apt-get clean cache && apt update -y && apt full-upgrade -y --allow-downgrades && dpkg --configure -a && grub-mkconfig && cd && aptitude upgrade --full-resolver -y && apt autoremove -y && clear && neofetch && echo "»»»»»» Your processor architecture is=" && uname -m && echo "»»»»»» Your Kali Linux version is=" && uname -a && lsb_release -a && echo "»»»»»» Your Internet Speed is=" && speedtest-cli && echo "»»»»»» Your External Public IP is=" && dig +short myip.opendns.com @resolver1.opendns.com &&  echo "»»»»»» Your local IP addresses of all the network interfaces on your system are=" && ip a | grep "inet " | grep -v 127.0.0.1 && neofetch && echo "҉ Kali Linux NetHunter Ninja - Activated by ҉αkα x⠠⠵"
```
#
#
#

## (Optional)
### Create NetHunter Installer Manully

https://www.kali.org/docs/nethunter/building-nethunter/

https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-devices

#### Xiaomi 9T Pro aka davinci 
Code Name: raphael/raphaelin / Android 13 / Rom = Evolution X

```ShellSession
python3 build.py -d davinci-miui --ten -f -u -nf -su -fs full -r ni
```

#### Samsung Galaxy S20 FE 5G (Snapdragon or Qualcomm KONA) aka r8q 
Android 13 / Rom = ProjectX / arch = arm64 / author = Svirusx

```ShellSession
python3 build.py -d r8q-thirteen --thirteen -f -u -nf -su -fs full -r ni
```
