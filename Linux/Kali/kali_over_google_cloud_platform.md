How to install Kali Linux 2021.2 on Google Cloud Platform - GCP

On this post, I am going to guide you how to install & upload your Kali Linux into Google Cloud Platform.

Requirements:

  
A Google Cloud Platform Account with credits
    
    https://console.cloud.google.com/
      
VirtualBox 6 with VirtualBox Guest Additions (bidirectional enabled)

    https://www.virtualbox.org/wiki/Downloads
    
Kali Linux ISO

    https://images.kali.org/kali-linux-2020.3-installer-amd64.iso.torrent


137 GB Free Space in your machine


Grab a tea/cofee/beer!!!
    

# Create VirtualBox virtual machine, 

using the ISO downloaded from Kali Linux. Deploy a Kali Linux Ninja (gnome) inside of Virtualbox with UEFI and SSD Storage of 337 GB, once you installed this OS, execute: 
#
# For Kali Linux

    sudo locale-gen && sudo dpkg-reconfigure locales && apt-get update -y && apt-get full-upgrade -y && apt-get install sudo wget -y && sudo apt-get autoclean && apt-get clean cache && sudo apt update && apt install kali-linux-default kali-linux-everything kali-linux-large && apt-get full-upgrade -y

#

    sudo apt-get autoclean && apt-get clean cache && sudo apt update && apt install git screen neofetch screenfetch synaptic lsb-release software-properties-common forensics-all forensics-all-gui forensics-extra-gui forensics-extra zipalign curl dirmngr apt-transport-https jq php postgresql nginx hping3 hashcat openvpn network-manager-openvpn-gnome gnome gdm3 gnome-tweaks gnome-tweak-tool synaptic caca-utils inetutils-traceroute python-nautilus mdbtools make libncurses5-dev module-assistant mingw-w64 pdns-tools synaptic autopsy pcsxr gir1.2-nautilus-3.0 sshfs resolvconf nmap net-tools ssh gcc python2 python3 gimp php-mbstring python-dev python-setuptools python-setuptools cmatrix python-dev python3-pip gparted pvm-dev compiz ndisc6 steghide httrack mesa-utils ethtool build-essential macchanger gnome winbind wget nano git file-roller p7zip-full p7zip-rar rar unrar zip unzip unace bzip2 lhasa jlha-utils lzip xz-utils mercurial make pulseaudio libcanberra-pulse blender blender-data byzanz calibre calibre-bin expect ffmpeg fig2dev fonts-dejavu gawk ghex gnome-dictionary hexchat screen hexchat-common hexchat-perl hexchat-plugins hexchat-python3 hwdata inkscape libavresample4 libblosc1 libchm1 libdbusextended-qt5-1 libdcmtk14 libdframeworkdbus-dev libdframeworkdbus2 libdtkcore-bin libdtkcore2 libdtkwm-dev libdtkwm2 libfreeimage3 libglew2.1 libgsettings-qt1 libgtkhex-3-0 libgtkspell0 libjemalloc2 libjs-coffeescript libjxr0 liblog4cplus-1.1-9 libmagick++-6.q16-8 libmpris-qt5-1 libmpv1 libopencolorio1v5 libpodofo0.9.6 libpotrace0 libpulse-dev libqapt3 libqapt3-runtime libqt5concurrent5 libqt5designer5 libqt5help5 libqt5multimediaquick5 libqt5opengl5-dev libqt5x11extras5-dev libqt5xdg3 libqt5xdgiconloader3 libspnav0 libtidy5deb1 libtinyxml2.6.2v5 libvulkan-dev libwmf-bin libxcb-composite0 libxcb-damage0 libyaml-cpp0.6 lrzsz mpv onioncircuits optipng papirus-icon-theme phantomjs polkit-kde-agent-1 python-libxml2 python-pygments scour python3-argcomplete python3-gnupg python3-progressbar python3-pycountry python3-pyxattr python3-scour python3-stem python3-xapian qt5-qmake qt5-qmake-bin qt5dxcb-plugin qtbase5-dev qtbase5-dev-tools qtmultimedia5-dev rtmpdump scour tcl-expect youtube-dl zssh lsdvd libdvdnav4 gdebi-core ffmpeg2theora ffmpegthumbnailer gstreamer1.0-plugins-base gstreamer1.0-nice gstreamer1.0-plugins-good gstreamer1.0-plugins-bad lib32z1 gstreamer1.0-plugins-ugly gstreamer1.0-alsa gstreamer1.0-pulseaudio gstreamer1.0-libav lightdm compizconfig-settings-manager compiz-plugins-extra compiz gstreamer1.0-vaapi apt-xapian-index mpg123 libldap-2.4-2 libpulse0 libxml2 giflib-tools libc6 gtk2-engines gcc gcc-multilib g++ g++-multilib cmake lm-sensors hddtemp fancontrol wine playonlinux telegram-desktop gdebi mesa-utils mesa-utils-extra libegl1-mesa libgl1-mesa-dri libglapi-mesa libgles2-mesa libglu1-mesa mesa-vdpau-drivers uuid-runtime fonts-cantarell fonts-liberation fonts-noto ttf-dejavu fonts-stix otf-stix fonts-oflb-asana-math fonts-mathjax -y && bash <(wget -qO- https://git.io/vAtmB) && sudo apt-get install aptitude -y && sudo aptitude safe-upgrade -y && sudo apt-get install --fix-broken && apt-get update --fix-missing && sudo apt-get update && apt-get full-upgrade && apt-get autoremove -y && apt-get install apt-file -y && apt-get install -y && sudo apt update -y && sudo apt dist-upgrade -y && cd && neofetch

#
    sudo apt-get autoclean && apt-get clean cache && sudo apt update && sudo apt install git screen neofetch screenfetch synaptic lsb-release software-properties-common curl dirmngr apt-transport-https jq nginx onioncircuits youtube-dl hping3 hashcat openvpn chktex clisp dvidvi dvipng lacheck latexdiff latexmk libemf1 libffcall1b libplot2c2 libpstoedit0c2a ps2eps pstoedit purifyeps xindy xindy-rules fonts-ancient-scripts fonts-symbola libgtkglext1 libpangox-1.0-0 qml-module-qtgraphicaleffects qml-module-qtquick-controls qml-module-qtquick-dialogs qml-module-qtquick-layouts qml-module-qtquick-privatewidgets qml-module-qtquick-window2 qml-module-qtquick2 network-manager-openvpn-gnome gnome gdm3 gnome-tweaks gnome-tweak-tool gnome-dictionary synaptic build-essential linux-headers-`uname -r` dkms gcc gcc-multilib g++ g++-multilib cmake ghex snapd blender lm-sensors hddtemp fancontrol wine playonlinux calibre hexchat docker docker-compose docker.io wmdocker vagrant inkscape libsecret-1-0 libsecret-1-dev telegram-desktop gir1.2-gtop-2.0 gir1.2-nm-1.0 asciidoc xmlto docbook2x install-info dh-autoreconf libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev wget npm nano git mercurial make pulseaudio libcanberra-pulse mpg123 libldap-2.4-2 libpulse0 libxml2 giflib-tools libc6 rar unrar p7zip p7zip-full p7zip-rar unace zip unzip bzip2 arj lhasa lzip ffmpegthumbnailer gstreamer1.0-plugins-base gstreamer1.0-nice gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-alsa gstreamer1.0-pulseaudio gstreamer1.0-libav gstreamer1.0-vaapi lsdvd libdvdnav4 compizconfig-settings-manager compiz-plugins-extra compiz python-nautilus gir1.2-nautilus-3.0 sshfs resolvconf nmap net-tools ssh gcc python-dev python-setuptools python-setuptools python-dev python3-pip libesedb-utils gparted gimp steghide httrack mesa-utils ethtool macchanger python2 python3 python-gi python3-gi postgresql gimp wireshark wireshark-gtk wireshark-doc ndiff zmap forensics-all forensics-all-gui forensics-extra-gui forensics-extra hydra-gtk -y && cd /usr/share && git clone https://github.com/s0md3v/Photon && cd /usr/share/Photon  && chmod +x *.* && neofetch && pwd && cd /usr/share && git clone https://github.com/aboul3la/Sublist3r.git && cd /usr/share/Sublist3r && chmod +x *.* && wget https://bootstrap.pypa.io/get-pip.py && sudo python get-pip.py && sudo pip install ebcdic && sudo pip install ebcdic && sudo pip3 install ebcdic && python setup.py install && sudo apt install snapd && sudo systemctl start snapd && sudo systemctl enable snapd && sudo systemctl start apparmor && sudo systemctl enable apparmor && export PATH="$PATH:/snap/bin" && snap install go --classic && sudo snap install snap-store && sudo snap install slack --classic && sudo snap install discord && sudo snap install signal-desktop && sudo snap install wire && snap install postman && sudo snap install kubectl --classic && sudo snap install mattermost-desktop && sudo snap install whatsdesk && sudo snap install google-cloud-sdk --classic && sudo snap install heroku --classic && sudo snap install aws-cli --classic && sudo snap install john-the-ripper && sudo snap install zaproxy --classic && sudo snap install wireguard-ammp && sudo snap install vectr && sudo snap install zeronet && sudo snap install spotify && sudo snap install hexexplorer-snap && sudo snap refresh && cd /root && wget http://archive.ubuntu.com/ubuntu/pool/main/p/packagekit/libpackagekit-glib2-16_0.8.17-4ubuntu6~gcc5.4ubuntu1_amd64.deb && wget https://mirrors.edge.kernel.org/ubuntu/pool/universe/t/ttf-ancient-fonts/ttf-ancient-fonts_2.60-1_all.deb && wget https://dl.teamviewer.com/download/linux/version_15x/teamviewer_15.4.4445_amd64.deb && wget https://repo.skype.com/latest/skypeforlinux-64.deb && dpkg -i *.* && systemctl disable teamviewerd.service && neofetch && pwd && sudo apt-get install aptitude -y && sudo aptitude safe-upgrade -y && sudo apt-get install --fix-broken && apt-get update --fix-missing && sudo apt-get update && apt-get full-upgrade && apt-get autoremove -y && apt-get install apt-file -y && apt-get install -y && /etc/init.d/kmod start && sensors-detect && sudo apt update -y && sudo apt dist-upgrade -y && sudo dpkg --configure -a && sudo grub-mkconfig && cd && neofetch
    
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


Change configuration of openssh-server
#
    nano /etc/ssh/sshd_config

Set the below value:
#
    PermitRootLogin yes

Set ssh run on the boot
#
    update-rc.d -f ssh enable 2 3 4 5

#
# Install Chrome

    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && chmod +x *.deb && dpkg -i *.deb
    
# Install Azure CLI + VS Code + PowerShell + MS SQL Cli + .Net Core
#    
#    
    curl -SL "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0xEB3E94ADBE1229CF" | sudo apt-key add
     
#    
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    
#  


#     
    sudo apt-get update -y && wget https://mirrors.edge.kernel.org/ubuntu/pool/universe/j/jemalloc/libjemalloc1_3.6.0-9ubuntu1_amd64.deb && chmod +x *.deb && dpkg -i *.deb && wget http://security.debian.org/debian-security/pool/updates/main/i/icu/libicu57_57.1-6+deb9u4_amd64.deb && chmod +x *.deb && dpkg -i *.deb && wget https://deb.sipwise.com/debian/pool/main/o/openssl1.0/libssl1.0.2_1.0.2r-1~deb9u1_amd64.deb && wget http://launchpadlibrarian.net/497699609/libssl1.0.0_1.0.2g-1ubuntu4.17_amd64.deb && wget http://security.ubuntu.com/ubuntu/pool/main/i/icu/libicu55_55.1-7ubuntu0.5_amd64.deb && chmod +x *.deb && dpkg -i *.deb && sudo apt-get update && sudo apt -f install && sudo apt install azure-cli code powershell dotnet-runtime-deps-2.2 dotnet-runtime-2.2 aspnetcore-runtime-2.2 dotnet-sdk-2.2 mssql-cli mssql-server mssql-tools && rm -r *.deb && sudo /opt/mssql/bin/mssql-conf setup && sudo apt-get update -y && sudo dpkg --configure -a && sudo grub-mkconfig && neofetch && systemctl status mssql-server --no-pager
    
#
     sudo reboot
#     
     az login
#     
# Install VirtualBox 6

    echo "deb https://download.virtualbox.org/virtualbox/debian stretch contrib" | sudo tee -a /etc/apt/sources.list && apt remove libcurl4 -y && mkdir /root/Downloads && cd /root/Downloads && wget http://ftp.br.debian.org/debian/pool/main/c/curl/libcurl3_7.52.1-5+deb9u9_amd64.deb && wget http://ftp.br.debian.org/debian/pool/main/libv/libvpx/libvpx4_1.6.1-3+deb9u1_amd64.deb && wget http://ftp.us.debian.org/debian/pool/main/libs/libssh2/libssh2-1_1.7.0-1_amd64.deb && chmod +x libcurl3_7.52.1-5+deb9u9_amd64.deb libvpx4_1.6.1-3+deb9u1_amd64.deb libssh2-1_1.7.0-1_amd64.deb && dpkg -i libcurl3_7.52.1-5+deb9u9_amd64.deb libvpx4_1.6.1-3+deb9u1_amd64.deb libssh2-1_1.7.0-1_amd64.deb && wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add - && wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add - && sudo apt update && sudo apt-get install virtualbox-6.0 -y && apt autoremove -y && rm -r lib* && sudo apt-get update -y && apt full-upgrade && sudo dpkg --configure -a && sudo grub-mkconfig && sudo reboot
    
# Install Google Cloud SDK & GCP Linux Guest Environment

    curl https://sdk.cloud.google.com | bash
    
Close the terminal and open again

    gcloud init && gcloud beta --help && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && sudo nano /etc/apt/sources.list.d/google-cloud.list
#    
    deb http://packages.cloud.google.com/apt google-compute-engine-buster-stable main
    deb http://packages.cloud.google.com/apt google-cloud-packages-archive-keyring-buster main
#
#    
Ctrl + x + y + Enter
#

    sudo apt update -y && sudo apt install -y google-cloud-packages-archive-keyring && sudo apt install aptitude -y && sudo apt-get autoclean && sudo apt-get clean cache && sudo aptitude safe-upgrade -y && sudo apt-get install --fix-broken && sudo apt-get update --fix-missing && sudo apt-get update -y && sudo apt-get full-upgrade -y && sudo apt-get update -y && sudo apt-get full-upgrade -y && sudo apt-get autoremove -y && sudo apt-get install apt-file -y && sudo apt-get install -y && sudo dpkg --configure -a && sudo grub-mkconfig
#
    sudo reboot
#

If all works as expected Kali Linux restarted, correctly, now login as root and execute:
#
    sudo apt update -y && sudo apt remove libcurl4 -y && wget http://security.debian.org/debian-security/pool/updates/main/c/curl/libcurl3-nss_7.52.1-5+deb9u15_amd64.deb && dpkg -i libcurl3-nss_7.52.1-5+deb9u15_amd64.deb && wget http://ftp.us.debian.org/debian/pool/main/j/json-c/libjson-c3_0.12.1+ds-2+deb10u1_amd64.deb && dpkg -i libjson-c3_0.12.1+ds-2+deb10u1_amd64.deb && sudo apt-get -y install make g++ libcurl4-openssl-dev libjson-c-dev libpam-dev && sudo apt-get -y install debhelper devscripts build-essential && sudo aptitude install google-guest-agent google-compute-engine google-compute-engine-oslogin google-compute-engine google-osconfig-agent -y && sudo apt install aptitude -y && apt-get autoclean && apt-get clean cache && sudo aptitude safe-upgrade -y && sudo apt-get install --fix-broken && apt-get update --fix-missing && sudo apt-get update -y && apt-get full-upgrade -y && sudo apt-get update -y && apt-get full-upgrade -y && apt-get autoremove -y && apt-get install apt-file -y && apt-get install -y && sudo dpkg --configure -a && sudo grub-mkconfig
    
    
#    
Restart Kali Linux and inspect that no errors ocurred.
# 
    pip install boto
#    
Restart Kali Linux and inspect that no errors ocurred.
#
    sudo reboot
#
Turn off the Kali Linux virtual machine.
#
Convert Kali linux vdi (37 GB) to raw file (85,9 GB) & Convert raw into tar.gz format
#
    vboxmanage clonehd kali.vdi disk.raw --format raw && tar -zcvf disk.tar.gz disk.raw
#
Create bucket at Google Cloud
#
    https://console.cloud.google.com/storage/browser
#
Upload Kali disk.raw (4,2 GB) to your GCP bucket
#
    gsutil cp disk.tar.gz gs://bucket-name/kali/disk.tar.gz
#
Create image for Kali Linux in GCP
#
    gcloud compute --project=name images create kali --source-uri=https://storage.googleapis.com/bucket-name.appspot.com/kali/disk.tar.gz
#
Start Kali Linux virtual machine in GCP and create Firewall
#
    gcloud beta compute --project=project-name instances create kali --zone=us-central1-f --machine-type=n1-highmem-4 --subnet=default      --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=name-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=http-server,https-server --image=kali --image-project=project-name --boot-disk-size=80GB --boot-disk-type=pd-ssd --boot-disk-device-name=kali
#
    gcloud compute --project=projet-name firewall-rules create default-allow-http --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=http-server    
#

Actually for connect you can do it via web, ssh & PowerShell
# 
    nano ~/.ssh/config
#
    Host *
        IPQoS=lowdelay throughput
# 
Connect via ssh keys in your metadata
#
    gcloud compute config-ssh
#    
Connect via SSH in Linux or PowerShell + Putty in Windows with debugg mode (OS Login Mode)
#     
    gcloud compute --project "project_name" ssh --zone "us-east1-b" "roo@kali"
#
#
#
If Kali Linux only show's the command line after boot, enter the below command 
#     
    startx    
#      
then edit the below file in a terminal
#
    sudo nano .xinitrc
#
Adding this 

    exec startx
    
Ctrl + x + y + Enter
#

For copy files from Google Bucket
#    
    gsutil cp -r gs://proyect_name.appspot.com/folder /root/



WIP=
