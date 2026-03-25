    Disable IPv6    
    
    net.ipv6.conf.all.disable_ipv6=1
    net.ipv6.conf.default.disable_ipv6=1
    net.ipv6.conf.lo.disable_ipv6=1
#
    To make the settings take effect, run the command below

    sysctl -p
#
    deb https://kali.download/kali kali-rolling main contrib non-free non-free-firmware

    #deb https://http.kali.org/kali kali-last-snapshot main non-free contrib
    #deb https://http.kali.org/kali kali-experimental main non-free contrib
    #deb https://http.kali.org/kali kali-rolling main non-free contrib
    #deb https://http.kali.org/kali kali-rolling main non-free contrib
    #deb https://http.kali.org/kali kali-last-snapshot main non-free contrib
    #deb https://http.kali.org/kali kali-experimental main non-free contrib
    #deb-src https://http.kali.org/kali kali-rolling main non-free contrib
    #deb https://mirrors.ocf.berkeley.edu/kali kali-rolling main non-free contrib
    #deb https://mirror.pwnieexpress.com/kali kali-rolling main non-free contrib
    #deb https://ftp.free.fr/pub/kali kali-rolling main non-free contrib
    #deb https://archive-4.kali.org/kali kali-rolling main non-free contrib
    #deb https://ftp.belnet.be/pub/kali/kali kali-rolling main non-free contrib
    #deb https://ftp.halifax.rwth-aachen.de/kali kali-rolling main non-free contrib
    #deb https://ftp1.nluug.nl/os/Linux/distr/kali kali-rolling main non-free contrib
    #deb https://ftp2.nluug.nl/os/Linux/distr/kali kali-rolling main non-free contrib
    #deb https://mirror.neostrada.nl/kali kali-rolling main non-free contrib
    #deb https://mirror.pyratelan.org/kali kali-rolling main non-free contrib
    #deb https://mirror.karneval.cz/pub/linux/kali kali-rolling main non-free contrib
    #deb https://mirror.serverion.com/kali kali-rolling main non-free contrib
    #deb https://mirrors.dotsrc.org/kali kali-rolling main non-free contrib
    #deb https://ftp.acc.umu.se/mirror/kali.org/kali kali-rolling main non-free contrib
    #deb https://mirror-1.truenetwork.ru/kali kali-rolling main non-free contrib
    #deb https://ftp.jaist.ac.jp/pub/Linux/kali kali-rolling main non-free contrib
    #deb https://hlzmel.fsmg.org.nz/kali kali-rolling main non-free contrib
    #deb https://wlglam.fsmg.org.nz/kali kali-rolling main non-free contrib
    #deb https://kali.mirror.garr.it/mirrors/kali kali-rolling main non-free contrib
    #deb-src https://kali.mirror.garr.it/mirrors/kali kali-rolling main non-free contrib
    #deb http://mirror.fsmg.org.nz/kali kali-rolling main contrib non-free
    #deb-src http://mirror.fsmg.org.nz/kali kali-rolling main contrib non-free
    #deb http://http.kali.org/kali kali-rolling main contrib non-free
    # For source package access, uncomment the following line
    #deb-src http://http.kali.org/kali kali-rolling main contrib non-free
