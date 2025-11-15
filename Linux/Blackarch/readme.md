# BlackArch Installation Script - Enhanced Version
## Issues Fixed from Error Output
### 1. Missing Dependencies
**Problem:** Script failed because required packages were not installed
* `plasma-framework` (required by calamares)
* `jre17-openjdk` (Java runtime for many tools)
* `rust` (Cargo for Rust-based tools)
* `tesseract-data-eng` (OCR data)
* `vagrant` (required by malboxes)
**Solution:** Pre-install all common dependencies in Step 1 and Step 4
### 2. Package Conflicts
**Problem:** Multiple conflicting packages blocked installation
* `python-yara` vs `python-yara-python-dex`
* `python-arsenic` vs `python-wapiti-arsenic`
**Solution:** Automatically remove conflicting packages before installation
### 3. Missing Category
**Problem:** `blackarch-webap` does not exist (typo in original script)
**Solution:** Removed invalid category, kept only valid ones
### 4. Interactive Prompts
**Problem:** Script stopped for user input on:
* Java runtime provider selection (2 options)
* Tesseract data language selection (128 options)
* Cargo provider selection (3 options)
* Skip unresolvable packages prompt
**Solution:** Use `yes ""` to auto-answer with defaults and `--ask 4` flag
### 5. Calamares Dependency Issues
**Problem:** Calamares and blackarch-config-calamares failed without plasma-framework
**Solution:** Conditionally skip these packages if plasma-framework is unavailable
## Key Enhancements
### Auto-Dependency Resolution
```warp-runnable-command
# Installs all required dependencies automatically
- Java Runtime (jre17-openjdk)
- Rust/Cargo
- Tesseract OCR data
- Plasma Framework
- Vagrant (for malboxes)
```
### Conflict Resolution
```warp-runnable-command
# Removes conflicting packages before installation
- python-yara → replaced with python-yara-python-dex
- python-arsenic → replaced with python-wapiti-arsenic
```
### Smart Package Skipping
```warp-runnable-command
# Automatically skips problematic packages
- aws-extender-cli (always problematic)
- calamares (if plasma-framework unavailable)
- blackarch-config-calamares (if plasma-framework unavailable)
- malboxes (if vagrant unavailable)
```
### Progress Tracking
* Visual progress indicators (✓ ⚠ ⊗)
* Real-time category counter ([5/49])
* Installation statistics summary
* Color-coded output for better readability
### Error Handling
* Non-blocking errors (continues on failure)
* Validates category existence before installation
* Tracks success/warning/skip statistics
## Usage
### Run the Enhanced Script
```warp-runnable-command
chmod +x install_blackarch_categories.sh
./install_blackarch_categories.sh
```
### What It Does Automatically
1. Installs Java, Rust, Tesseract, and other dependencies
2. Resolves package conflicts
3. Updates package database
4. Pre-installs commonly needed packages
5. Installs all 49 BlackArch categories
6. Handles all prompts without user input
7. Provides detailed statistics at completion
### Expected Output
```warp-runnable-command
╔════════════════════════════════════════════════════════════╗
║     BlackArch Auto-Installation Script (Enhanced)        ║
╚════════════════════════════════════════════════════════════╝
[1/5] Installing required system dependencies...
[2/5] Resolving package conflicts...
[3/5] Updating package database...
[4/5] Pre-installing commonly required packages...
[5/5] Installing BlackArch categories...
┌─ [1/49] Installing: blackarch
└─ ✓ Success
┌─ [2/49] Installing: blackarch-webapp
└─ ✓ Success
... (continues for all categories)
╔════════════════════════════════════════════════════════════╗
║              Installation Complete!                        ║
╚════════════════════════════════════════════════════════════╝
Installation Statistics:
  ✓ Successful:      45 categories
  ⚠ With warnings:   3 categories
  ⊗ Skipped:         1 categories
```
## Notes
* Installation time: 30-90 minutes depending on internet speed
* Some packages may still fail due to AUR/repository issues
* All errors are logged but don't stop the installation
* You can manually install failed packages later with: `sudo pacman -S <package-name>`
## Troubleshooting
If specific categories fail:
```warp-runnable-command
# Check what's available
pacman -Sg | grep blackarch
# Install specific category manually
sudo pacman -S blackarch-<category>
# Install specific tool
sudo pacman -S <tool-name>
```
