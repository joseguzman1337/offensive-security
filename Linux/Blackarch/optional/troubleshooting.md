#

    clear && sudo rm /var/lib/pacman/db.lck && sudo pacman -Syyu --needed --disable-download-timeout --noprogressbar --overwrite y && clear && sudo pacman -Syyu haveged pacman-contrib --disable-download-timeout --noconfirm --needed --noprogressbar --overwrite y && systemctl start haveged && systemctl enable haveged && haveged && sudo paccache -r && clear && sudo reflector --threads 20 --verbose --save "/etc/pacman.d/mirrorlist" --protocol https --sort rate --age 24 --score 100 --fastest 100 --latest 50

#

    clear && sudo rm -rf /etc/pacman.d/gnupg/* && sudo pacman-key --init && sudo pacman-key --populate archlinux && curl -O https://blackarch.org/strap.sh && echo 26849980b35a42e6e192c6d9ed8c46f0d6d06047 strap.sh | sha1sum -c && chmod +x strap.sh && sudo ./strap.sh && sudo pacman-key --populate blackarch && gpg --recv-keys D4A753468A5A5B67 && sudo pacman-key --lsign-key D4A753468A5A5B67 && sudo pacman -Scc --noconfirm && clear && sudo pacman-key --refresh-keys && sudo pacman -Scc --noconfirm && sudo pacman -Syyu --noconfirm && sudo pacman-key --populate archlinux blackarch && gpg --recv-keys --keyserver keyserver.ubuntu.com C7246DCCAB907BF6B5F02BE7C6245B6A5F2E86E0 F9A6E68A711354D84A9B91637533BAFE69A25079 && sudo pacman -Syyu --noconfirm

#

    clear && sudo pacman -Syyu --needed --noconfirm --disable-download-timeout --noprogressbar --overwrite '*' && clear && sudo pacman -Syuu --needed --noconfirm --disable-download-timeout --noprogressbar --overwrite '*' gnome guake blackarch && clear && sudo pacman -Syuu --needed --noconfirm --disable-download-timeout --noprogressbar --overwrite '*' blackarch blackarch-anti-forensic blackarch-automation blackarch-backdoor blackarch-binary blackarch-bluetooth blackarch-code-audit blackarch-config blackarch-cracker blackarch-crypto blackarch-database blackarch-debugger blackarch-decompiler blackarch-disassembler blackarch-dos blackarch-drone blackarch-exploitation blackarch-forensic blackarch-fingerprint blackarch-firmware blackarch-fuzzer blackarch-gpu blackarch-hardware blackarch-honeypot blackarch-ids blackarch-keylogger blackarch-malware blackarch-misc blackarch-mobile blackarch-networking blackarch-nfc blackarch-packer blackarch-proxy blackarch-radio blackarch-recon blackarch-reversing blackarch-scanner blackarch-sniffer blackarch-social blackarch-spoof blackarch-stego blackarch-tunnel blackarch-unpacker blackarch-voip blackarch-webap blackarch-webapp blackarch-windows blackarch-wireless

#

    clear && sudo pacman -Syuu --ignore capstone rizin python-capstone --needed --noconfirm --disable-download-timeout --noprogressbar --overwrite blackarch-reversing
