```ShellSesion
yay -Sc && yay -Syuuq --noconfirm && yay -Sc
```

```ShellSesion
paru -Sc && paru -Syuq --noconfirm && paru -Sc
```

```ShellSesion
sudo pacman -Qdtq | sudo pacman -Rs - && sudo pacman -Syuu --needed --disable-download-timeout --noprogressbar --overwrite --noconfirm && sudo pacman -Qdtq | sudo pacman -Rs -
```
