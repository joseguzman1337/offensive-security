{ lib, pkgs, ... }:

{
  # Generated from the validated sx1 Arch-to-Nix mapping.
  environment.systemPackages = map (path: lib.attrByPath path null pkgs) [
    [ "libspiro" ] # libspiro
    [ "libspnav" ] # libspnav
    [ "libtins" ] # libtins
    [ "libtorrent-rasterbar" ] # libtorrent-rasterbar
    [ "libtpms" ] # libtpms
    [ "libtraceevent" ] # libtraceevent
    [ "libtracefs" ] # libtracefs
    [ "libuninameslist" ] # libuninameslist
    [ "libvirt" ] # libvirt
    [ "libvirt-dbus" ] # libvirt-dbus
    [ "libvirt-glib" ] # libvirt-glib
    [ "libvisio" ] # libvisio
    [ "libvncserver" ] # libvncserver
    [ "libwebsockets" ] # libwebsockets
    [ "libwmf" ] # libwmf
    [ "libwpd" ] # libwpd
    [ "libwpg" ] # libwpg
    [ "libwps" ] # libwps
    [ "libxklavier" ] # libxklavier
    [ "libxpresent" ] # libxpresent
    [ "libytnef" ] # libytnef
    [ "libzen" ] # libzen
    [ "libzmf" ] # libzmf
    [ "lief" ] # lief
    [ "ligolo-ng" ] # ligolo-ng
    [ "linux-exploit-suggester" ] # linux-exploit-suggester
    [ "linux-firmware" ] # linux-firmware
    [ "linux-wifi-hotspot" ] # linux-wifi-hotspot
    [ "linux_zen" ] # linux-zen
    [ "litehtml" ] # litehtml
    [ "llama-cpp" ] # llama-cpp
    [ "llvm" ] # llvm
    [ "lmms" ] # lmms
    [ "loadlibrary" ] # loadlibrary
    [ "log4cplus" ] # log4cplus
    [ "logkeys" ] # logkeys
    [ "logrotate" ] # logrotate
    [ "lollypop" ] # lollypop
    [ "lrzip" ] # lrzip
    [ "lsb-release" ] # lsb-release
    [ "lsof" ] # lsof
    [ "luajit" ] # luajit
    [ "lvm2" ] # lvm2
    [ "lxpanel" ] # lxpanel
    [ "lzip" ] # lzip
    [ "lzop" ] # lzop
    [ "m17n_db" ] # m17n-db
    [ "m17n_lib" ] # m17n-lib
    [ "mac-robber" ] # mac-robber
    [ "magicrescue" ] # magicrescue
    [ "maigret" ] # maigret
    [ "mailspring" ] # mailspring
    [ "maltego" ] # maltego
    [ "man-db" ] # man-db
    [ "man-pages" ] # man-pages
    [ "manifold" ] # manifold
    [ "mantra" ] # mantra
    [ "mapcidr" ] # mapcidr
    [ "mariadb" ] # mariadb
    [ "maskprocessor" ] # maskprocessor
    [ "massdns" ] # massdns
    [ "materialx" ] # materialx
    [ "mbedtls" ] # mbedtls
    [ "mdadm" ] # mdadm
    [ "mdbtools" ] # mdbtools
    [ "med" ] # med
    [ "mediaelch" ] # mediaelch
    [ "meg" ] # meg
    [ "meld" ] # meld
    [ "mercury" ] # mercury
    [ "meson" ] # meson
    [ "metabigor" ] # metabigor
    [ "mfcuk" ] # mfcuk
    [ "micro" ] # micro
    [ "mimikatz" ] # mimikatz
    [ "minimodem" ] # minimodem
    [ "minizip-ng" ] # minizip-ng
    [ "missidentify" ] # missidentify
    [ "mitm6" ] # mitm6
    [ "mixxx" ] # mixxx
    [ "mlt" ] # mlt
    [ "mobsf" ] # mobsf
    [ "mongoaudit" ] # mongoaudit
    [ "monocle" ] # monocle
    [ "monsoon" ] # monsoon
    [ "mousepad" ] # mousepad
    [ "movit" ] # movit
    [ "mpv" ] # mpv
    [ "ms-sys" ] # ms-sys
    [ "mtools" ] # mtools
    [ "mubeng" ] # mubeng
    [ "mujs" ] # mujs
    [ "mumble" ] # mumble
    [ "muparser" ] # muparser
    [ "musescore" ] # musescore
    [ "myjwt" ] # myjwt
    [ "mypaint" ] # mypaint
    [ "mypaint-brushes" ] # mypaint-brushes
    [ "mypaint-brushes1" ] # mypaint-brushes1
    [ "myrescue" ] # myrescue
    [ "naabu" ] # naabu
    [ "nano" ] # nano
    [ "net-snmp" ] # net-snmp
    [ "net-tools" ] # net-tools
    [ "netavark" ] # netavark
    [ "netbeans" ] # netbeans
    [ "netdiscover" ] # netdiscover
    [ "netexec" ] # netexec
    [ "netmask" ] # netmask
    [ "netpbm" ] # netpbm
    [ "netscan" ] # netscan
    [ "networkminer" ] # networkminer
    [ "nextcloud-client" ] # nextcloud-client
    [ "nfdump" ] # nfdump
    [ "nfs-utils" ] # nfs-utils
    [ "ngrok" ] # ngrok
    [ "ngspice" ] # ngspice
    [ "nilfs-utils" ] # nilfs-utils
    [ "ninja" ] # ninja
    [ "nmap" ] # nmap
    [ "nng" ] # nng
    [ "node-gyp" ] # node-gyp
    [ "nodejs" ] # nodejs
    [ "nosqli" ] # nosqli
    [ "noto-fonts" ] # noto-fonts
    [ "nray" ] # nray
    [ "ntlm-challenger" ] # ntlm-challenger
    [ "ntlmrecon" ] # ntlmrecon
    [ "nuclei" ] # nuclei
    [ "numactl" ] # numactl
    [ "obs-studio" ] # obs-studio
    [ "obsidian" ] # obsidian
    [ "onesixtyone" ] # onesixtyone
    [ "opencode" ] # opencode
    [ "opencolorio" ] # opencolorio
    [ "openh264" ] # openh264
    [ "openimagedenoise" ] # openimagedenoise
    [ "openimageio" ] # openimageio
    [ "openmpi" ] # openmpi
    [ "openpgl" ] # openpgl
    [ "openrisk" ] # openrisk
    [ "openshadinglanguage" ] # openshadinglanguage
    [ "opensnitch" ] # opensnitch
    [ "opensubdiv" ] # opensubdiv
    [ "opentimelineio" ] # opentimelineio
    [ "openvdb" ] # openvdb
    [ "ophcrack" ] # ophcrack
    [ "opus-tools" ] # opus-tools
    [ "opusfile" ] # opusfile
    [ "osinfo-db" ] # osinfo-db
    [ "osm-gps-map" ] # osm-gps-map
    [ "osslsigncode" ] # osslsigncode
    [ "ostinato" ] # ostinato
    [ "ostree" ] # ostree
    [ "outguess" ] # outguess
    [ "pack" ] # pack
    [ "packagekit" ] # packagekit
    [ "pacman" ] # pacman
    [ "pacu" ] # pacu
    [ "padbuster" ] # padbuster
    [ "padre" ] # padre
    [ "parole" ] # parole
    [ "parsero" ] # parsero
    [ "paru" ] # paru
    [ "pasco" ] # pasco
    [ "passdetective" ] # passdetective
    [ "passt" ] # passt
    [ "payloadsallthethings" ] # payloadsallthethings
    [ "pcapfix" ] # pcapfix
    [ "pciutils" ] # pciutils
    [ "pdf-parser" ] # pdf-parser
    [ "pdfid" ] # pdfid
    [ "pe-bear" ] # pe-bear
    [ "pencil2d" ] # pencil2d
    [ "pentestgpt" ] # pentestgpt
    [ "pev" ] # pev
    [ "phodav" ] # phodav
    [ "phpstan" ] # phpstan
    [ "phrasendrescher" ] # phrasendrescher
    [ "pipeline" ] # pipeline
    [ "pixd" ] # pixd
    [ "pkcrack" ] # pkcrack
    [ "plecost" ] # plecost
    [ "plocate" ] # plocate
    [ "pmacct" ] # pmacct
    [ "pngcheck" ] # pngcheck
    [ "poco" ] # poco
    [ "podman" ] # podman
    [ "podman-compose" ] # podman-compose
    [ "podman-desktop" ] # podman-desktop
    [ "poly" ] # poly
    [ "portmidi" ] # portmidi
    [ "postman" ] # postman-bin
    [ "potrace" ] # potrace
    [ "power-profiles-daemon" ] # power-profiles-daemon
    [ "powersploit" ] # powersploit
    [ "powertop" ] # powertop
    [ "pre2k" ] # pre2k
    [ "procdump" ] # procdump
    [ "procyon" ] # procyon
    [ "prometheus" ] # prometheus
    [ "prowler" ] # prowler
    [ "proxify" ] # proxify
    [ "prrte" ] # prrte
    [ "psmisc" ] # psmisc
    [ "pspy" ] # pspy
    [ "psutils" ] # psutils
    [ "ptex" ] # ptex
    [ "pugixml" ] # pugixml
    [ "puppet" ] # puppet
    [ "puredns" ] # puredns
    [ "putty" ] # putty
    [ "pwnat" ] # pwnat
    [ "pwncat" ] # pwncat
    [ "pygpoabuse" ] # pygpoabuse
    [ "pystring" ] # pystring
    [ "python3Packages" "adblock" ] # python-adblock
    [ "python3Packages" "appdirs" ] # python-appdirs
    [ "python3Packages" "attrs" ] # python-attrs
    [ "python3Packages" "autocommand" ] # python-autocommand
    [ "python3Packages" "automat" ] # python-automat
    [ "python3Packages" "babel" ] # python-babel
    [ "python3Packages" "bcrypt" ] # python-bcrypt
    [ "python3Packages" "beautifulsoup4" ] # python-beautifulsoup4
    [ "python3Packages" "cachecontrol" ] # python-cachecontrol
    [ "python3Packages" "certifi" ] # python-certifi
    [ "python3Packages" "cffi" ] # python-cffi
    [ "python3Packages" "chardet" ] # python-chardet
    [ "python3Packages" "charset-normalizer" ] # python-charset-normalizer
    [ "python3Packages" "click" ] # python-click
    [ "python3Packages" "colorama" ] # python-colorama
    [ "python3Packages" "configobj" ] # python-configobj
    [ "python3Packages" "constantly" ] # python-constantly
    [ "python3Packages" "contourpy" ] # python-contourpy
    [ "python3Packages" "cryptography" ] # python-cryptography
    [ "python3Packages" "cssselect" ] # python-cssselect
    [ "python3Packages" "cycler" ] # python-cycler
    [ "python3Packages" "cymruwhois" ] # python-cymruwhois
    [ "python3Packages" "distro" ] # python-distro
    [ "python3Packages" "docutils" ] # python-docutils
    [ "python3Packages" "filelock" ] # python-filelock
    [ "python3Packages" "fonttools" ] # python-fonttools
    [ "python3Packages" "geoip" ] # python-geoip
    [ "python3Packages" "gpgme" ] # python-gpgme
    [ "python3Packages" "greenlet" ] # python-greenlet
    [ "python3Packages" "grpcio" ] # python-grpcio
  ];
}
