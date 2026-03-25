#!/bin/bash

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     BlackArch Keyring Conflict Fix Script                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

CONFLICTING_FILES=(
    "/usr/share/pacman/keyrings/blackarch-revoked"
    "/usr/share/pacman/keyrings/blackarch-trusted"
    "/usr/share/pacman/keyrings/blackarch.gpg"
)

echo "[1/3] Backing up conflicting keyring files..."
BACKUP_DIR="/tmp/blackarch-keyring-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

for file in "${CONFLICTING_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  → Backing up: $file"
        sudo cp "$file" "$BACKUP_DIR/"
    fi
done

echo "  ✓ Backup saved to: $BACKUP_DIR"
echo ""

echo "[2/3] Removing conflicting files..."
for file in "${CONFLICTING_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  → Removing: $file"
        sudo rm -f "$file"
    fi
done
echo "  ✓ Conflicting files removed"
echo ""

echo "[3/3] Installing/reinstalling blackarch-keyring..."
sudo pacman -S --noconfirm --overwrite '*' blackarch-keyring

if [ $? -eq 0 ]; then
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              Fix Applied Successfully!                     ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "You can now proceed with your package installation."
    echo "Backup location: $BACKUP_DIR"
else
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              Installation Failed                           ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Restoring backup files..."
    for file in "${CONFLICTING_FILES[@]}"; do
        backup_file="$BACKUP_DIR/$(basename $file)"
        if [ -f "$backup_file" ]; then
            sudo cp "$backup_file" "$file"
        fi
    done
    echo "Files restored. Manual intervention may be required."
    exit 1
fi
