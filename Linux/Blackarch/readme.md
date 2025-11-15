```ShellSesion
yay -Sc --noconfirm  && yay -Syuuq --noconfirm && yay -Sc --noconfirm
```

```ShellSesion
paru -Sc --noconfirm  && paru -Syuq --noconfirm && paru -Sc --noconfirm
```

```ShellSesion
if pacman -Qdtq >/dev/null 2>&1; then sudo pacman -Rs --noconfirm $(pacman -Qdtq); fi && sudo pacman -Syu --needed --disable-download-timeout --noprogressbar --noconfirm && if pacman -Qdtq >/dev/null 2>&1; then sudo pacman -Rs --noconfirm $(pacman -Qdtq); fi
```
