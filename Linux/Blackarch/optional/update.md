### Yay: Update & Clean

```bash
# Cleans the package cache, performs a full system upgrade (allowing downgrades and skipping tests), and cleans the cache again.
yay -Sc --noconfirm && yay -Syuuq --noconfirm --mflags "--nocheck" && yay -Sc --noconfirm

```

### Pacman: Update with Orphan Cleanup

```bash
# Removes orphaned packages, updates the system, and performs a second pass to remove any new orphans created during the update.
if pacman -Qdtq >/dev/null 2>&1; then sudo pacman -Rs --noconfirm $(pacman -Qdtq); fi && sudo pacman -Syu --needed --disable-download-timeout --noprogressbar --noconfirm && if pacman -Qdtq >/dev/null 2>&1; then sudo pacman -Rs --noconfirm $(pacman -Qdtq); fi

```

### Paru: Manual Repair

```bash
# Manually rebuilds Paru from source using Cargo (clearing registry first) and overwrites the system binary to fix a broken installation.
cd /tmp/paru && rm -rf ~/.cargo/registry && cargo install --path src/paru-2.1.0 --locked --features=git --no-default-features && sudo cp $(find . -name paru -type f -executable) /usr/bin/ && paru --version && echo "Paru fixed successfully!"

```

### Pikaur: Installation (Bootstrap)

```bash
# Installs prerequisites, clones Pikaur from AUR to /tmp, builds/installs it, and cleans up the source folder.
sudo pacman -S --needed base-devel git --noconfirm && git clone https://aur.archlinux.org/pikaur.git /tmp/pikaur && cd /tmp/pikaur && makepkg -si --noconfirm && cd ~ && rm -rf /tmp/pikaur

```

### Paru: Update & Clean

```bash
# Updates the system using Paru (skipping package checks/tests) and cleans the package cache multiple times to free space.
paru -Syu --noconfirm --mflags "--nocheck" && paru -Sc --noconfirm && paru -Syu --needed --noconfirm --mflags "--nocheck" && paru -Sc --noconfirm && echo "System update complete!"

```

### Pikaur: Update (No Checks/Tests)

```bash
# Updates the system skipping user confirmation and disabling package validity checks and test suites (faster, but riskier).
pikaur -Syu --noconfirm --makepkg-args="--nocheck"

```
