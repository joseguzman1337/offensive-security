### Install Kali Linux in Docker

Deploy Portainer tool for managing your Containers through a Web Intranet Portal

    docker volume create portainer_data && docker run -d -p 8001:8000 -p 9443:9443 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

#

Deploy & Run Kali Linux image in Docker with storage persistence

    docker run -it --rm --mount src=kali-root,dst=/root --mount src=kali-postgres,dst=/var/lib/postgresql kalilinux/kali-rolling /bin/bash

#

List actual Docker images

    docker ps -a

#

or

    docker container ls

or

    docker ps --filter status=running

#

In a future when you need start the same Kali Linux Docker Container that you installed, execute:

    docker exec -it <container_name> bash

#

Start Kali Linux \* only after close the docker instance or reboot your physical machine

    docker run -it --rm --mount src=kali-root,dst=/root --mount src=kali-postgres,dst=/var/lib/postgresql kalilinux/kali-rolling /bin/bash

Other docker images=

    docker start xxxxxxxxxxxx

#

Start Portainer \* only after reboot your physical machine

    docker start portainer

#

or

    docker start xxxxxxxxxxxx

#

#

For open Portainer go to

    http://localhost:9000

# Convert Kali Linux in Ninja Mode

33.37 GB free space required in your disk. \*\*\*Repeat it until you see that really were installed successfully at 100%.

    sudo locale-gen && sudo dpkg-reconfigure locales && apt-get update -y && apt-get full-upgrade -y && apt-get install sudo wget -y && sudo apt-get autoclean && apt-get clean cache && sudo apt update && apt install kali-linux-default kali-linux-everything kali-linux-large && apt-get full-upgrade -y

