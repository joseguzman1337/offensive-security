```ShellSesion
yay -Sc --noconfirm  && yay -Syuuq --noconfirm && yay -Sc --noconfirm 
```

```ShellSesion
paru -Sc --noconfirm  && paru -Syuq --noconfirm && paru -Sc --noconfirm 
```

```ShellSesion
sudo pacman -Qdtq | sudo pacman -Rs --noconfirm - && sudo pacman -Syuu --needed --disable-download-timeout --noprogressbar --overwrite --noconfirm && sudo pacman -Qdtq | sudo pacman -Rs --noconfirm -
```
