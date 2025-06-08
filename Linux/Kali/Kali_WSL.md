# Kali Linux WSL 2 Ninja

0.  Enable the WSL feature, executing this in Powershell as Administrator

         dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

1.  Enable the Virtual Machine feature executing this in Powershell as Administrator

         dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

2.  Download the Linux kernel update package

This package will install the most recent version of the WSL 2 Linux kernel

https://learn.microsoft.com/en-us/windows/wsl/install-manual#step-4---download-the-linux-kernel-update-package

3.  Restart the Operating System to apply the changes

4.  Set WSL version 2 as the default

         wsl --set-default-version 2

5.  Update WSL to the latest version

         wsl --update

6.  Install Kali Linux WSL from the Windows Store

https://www.microsoft.com/store/apps/9PKR34TNCV07

7.  Restart Windows Operating System to apply changes
8.  Open Kali Linux, follow the wizard for installation define your username and password, and reset the root password

         sudo -i

9.  Add this path to Windows Defender as an exception

    C:\Users\yourusername\AppData\Local\Packages\KaliLinux.\*

#

33.37 GB of free space is required on your disk. \*\*\*Repeat it until you see that it was installed successfully at 100% as root.

    sudo wget https://archive.kali.org/archive-keyring.gpg -O /usr/share/keyrings/kali-archive-keyring.gpg

#

    apt-get update -y && apt-get full-upgrade -y && apt-get install sudo wget aptitude -y && sudo apt-get autoclean && apt-get clean cache && sudo apt update -y && apt-get full-upgrade -y