#

    sudo apt-get autoclean && apt-get clean cache && sudo apt update && apt install git screen neofetch screenfetch synaptic lsb-release software-properties-common forensics-all forensics-all-gui forensics-extra-gui forensics-extra zipalign curl dirmngr apt-transport-https jq php postgresql nginx hping3 hashcat openvpn network-manager-openvpn-gnome gnome gdm3 gnome-tweaks gnome-tweak-tool synaptic caca-utils inetutils-traceroute python-nautilus mdbtools make libncurses5-dev module-assistant mingw-w64 pdns-tools synaptic autopsy pcsxr gir1.2-nautilus-3.0 sshfs resolvconf nmap net-tools ssh gcc python2 python3 gimp php-mbstring python-dev python-setuptools python-setuptools cmatrix python-dev python3-pip gparted pvm-dev compiz ndisc6 steghide httrack mesa-utils ethtool build-essential macchanger gnome winbind wget nano git file-roller p7zip-full p7zip-rar rar unrar zip unzip unace bzip2 lhasa jlha-utils lzip xz-utils mercurial make pulseaudio libcanberra-pulse blender blender-data byzanz calibre calibre-bin expect ffmpeg fig2dev fonts-dejavu gawk ghex gnome-dictionary hexchat screen hexchat-common hexchat-perl hexchat-plugins hexchat-python3 hwdata inkscape libavresample4 libblosc1 libchm1 libdbusextended-qt5-1 libdcmtk14 libdframeworkdbus-dev libdframeworkdbus2 libdtkcore-bin libdtkcore2 libdtkwm-dev libdtkwm2 libfreeimage3 libglew2.1 libgsettings-qt1 libgtkhex-3-0 libgtkspell0 libjemalloc2 libjs-coffeescript libjxr0 liblog4cplus-1.1-9 libmagick++-6.q16-8 libmpris-qt5-1 libmpv1 libopencolorio1v5 libpodofo0.9.6 libpotrace0 libpulse-dev libqapt3 libqapt3-runtime libqt5concurrent5 libqt5designer5 libqt5help5 libqt5multimediaquick5 libqt5opengl5-dev libqt5x11extras5-dev libqt5xdg3 libqt5xdgiconloader3 libspnav0 libtidy5deb1 libtinyxml2.6.2v5 libvulkan-dev libwmf-bin libxcb-composite0 libxcb-damage0 libyaml-cpp0.6 lrzsz mpv onioncircuits optipng papirus-icon-theme phantomjs polkit-kde-agent-1 python-libxml2 python-pygments scour python3-argcomplete python3-gnupg python3-progressbar python3-pycountry python3-pyxattr python3-scour python3-stem python3-xapian qt5-qmake qt5-qmake-bin qt5dxcb-plugin qtbase5-dev qtbase5-dev-tools qtmultimedia5-dev rtmpdump scour tcl-expect youtube-dl zssh lsdvd libdvdnav4 gdebi-core ffmpeg2theora ffmpegthumbnailer gstreamer1.0-plugins-base gstreamer1.0-nice gstreamer1.0-plugins-good gstreamer1.0-plugins-bad lib32z1 gstreamer1.0-plugins-ugly gstreamer1.0-alsa gstreamer1.0-pulseaudio gstreamer1.0-libav lightdm compizconfig-settings-manager compiz-plugins-extra compiz gstreamer1.0-vaapi apt-xapian-index mpg123 libldap-2.4-2 libpulse0 libxml2 giflib-tools libc6 gtk2-engines gcc gcc-multilib g++ g++-multilib cmake lm-sensors hddtemp fancontrol wine playonlinux telegram-desktop gdebi mesa-utils mesa-utils-extra libegl1-mesa libgl1-mesa-dri libglapi-mesa libgles2-mesa libglu1-mesa mesa-vdpau-drivers uuid-runtime fonts-cantarell fonts-liberation fonts-noto ttf-dejavu fonts-stix otf-stix fonts-oflb-asana-math fonts-mathjax -y && bash <(wget -qO- https://git.io/vAtmB) && sudo apt-get install aptitude -y && sudo aptitude safe-upgrade -y && sudo apt-get install --fix-broken && apt-get update --fix-missing && sudo apt-get update && apt-get full-upgrade && apt-get autoremove -y && apt-get install apt-file -y && apt-get install -y && sudo apt update -y && sudo apt dist-upgrade -y && cd && neofetch

#

    sudo apt-get autoclean && apt-get clean cache && sudo apt update && sudo apt install git screen neofetch screenfetch synaptic lsb-release software-properties-common curl dirmngr apt-transport-https jq nginx onioncircuits youtube-dl hping3 hashcat openvpn chktex clisp dvidvi dvipng lacheck latexdiff latexmk libemf1 libffcall1b libplot2c2 libpstoedit0c2a ps2eps pstoedit purifyeps xindy xindy-rules fonts-ancient-scripts fonts-symbola libgtkglext1 libpangox-1.0-0 qml-module-qtgraphicaleffects qml-module-qtquick-controls qml-module-qtquick-dialogs qml-module-qtquick-layouts qml-module-qtquick-privatewidgets qml-module-qtquick-window2 qml-module-qtquick2 network-manager-openvpn-gnome gnome gdm3 gnome-tweaks gnome-tweak-tool gnome-dictionary synaptic build-essential linux-headers-`uname -r` dkms gcc gcc-multilib g++ g++-multilib cmake ghex snapd blender lm-sensors hddtemp fancontrol wine playonlinux calibre hexchat docker docker-compose docker.io wmdocker vagrant inkscape libsecret-1-0 libsecret-1-dev telegram-desktop gir1.2-gtop-2.0 gir1.2-nm-1.0 asciidoc xmlto docbook2x install-info dh-autoreconf libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev wget npm nano git mercurial make pulseaudio libcanberra-pulse mpg123 libldap-2.4-2 libpulse0 libxml2 giflib-tools libc6 rar unrar p7zip p7zip-full p7zip-rar unace zip unzip bzip2 arj lhasa lzip ffmpegthumbnailer gstreamer1.0-plugins-base gstreamer1.0-nice gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-alsa gstreamer1.0-pulseaudio gstreamer1.0-libav gstreamer1.0-vaapi lsdvd libdvdnav4 compizconfig-settings-manager compiz-plugins-extra compiz python-nautilus gir1.2-nautilus-3.0 sshfs resolvconf nmap net-tools ssh gcc python-dev python-setuptools python-setuptools python-dev python3-pip libesedb-utils gparted gimp steghide httrack mesa-utils ethtool macchanger python2 python3 python-gi python3-gi postgresql gimp wireshark wireshark-gtk wireshark-doc ndiff zmap forensics-all forensics-all-gui forensics-extra-gui forensics-extra hydra-gtk -y && cd /usr/share && git clone https://github.com/s0md3v/Photon && cd /usr/share/Photon  && chmod +x *.* && neofetch && pwd && cd /usr/share && git clone https://github.com/aboul3la/Sublist3r.git && cd /usr/share/Sublist3r && chmod +x *.* && wget https://bootstrap.pypa.io/get-pip.py && sudo python get-pip.py && sudo pip install ebcdic && sudo pip install ebcdic && sudo pip3 install ebcdic && python setup.py install && sudo apt install snapd && sudo systemctl start snapd && sudo systemctl enable snapd && sudo systemctl start apparmor && sudo systemctl enable apparmor && export PATH="$PATH:/snap/bin" && snap install go --classic && sudo snap install snap-store && sudo snap install slack --classic && sudo snap install discord && sudo snap install signal-desktop && sudo snap install wire && snap install postman && sudo snap install kubectl --classic && sudo snap install mattermost-desktop && sudo snap install whatsdesk && sudo snap install google-cloud-sdk --classic && sudo snap install heroku --classic && sudo snap install aws-cli --classic && sudo snap install john-the-ripper && sudo snap install zaproxy --classic && sudo snap install wireguard-ammp && sudo snap install vectr && sudo snap install zeronet && sudo snap install spotify && sudo snap install hexexplorer-snap && sudo snap refresh && cd /root && wget http://archive.ubuntu.com/ubuntu/pool/main/p/packagekit/libpackagekit-glib2-16_0.8.17-4ubuntu6~gcc5.4ubuntu1_amd64.deb && wget https://mirrors.edge.kernel.org/ubuntu/pool/universe/t/ttf-ancient-fonts/ttf-ancient-fonts_2.60-1_all.deb && wget https://dl.teamviewer.com/download/linux/version_15x/teamviewer_15.4.4445_amd64.deb && wget https://repo.skype.com/latest/skypeforlinux-64.deb && dpkg -i *.* && systemctl disable teamviewerd.service && neofetch && pwd && sudo apt-get install aptitude -y && sudo aptitude safe-upgrade -y && sudo apt-get install --fix-broken && apt-get update --fix-missing && sudo apt-get update && apt-get full-upgrade && apt-get autoremove -y && apt-get install apt-file -y && apt-get install -y && /etc/init.d/kmod start && sensors-detect && sudo apt update -y && sudo apt dist-upgrade -y && sudo dpkg --configure -a && cd && neofetch

#

    sudo gem install lolcat nokogiri bundle rails racc

#

    sudo gem pristine diff-lcs domain_name erubis httpclient rack rake rest-client rubydns term-ansicolor thin thor tilt racc

#

    sudo gem update --system

#

    sudo pip install --no-cache-dir -U crcmod

#

#

    sudo apt-get autoclean && sudo apt install -f && sudo apt install neofetch -y && sudo apt -f install && sudo apt autoremove -y && apt-get clean cache && sudo apt update && sudo apt-get autoclean && apt-get clean cache && sudo apt update && sudo apt update -y && sudo apt full-upgrade -y --allow-downgrades && sudo dpkg --configure -a && sudo grub-mkconfig && cd && neofetch

#

#

## Set DNS

    rm -r /etc/resolv.conf && nano /etc/resolv.conf

#

    #P
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

# Add GUI & XFCE4 desktop

Select lightdm=

    sudo apt install xfce4 xfce4-goodies -y && sudo apt install lightdm -y && sudo apt install xfce4 xrdp -y && echo "xfce4-session" >~/.xsession && sudo systemctl enable xrdp && sudo /etc/init.d/xrdp start && sudo systemctl start xrdp

Now you can open a new session for access Kali Linux Dockerized via RDP.

enjoy
:)
