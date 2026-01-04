**Update with Orphan Cleanup**
Remove orphaned packages; update system; perform second pass to remove new orphans.

```bash
sudo bash -c 'rm -rf /var/cache/pacman/pkg/download-* /var/cache/pacman/pkg/*.part' && bash -c '(if command -v pacman &> /dev/null; then (if pacman -Qdtq >/dev/null 2>&1; then sudo pacman -Rs --noconfirm $(pacman -Qdtq) 2> /dev/null; fi && sudo pacman -Syu --needed --disable-download-timeout --noconfirm 2> /dev/null && if pacman -Qdtq >/dev/null 2>&1; then sudo pacman -Rs --noconfirm $(pacman -Qdtq) 2> /dev/null; fi); fi) && (if command -v yay &> /dev/null; then yay -Sc --noconfirm 2> /dev/null && yay -Syuuq --noconfirm --answerclean=All --answerdiff=None --mflags "--nocheck" 2> /dev/null && yay -Sc --noconfirm 2> /dev/null; fi) && (if command -v paru &> /dev/null; then paru -Syu --noconfirm --mflags "--nocheck" 2> /dev/null && paru -Sc --noconfirm 2> /dev/null && paru -Syu --needed --noconfirm --mflags "--nocheck" 2> /dev/null && paru -Sc --noconfirm 2> /dev/null; fi) && (if command -v pikaur &> /dev/null; then pikaur -Syu --noconfirm --makepkg-args="--nocheck" 2> /dev/null; fi) && echo "All updates complete!"'

```
