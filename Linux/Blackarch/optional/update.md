Here is the reorganized list of commands, grouped by the package manager or AUR helper they utilize.

### Pacman

**Update with Orphan Cleanup**
Removes orphaned packages, updates the system, and performs a second pass to remove any new orphans created during the update.

```bash
if pacman -Qdtq >/dev/null 2>&1; then sudo pacman -Rs --noconfirm $(pacman -Qdtq); fi && sudo pacman -Syu --needed --disable-download-timeout --noprogressbar --noconfirm && if pacman -Qdtq >/dev/null 2>&1; then sudo pacman -Rs --noconfirm $(pacman -Qdtq); fi

```

---

### Yay

**Update & Clean**
Cleans the package cache, performs a full system upgrade (allowing downgrades and skipping tests), and cleans the cache again.

```bash
yay -Sc --noconfirm && yay -Syuuq --noconfirm --mflags "--nocheck" && yay -Sc --noconfirm

```

---

### Paru

**Update & Clean**
Updates the system using Paru (skipping package checks/tests) and cleans the package cache multiple times to free space.

```bash
paru -Syu --noconfirm --mflags "--nocheck" && paru -Sc --noconfirm && paru -Syu --needed --noconfirm --mflags "--nocheck" && paru -Sc --noconfirm && echo "System update complete!"

```

**Manual Repair**
Manually rebuilds Paru from source using Cargo (clearing registry first) and overwrites the system binary to fix a broken installation.

```bash
cd /tmp/paru && rm -rf ~/.cargo/registry && cargo install --path src/paru-2.1.0 --locked --features=git --no-default-features && sudo cp $(find . -name paru -type f -executable) /usr/bin/ && paru --version && echo "Paru fixed successfully!"

```

---

### Pikaur

**Installation (Bootstrap)**
Installs prerequisites, clones Pikaur from AUR to `/tmp`, builds/installs it, and cleans up the source folder.

```bash
sudo pacman -S --needed base-devel git --noconfirm && git clone https://aur.archlinux.org/pikaur.git /tmp/pikaur && cd /tmp/pikaur && makepkg -si --noconfirm && cd ~ && rm -rf /tmp/pikaur

```

**Update (No Checks/Tests)**
Updates the system skipping user confirmation and disabling package validity checks and test suites (faster, but riskier).

```bash
pikaur -Syu --noconfirm --makepkg-args="--nocheck"

```

---

Would you like me to add comments inside the code blocks explaining specific flags (like `--nocheck` or `-Qdtq`) for easier reference?
