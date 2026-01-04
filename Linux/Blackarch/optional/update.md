```ShellSesion
yay -Sc --noconfirm && yay -Syuuq --noconfirm --mflags "--nocheck" && yay -Sc --noconfirm
```

```ShellSesion
if pacman -Qdtq >/dev/null 2>&1; then sudo pacman -Rs --noconfirm $(pacman -Qdtq); fi && sudo pacman -Syu --needed --disable-download-timeout --noprogressbar --noconfirm && if pacman -Qdtq >/dev/null 2>&1; then sudo pacman -Rs --noconfirm $(pacman -Qdtq); fi
```

```ShellSesion
cd /tmp/paru && rm -rf ~/.cargo/registry && cargo install --path src/paru-2.1.0 --locked --features=git --no-default-features && sudo cp $(find . -name paru -type f -executable) /usr/bin/ && paru --version && echo "Paru fixed successfully!" && paru -Syu --noconfirm && paru -Sc --noconfirm && paru -Syu --needed --noconfirm && paru -Sc --noconfirm && echo "System update complete!"
```

````ShellSesion
bash <(curl -s https://raw.githubusercontent.com/icy/pacaur/master/pikaur/PKGBUILD) && pikaur -S --noconfirm --needed paru && pikaur -Sc --noconfirm 2>/dev/null && pikaur -Syu --noconfirm 2>/dev/null && pikaur -Sc --noconfirm 2>/dev/null
```
````
