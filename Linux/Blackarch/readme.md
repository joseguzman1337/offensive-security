```ShellSesion
yay -Sc --noconfirm  && yay -Syuuq --noconfirm && yay -Sc --noconfirm
```

```ShellSesion
paru -Sc --noconfirm  && paru -Syuq --noconfirm && paru -Sc --noconfirm
```

```ShellSesion
if pacman -Qdtq >/dev/null 2>&1; then sudo pacman -Qdtq | sudo pacman -Rs --noconfirm -; fi && sudo pacman -Syuu --needed --disable-download-timeout --noprogressbar --overwrite --noconfirm && if pacman -Qdtq >/dev/null 2>&1; then sudo pacman -Qdtq | sudo pacman -Rs --noconfirm -; fi
```
