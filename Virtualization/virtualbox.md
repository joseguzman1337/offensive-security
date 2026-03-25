# Ubuntu | Debian | Kali | Parrot

Tested and verifed: 16 Oct 2023

    su
#    
    cd ~/ && mkdir Downloads && wget http://ftp.br.debian.org/debian/pool/main/libv/libvpx/libvpx5_1.7.0-3+deb10u1_amd64.deb && wget http://ftp.de.debian.org/debian/pool/main/libv/libvpx/libvpx6_1.9.0-1+deb11u1_amd64.deb && wget http://ftp.us.debian.org/debian/pool/main/libv/libvpx/libvpx7_1.12.0-1.2_amd64.deb && chmod +x *.deb && dpkg -i *.deb && wget https://download.virtualbox.org/virtualbox/7.0.10/virtualbox-7.0_7.0.10-158379~Debian~bookworm_amd64.deb && chmod +x virtualbox-*.deb && dpkg -i virtualbox-*.deb && apt install -f -y && apt-get autoclean && apt install -f && apt install aptitude -y && apt install neofetch linux-headers-`uname -r` -y && apt -f install && apt autoremove -y && apt-get clean cache && apt update && apt-get autoclean && apt-get clean cache &&  apt update -y && apt full-upgrade -y --allow-downgrades && dpkg --configure -a &&  grub-mkconfig && cd && aptitude upgrade --full-resolver -y && apt autoremove -y && neofetch
    
#    

Reboot and Enjoy


# Uninstall

    sudo apt-get remove virtualbox-\* -y && sudo apt-get purge virtualbox-\* -y