#

    apt install aptitude -y && aptitude install locales -y && locale-gen en_US.UTF-8 && localedef -i en_US -f UTF-8 en_US.UTF-8 && export LANGUAGE=en_US.UTF-8 && export LANG=en_US.UTF-8 && export LC_ALL=en_US.UTF-8 && apt-get update -y && apt-get full-upgrade -y && aptitude install wget -y && apt-get install python3 python3-venv python3-pip -y && apt-get autoclean && apt-get clean cache && apt update -y && aptitude install kali-linux-default kali-linux-everything kali-linux-large -y && apt-get full-upgrade -y && apt-get autoclean && apt-get clean cache && apt update && aptitude install git screen neofetch python-is-python3 synaptic lsb-release software-properties-common zipalign curl dirmngr apt-transport-https jq php gdebi postgresql nginx hping3 hashcat openvpn synaptic caca-utils inetutils-traceroute mdbtools make libncurses5-dev module-assistant mingw-w64 pdns-tools synaptic autopsy pcsxr gir1.2-nautilus-4.0 sshfs resolvconf nmap net-tools ssh gcc python2 python3 gimp php-mbstring python3-dev cmatrix gparted compiz ndisc6 steghide httrack mesa-utils ethtool build-essential macchanger winbind wget nano file-roller p7zip-full p7zip-rar unrar zip unzip unace bzip2 lhasa jlha-utils lzip xz-utils mercurial libcanberra-pulse byzanz calibre calibre-bin expect ffmpeg fig2dev fonts-dejavu gawk ghex hexchat hexchat-common hexchat-perl hexchat-plugins hexchat-python3 hwdata inkscape libblosc1 libchm1 libdbusextended-qt5-1 libdframeworkdbus-dev libdframeworkdbus2 libfreeimage3 libgsettings-qt1 libgtkhex-4-1 libgtkspell0 libjemalloc2 libjs-coffeescript libjxr0 libmagick++-6.q16-9 libmpris-qt5-1 libmpv2 libpotrace0 libpulse-dev libqapt3 libqapt3-runtime libqt6concurrent6 libqt6designer6 libqt6help6 libqt6multimediaquick6 libqt6opengl6-dev libqt5x11extras5-dev libqt5xdg3 libqt5xdgiconloader3 libspnav0 libtidy5deb1 libtinyxml2.6.2v5 libvulkan-dev libwmf-bin libxcb-composite0 libxcb-damage0 libyaml-cpp0.8 lrzsz mpv onioncircuits optipng papirus-icon-theme polkit-kde-agent-1 scour python3-argcomplete python3-gnupg python3-progressbar python3-pycountry python3-pyxattr python3-scour python3-stem python3-xapian qt5-qmake qt5-qmake-bin qt5dxcb-plugin qtbase5-dev qtbase5-dev-tools qtmultimedia5-dev rtmpdump scour tcl-expect zssh lsdvd libdvdnav4 gdebi-core ffmpegthumbnailer gstreamer1.0-plugins-base gstreamer1.0-nice gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-alsa gstreamer1.0-pulseaudio gstreamer1.0-libav lightdm compizconfig-settings-manager compiz-plugins-extra compiz gstreamer1.0-vaapi apt-xapian-index mpg123 libldap-2.5-0 libxml2 giflib-tools libc6 gtk2-engines gcc g++ g++-multilib-mipsisa32r6-linux-gnu g++-multilib-mipsisa32r6el-linux-gnu g++-multilib-mipsel-linux-gnu g++-multilib-mips64el-linux-gnuabi64 g++-multilib-i686-linux-gnu g++-multilib-s390x-linux-gnu g++-multilib-mips64-linux-gnuabi64 g++-multilib-mipsisa64r6el-linux-gnuabi64 g++-multilib-mips-linux-gnu g++-multilib-mipsisa64r6-linux-gnuabi64 cmake lm-sensors fancontrol wine playonlinux telegram-desktop gdebi mesa-utils mesa-utils-extra  libgl1-mesa-dri libglapi-mesa libglu1-mesa mesa-vdpau-drivers uuid-runtime fonts-cantarell fonts-liberation fonts-noto fonts-stix otf-stix fonts-oflb-asana-math fonts-mathjax -y && bash <(wget -qO- https://git.io/vAtmB) && aptitude safe-upgrade -y && apt install --fix-broken && apt-get update --fix-missing && apt-get update && apt-get full-upgrade && apt-get autoremove -y && aptitude install apt-file -y && aptitude install -y && apt update -y && apt dist-upgrade -y && cd && neofetch && apt-get autoclean && apt-get clean cache && apt update && aptitude install git screen neofetch synaptic lsb-release software-properties-common curl dirmngr apt-transport-https jq nginx onioncircuits hping3 hashcat openvpn chktex clisp dvidvi dvipng lacheck latexdiff latexmk libemf1 libffcall1b libplot2c2 libpstoedit0c2a ps2eps pstoedit purifyeps xindy xindy-rules fonts-ancient-scripts fonts-symbola qml-module-qtgraphicaleffects qml-module-qtquick-controls qml-module-qtquick-dialogs qml-module-qtquick-layouts qml-module-qtquick-privatewidgets qml-module-qtquick-window2 qml-module-qtquick2 synaptic build-essential dkms gcc g++ cmake ghex snapd fancontrol wine playonlinux calibre hexchat docker-compose docker.io wmdocker vagrant inkscape libsecret-1-0 libsecret-1-dev telegram-desktop gir1.2-gtop-2.0 gir1.2-nm-1.0 asciidoc xmlto docbook2x install-info dh-autoreconf libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev wget npm nano git mercurial make pulseaudio libcanberra-pulse mpg123 libpulse0 libxml2 giflib-tools libc6 unrar p7zip p7zip-full p7zip-rar unace zip unzip bzip2 arj lhasa lzip ffmpegthumbnailer gstreamer1.0-plugins-base gstreamer1.0-nice gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-alsa gstreamer1.0-pulseaudio gstreamer1.0-libav gstreamer1.0-vaapi lsdvd libdvdnav4 compizconfig-settings-manager compiz-plugins-extra compiz gir1.2-nautilus-4.0 sshfs resolvconf nmap net-tools ssh gcc python3-dev python3-pip libesedb-utils gparted gimp steghide httrack mesa-utils ethtool macchanger python2 python3 python3-gi postgresql gimp wireshark wireshark-doc ndiff zmap hydra-gtk jython -y && cd /root && aptitude install libgdk-pixbuf2.0-0 -y && apt --fix-broken install -y && pwd && aptitude safe-upgrade -y && apt install --fix-broken && apt-get update --fix-missing && apt-get update && apt-get full-upgrade && apt-get autoremove -y && aptitude install apt-file -y && aptitude install -y && /etc/init.d/kmod start && apt update -y && apt dist-upgrade -y && dpkg --configure -a && cd && neofetch && gem install lolcat nokogiri bundle rails racc && gem pristine diff-lcs domain_name erubis httpclient rack rake rest-client rubydns term-ansicolor thin thor tilt && pip install --no-cache-dir -U crcmod && /usr/bin/python3 -m pip install --upgrade pip && apt-get autoclean && apt install -f && apt install aptitude -y && apt install neofetch && apt -f install && apt autoremove -y && apt-get clean cache && apt update && apt-get autoclean && apt-get clean cache && apt update -y && apt full-upgrade -y --allow-downgrades && dpkg --configure -a && grub-mkconfig && cd && aptitude upgrade --full-resolver -y && apt autoremove -y && neofetch

#

#

    sudo apt-get autoclean && sudo apt install -f && sudo apt install neofetch -y && sudo apt -f install && sudo apt autoremove -y && apt-get clean cache && sudo apt update && sudo apt-get autoclean && apt-get clean cache && sudo apt update && sudo apt update -y && sudo apt full-upgrade -y --allow-downgrades && cd && neofetch

#

#

## Set DNS

    rm -r /etc/resolv.conf && nano /etc/resolv.conf

#

    #
    nameserver 139.99.96.146
    nameserver 37.59.40.15
    nameserver 185.121.177.177

    # Round Robin
    options rotate

#

    sudo reboot

#

#

#

# 10. Add GUI xfce

    sudo apt install xfce4 xfce4-goodies -y && sudo apt install lightdm -y && sudo apt install xfce4 xrdp -y && echo "xfce4-session" >~/.xsession && sudo systemctl enable xrdp && sudo /etc/init.d/xrdp start && sudo systemctl start xrdp

a. Select lightdm and allow the traffic on port 3389 in your private network in the Windows firewall to grant RDP access.

b. In the Mobaxterm application, edit the "WSL-Kali" session, go to "Advanced WSL settings" and select "XFCE4 desktop"

3. Open a new session to access Kali Linux WSL via RDP.

enjoy
:)
