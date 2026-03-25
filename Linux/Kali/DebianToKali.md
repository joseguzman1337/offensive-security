# Login as root

```
sudo -i
```

---

## Edit APT Repo

```
sudo nano /etc/apt/sources.list
```

Add this repos

```
deb https://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian/ bookworm main
deb https://security.debian.org/debian-security bookworm-security main
deb-src https://security.debian.org/debian-security bookworm-security main
deb https://deb.debian.org/debian/ bookworm-updates main
deb-src https://deb.debian.org/debian/ bookworm-updates main
```

## Debian Bookworm Ninja

```
apt clean && apt update -y && apt install sudo gdebi dirmngr aptitude -y && sudo apt-get autoclean && apt-get clean cache && sudo apt update && apt full-upgrade -y
```

### Add Kali Repo for Debian

On a standard, clean install of Debian Distro-Based Linux, you should have the following entry present in /etc/apt/sources.list:

```
sudo nano /etc/apt/sources.list
```

For Parrot Security add here

```
sudo nano /etc/apt/sources.list.d/parrot.list
```

#

    deb https://kali.download/kali kali-rolling main contrib non-free non-free-firmware

#

```
sudo apt install dirmngr -y && wget -O - https://archive.kali.org/archive-key.asc | sudo apt-key add - && apt-get update -y && apt-get install neofetch lolcat -y && echo "Activated Kali Ninja Repos"
```

### Convert Debian Bookworm Ninja to Kali Ninja

```
sudo apt --fix-broken install && sudo apt autoremove -y && sudo apt update -y && sudo apt full-upgrade -y && sudo apt install aptitude -y && apt-get autoclean && apt-get clean cache && sudo aptitude safe-upgrade --full-resolver -y && sudo apt-get install --fix-broken && apt-get update --fix-missing && sudo apt-get update -y && apt-get dist-upgrade -y && apt-get full-upgrade -y && sudo apt-get update -y && apt-get full-upgrade -y && sudo apt-get autoremove -y && apt-get install apt-file -y && apt-get install -y && sudo dpkg --configure -a && sudo grub-mkconfig
```

Now reboot your machine to complete the conversion of Debian to Kali

### Install Kali Extras

```
sudo apt-get autoclean && sudo apt-get clean cache && sudo apt autoremove -y && sudo apt install aptitude -y && aptitude install locales -y && locale-gen en_US.UTF-8 && localedef -i en_US -f UTF-8 en_US.UTF-8 && export LANGUAGE=en_US.UTF-8 && export LANG=en_US.UTF-8 && export LC_ALL=en_US.UTF-8 && locale-gen en_US.UTF-8 && apt-get update -y && apt-get full-upgrade -y && aptitude install wget ncdu -y && apt-get autoclean && apt-get clean cache && apt update -y && aptitude install kali-linux-default kali-linux-everything kali-linux-large -y && apt-get full-upgrade -y
```

# Add GUI & XFCE4 desktop

Select lightdm=

    sudo apt install xfce4 xfce4-goodies -y && sudo apt install lightdm -y && sudo apt install xfce4 xrdp -y && echo "xfce4-session" >~/.xsession && sudo systemctl enable xrdp && sudo /etc/init.d/xrdp start && sudo systemctl start xrdp

Now you can access Kali Linux via SSH and RDP as well.

enjoy
:)
