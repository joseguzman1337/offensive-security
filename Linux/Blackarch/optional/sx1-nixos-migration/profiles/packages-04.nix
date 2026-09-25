{ lib, pkgs, ... }:

{
  # Generated from the validated sx1 Arch-to-Nix mapping.
  environment.systemPackages = map (path: lib.attrByPath path null pkgs) [
    [ "python3Packages" "grpcio-tools" ] # python-grpcio-tools
    [ "python3Packages" "h11" ] # python-h11
    [ "python3Packages" "httplib2" ] # python-httplib2
    [ "python3Packages" "hyperlink" ] # python-hyperlink
    [ "python3Packages" "idna" ] # python-idna
    [ "python3Packages" "ifaddr" ] # python-ifaddr
    [ "python3Packages" "imagesize" ] # python-imagesize
    [ "python3Packages" "importlib-metadata" ] # python-importlib-metadata
    [ "python3Packages" "incremental" ] # python-incremental
    [ "python3Packages" "invoke" ] # python-invoke
    [ "python3Packages" "isodate" ] # python-isodate
    [ "python3Packages" "kiwisolver" ] # python-kiwisolver
    [ "python3Packages" "lief" ] # python-lief
    [ "python3Packages" "lockfile" ] # python-lockfile
    [ "python3Packages" "lxml" ] # python-lxml
    [ "python3Packages" "mako" ] # python-mako
    [ "python3Packages" "markdown" ] # python-markdown
    [ "python3Packages" "markupsafe" ] # python-markupsafe
    [ "python3Packages" "matplotlib" ] # python-matplotlib
    [ "python3Packages" "more-itertools" ] # python-more-itertools
    [ "python3Packages" "msgpack" ] # python-msgpack
    [ "python3Packages" "netifaces" ] # python-netifaces
    [ "python3Packages" "numpy" ] # python-numpy
    [ "python3Packages" "outcome" ] # python-outcome
    [ "python3Packages" "paramiko" ] # python-paramiko
    [ "python3Packages" "pcodedmp" ] # python-pcodedmp
    [ "python3Packages" "pillow" ] # python-pillow
    [ "python3Packages" "pip" ] # python-pip
    [ "python3Packages" "pivy" ] # python-pivy
    [ "python3Packages" "platformdirs" ] # python-platformdirs
    [ "python3Packages" "ply" ] # python-ply
    [ "python3Packages" "protobuf" ] # python-protobuf
    [ "python3Packages" "puremagic" ] # python-puremagic
    [ "python3Packages" "pyaml" ] # python-pyaml
    [ "python3Packages" "pyasn1" ] # python-pyasn1
    [ "python3Packages" "pyasn1-modules" ] # python-pyasn1-modules
    [ "python3Packages" "pycountry" ] # python-pycountry
    [ "python3Packages" "pycparser" ] # python-pycparser
    [ "python3Packages" "pycryptodome" ] # python-pycryptodome
    [ "python3Packages" "pycryptodomex" ] # python-pycryptodomex
    [ "python3Packages" "pycurl" ] # python-pycurl
    [ "python3Packages" "pygments" ] # python-pygments
    [ "python3Packages" "pyinotify" ] # python-pyinotify
    [ "python3Packages" "pynacl" ] # python-pynacl
    [ "python3Packages" "pyopenssl" ] # python-pyopenssl
    [ "python3Packages" "pyparsing" ] # python-pyparsing
    [ "python3Packages" "pypdf" ] # python-pypdf
    [ "python3Packages" "pyqt5" ] # python-pyqt5
    [ "python3Packages" "pyqt5-sip" ] # python-pyqt5-sip
    [ "python3Packages" "pyqt6-webengine" ] # python-pyqt6-webengine
    [ "python3Packages" "pyserial" ] # python-pyserial
    [ "python3Packages" "pysocks" ] # python-pysocks
    [ "python3Packages" "pytz" ] # python-pytz
    [ "python3Packages" "qrcode" ] # python-qrcode
    [ "python3Packages" "rencode" ] # python-rencode
    [ "python3Packages" "requests" ] # python-requests
    [ "python3Packages" "resolvelib" ] # python-resolvelib
    [ "python3Packages" "roman-numerals-py" ] # python-roman-numerals-py
    [ "python3Packages" "service-identity" ] # python-service-identity
    [ "python3Packages" "setproctitle" ] # python-setproctitle
    [ "python3Packages" "setuptools" ] # python-setuptools
    [ "python3Packages" "simplejson" ] # python-simplejson
    [ "python3Packages" "six" ] # python-six
    [ "python3Packages" "sniffio" ] # python-sniffio
    [ "python3Packages" "snowballstemmer" ] # python-snowballstemmer
    [ "python3Packages" "sortedcontainers" ] # python-sortedcontainers
    [ "python3Packages" "soupsieve" ] # python-soupsieve
    [ "python3Packages" "sphinx" ] # python-sphinx
    [ "python3Packages" "sphinxcontrib-applehelp" ] # python-sphinxcontrib-applehelp
    [ "python3Packages" "sphinxcontrib-devhelp" ] # python-sphinxcontrib-devhelp
    [ "python3Packages" "sphinxcontrib-htmlhelp" ] # python-sphinxcontrib-htmlhelp
    [ "python3Packages" "sphinxcontrib-jsmath" ] # python-sphinxcontrib-jsmath
    [ "python3Packages" "sphinxcontrib-qthelp" ] # python-sphinxcontrib-qthelp
    [ "python3Packages" "sphinxcontrib-serializinghtml" ] # python-sphinxcontrib-serializinghtml
    [ "python3Packages" "sqlalchemy" ] # python-sqlalchemy
    [ "python3Packages" "tinycss2" ] # python-tinycss2
    [ "python3Packages" "tqdm" ] # python-tqdm
    [ "python3Packages" "trio" ] # python-trio
    [ "python3Packages" "trio-websocket" ] # python-trio-websocket
    [ "python3Packages" "twisted" ] # python-twisted
    [ "python3Packages" "uncompyle6" ] # python-uncompyle6
    [ "python3Packages" "unidecode" ] # python-unidecode
    [ "python3Packages" "urllib3" ] # python-urllib3
    [ "python3Packages" "wapiti-arsenic" ] # python-wapiti-arsenic
    [ "python3Packages" "webencodings" ] # python-webencodings
    [ "python3Packages" "websocket-client" ] # python-websocket-client
    [ "python3Packages" "wheel" ] # python-wheel
    [ "python3Packages" "wsproto" ] # python-wsproto
    [ "python3Packages" "wxpython" ] # python-wxpython
    [ "python3Packages" "zeroconf" ] # python-zeroconf
    [ "python3Packages" "zipp" ] # python-zipp
    [ "python3Packages" "zope-interface" ] # python-zope-interface
    [ "python3Packages" "zstandard" ] # python-zstandard
    [ "qbittorrent" ] # qbittorrent
    [ "qhull" ] # qhull
    [ "qradiolink" ] # qradiolink
    [ "qsreplace" ] # qsreplace
    [ "qtcreator" ] # qtcreator
    [ "quark-engine" ] # quark-engine
    [ "qutebrowser" ] # qutebrowser
    [ "radvd" ] # radvd
    [ "ragel" ] # ragel
    [ "rdma-core" ] # rdma-core
    [ "rdwatool" ] # rdwatool
    [ "recoverdm" ] # recoverdm
    [ "recoverjpeg" ] # recoverjpeg
    [ "redfang" ] # redfang
    [ "redland" ] # redland
    [ "redsocks" ] # redsocks
    [ "regripper" ] # regripper
    [ "remmina" ] # remmina
    [ "reptor" ] # reptor
    [ "resvg" ] # resvg
    [ "rex" ] # rex
    [ "rinetd" ] # rinetd
    [ "ristretto" ] # ristretto
    [ "rita" ] # rita
    [ "rnnoise" ] # rnnoise
    [ "rosegarden" ] # rosegarden
    [ "rp" ] # rp
    [ "rr" ] # rr
    [ "rsmangler" ] # rsmangler
    [ "rsync" ] # rsync
    [ "rtfm" ] # rtfm
    [ "rtl_433" ] # rtl-433
    [ "rtl_wmbus" ] # rtl-wmbus
    [ "rtlamr" ] # rtlamr
    [ "ruby" ] # ruby
    [ "rubyPackages" "base64" ] # ruby-base64
    [ "rubyPackages" "erb" ] # ruby-erb
    [ "rubyPackages" "ffi" ] # ruby-ffi
    [ "rubyPackages" "locale" ] # ruby-locale
    [ "rubyPackages" "multi_json" ] # ruby-multi_json
    [ "rubyPackages" "racc" ] # ruby-racc
    [ "rubyPackages" "thor" ] # ruby-thor
    [ "ruler" ] # ruler
    [ "runc" ] # runc
    [ "rustcat" ] # rustcat
    [ "rusthound-ce" ] # rusthound-ce
    [ "s3scanner" ] # s3scanner
    [ "safecopy" ] # safecopy
    [ "saleae-logic" ] # saleae-logic
    [ "samdump2" ] # samdump2
    [ "samplicator" ] # samplicator
    [ "sane-airscan" ] # sane-airscan
    [ "savvycan" ] # savvycan
    [ "scalpel" ] # scalpel
    [ "scap-security-guide" ] # scap-security-guide
    [ "sccmhunter" ] # sccmhunter
    [ "scour" ] # scour
    [ "scoutsuite" ] # scoutsuite
    [ "scrounge-ntfs" ] # scrounge-ntfs
    [ "sdl12-compat" ] # sdl12-compat
    [ "sdrangel" ] # sdrangel
    [ "sdrpp" ] # sdrpp
    [ "seabios" ] # seabios
    [ "seclists" ] # seclists
    [ "semgrep" ] # semgrep
    [ "semver" ] # semver
    [ "sg3_utils" ] # sg3_utils
    [ "sha1collisiondetection" ] # sha1collisiondetection
    [ "shadow" ] # shadow
    [ "shellnoob" ] # shellnoob
    [ "shellz" ] # shellz
    [ "sherlock" ] # sherlock
    [ "shortwave" ] # shortwave
    [ "shotcut" ] # shotcut
    [ "shuffledns" ] # shuffledns
    [ "signal-desktop" ] # signal-desktop
    [ "simde" ] # simde
    [ "simdjson" ] # simdjson
    [ "sipp" ] # sipp
    [ "sipsak" ] # sipsak
    [ "sipvicious" ] # sipvicious
    [ "smap" ] # smap
    [ "smbclient-ng" ] # smbclient-ng
    [ "smbmap" ] # smbmap
    [ "smplayer" ] # smplayer
    [ "snallygaster" ] # snallygaster
    [ "sndio" ] # sndio
    [ "snitch" ] # snitch
    [ "snmpcheck" ] # snmpcheck
    [ "snort" ] # snort
    [ "snow" ] # snow
    [ "snscrape" ] # snscrape
    [ "snyk" ] # snyk
    [ "soapui" ] # soapui
    [ "socialscan" ] # socialscan
    [ "sof-firmware" ] # sof-firmware
    [ "soqt" ] # soqt
    [ "sourcemapper" ] # sourcemapper
    [ "sox" ] # sox
    [ "spade" ] # spade
    [ "spdlog" ] # spdlog
    [ "speedtest-cli" ] # speedtest-cli
    [ "spice" ] # spice
    [ "spice-gtk" ] # spice-gtk
    [ "spice-protocol" ] # spice-protocol
    [ "splix" ] # splix
    [ "spooftooph" ] # spooftooph
    [ "spraycharles" ] # spraycharles
    [ "ssh-mitm" ] # ssh-mitm
    [ "sshfs" ] # sshfs
    [ "ssldump" ] # ssldump
    [ "sslstrip" ] # sslstrip
    [ "steghide" ] # steghide
    [ "stegseek" ] # stegseek
    [ "stegsolve" ] # stegsolve
    [ "stowaway" ] # stowaway
    [ "strawberry" ] # strawberry
    [ "streamlink" ] # streamlink
    [ "stunner" ] # stunner
    [ "subfinder" ] # subfinder
    [ "subjack" ] # subjack
    [ "subjs" ] # subjs
    [ "subtitlecomposer" ] # subtitlecomposer
    [ "sudo" ] # sudo
    [ "suil" ] # suil
    [ "suitesparse" ] # suitesparse
    [ "superlu" ] # superlu
    [ "suricata" ] # suricata
    [ "swarm" ] # swarm
    [ "synfigstudio" ] # synfigstudio
    [ "sysprof" ] # sysprof
    [ "systemd" ] # systemd
    [ "tcptraceroute" ] # tcptraceroute
    [ "teams-for-linux" ] # teams-for-linux
    [ "telegram-desktop" ] # telegram-desktop
    [ "tell-me-your-secrets" ] # tell-me-your-secrets
    [ "template-glib" ] # template-glib
    [ "termineter" ] # termineter
    [ "terminus_font" ] # terminus-font
    [ "terraform" ] # terraform
    [ "tfsec" ] # tfsec
    [ "thermald" ] # thermald
    [ "thunar" ] # thunar
    [ "thunar-archive-plugin" ] # thunar-archive-plugin
    [ "thunar-media-tags-plugin" ] # thunar-media-tags-plugin
    [ "thunar-volman" ] # thunar-volman
    [ "thunderbird" ] # thunderbird
    [ "tilt" ] # tilt
    [ "tinyxml" ] # tinyxml
    [ "tk" ] # tk
    [ "tlottie" ] # tlottie
    [ "tlsx" ] # tlsx
    [ "topgrade" ] # topgrade
  ];
}
