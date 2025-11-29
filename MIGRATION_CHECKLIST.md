# NixOS Migration Checklist

**Quick Reference:** Use this checklist alongside MIGRATION_LOG.md  
**How to Use:** Check off items as you complete them, update MIGRATION_LOG.md with details

---

## Phase 0: Preparation & Backup (2 hours)

### 0.1: Backup Current System
- [ ] Create backup branch: `git checkout -b ansible-backup`
- [ ] Push backup branch: `git push -u origin ansible-backup`
- [ ] Tag current state: `git tag -a pre-nix-migration -m "Pre-migration state"`
- [ ] Push tags: `git push --tags`
- [ ] Export Homebrew packages: `brew list > ~/Desktop/brew-backup.txt` (macOS)
- [ ] Verify backup branch on GitHub

### 0.2: Create Migration Tracking
- [ ] Create `MIGRATION_LOG.md` (already exists from this session)
- [ ] Create `MIGRATION_CHECKLIST.md` (this file)
- [ ] Create migration branch: `git checkout -b nix-migration`
- [ ] Fill in start date in MIGRATION_LOG.md

### 0.3: Install Nix on macOS
- [ ] Run installer: `sh <(curl -L https://nixos.org/nix/install) --daemon`
- [ ] Restart terminal
- [ ] Verify: `nix --version` (should be >= 2.18)
- [ ] Create config dir: `mkdir -p ~/.config/nix`
- [ ] Enable flakes: `echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf`
- [ ] Restart terminal again

### 0.4: Test Nix Basic Functionality
- [ ] Test flakes: `nix flake show github:nix-community/home-manager`
- [ ] Test shell: `nix shell nixpkgs#hello --command hello`
- [ ] Test build: `nix build nixpkgs#hello`
- [ ] Verify all three commands work

### Phase 0 Completion
- [ ] Update MIGRATION_LOG.md Phase 0 section
- [ ] Mark Phase 0 as complete in status table
- [ ] Commit tracking files: `git add MIGRATION_LOG.md MIGRATION_CHECKLIST.md`
- [ ] Commit: `git commit -m "Phase 0 complete: Preparation and Nix installation"`

---

## Phase 1: Foundation - Create Nix Structure (4 hours)

### 1.1: Create Directory Structure
- [ ] `cd ~/dotfiles`
- [ ] `mkdir -p hosts/nixos-desktop`
- [ ] `mkdir -p hosts/darwin`
- [ ] `mkdir -p hosts/wsl`
- [ ] `mkdir -p home/programs`
- [ ] `mkdir -p configs`
- [ ] `mkdir -p modules overlays`
- [ ] Verify structure: `tree -L 2` or `ls -R`

### 1.2: Move Existing Configs
- [ ] `cp -r neovim configs/`
- [ ] `cp -r opencode configs/`
- [ ] `cp -r ghostty configs/`
- [ ] `cp -r tmux configs/`
- [ ] Verify copies exist in `configs/`
- [ ] **DO NOT DELETE** originals yet

### 1.3: Create Minimal flake.nix
- [ ] Create `flake.nix` (copy from NIX_MIGRATION_GUIDE.md)
- [ ] Update username in flake (search for "chris", replace with yours)
- [ ] Update hostname for macOS (e.g., "macbook")
- [ ] Test parse: `nix flake show`
- [ ] Test metadata: `nix flake metadata`

### 1.4: Create Home Manager Minimal Config
- [ ] Create `home/default.nix`
- [ ] Set your username
- [ ] Set your home directory
- [ ] Set state version to "24.05"
- [ ] Add: `programs.home-manager.enable = true;`

### 1.5: Test Flake Build
- [ ] Run: `nix flake check`
- [ ] Fix any errors
- [ ] Run: `nix build .#homeConfigurations.YOUR_USERNAME.activationPackage`
- [ ] Verify build succeeds

### Phase 1 Completion
- [ ] Update MIGRATION_LOG.md Phase 1 section
- [ ] Mark Phase 1 as complete
- [ ] Commit: `git add flake.nix flake.lock home/`
- [ ] Commit: `git commit -m "Phase 1: Create basic Nix structure"`
- [ ] Tag: `git tag -a phase-1-complete -m "Nix structure created"`
- [ ] Push: `git push origin nix-migration --tags`

---

## Phase 2: Core Configuration Migration (8 hours) ✅ COMPLETE

### 2.1: Create packages.nix
- [x] Create `home/packages.nix`
- [x] Copy package list from `ansible/group_vars/all.yml`
- [x] Convert YAML to Nix syntax
- [x] Add core packages (git, curl, wget, etc.)
- [x] Add CLI tools (ripgrep, fd, bat, eza, etc.)
- [x] Add language runtimes (nodejs, bun, etc.)
- [x] Test build: `nix build .#homeConfigurations.YOUR_USERNAME.activationPackage`

### 2.2: Create Shell Configuration
- [x] Create `home/programs/zsh.nix`
- [x] Configure oh-my-zsh
- [x] Enable autosuggestions
- [x] Enable syntax highlighting
- [x] Add aliases (ls→eza, cat→bat, etc.)
- [x] Add shell initialization
- [x] Import in `home/default.nix`
- [x] Test build

### 2.3: Create Starship Configuration
- [x] Create `home/programs/starship.nix`
- [x] Enable starship
- [x] Configure prompt format
- [x] Configure git indicators
- [x] Configure language indicators
- [x] Import in `home/default.nix`
- [x] Test build

### 2.4: Create Git Configuration
- [x] Create `home/programs/git.nix`
- [x] Set your name
- [x] Set your email
- [x] Configure delta for diffs
- [x] Add git aliases
- [x] Configure GitHub CLI (gh)
- [x] Import in `home/default.nix`
- [x] Test build

### 2.5: Create Tmux Configuration
- [x] Create `home/programs/tmux.nix`
- [x] Set terminal type
- [x] Configure truecolor support
- [x] Set mouse mode, vi mode
- [x] Add extra config from `tmux/.tmux.conf`
- [x] Import in `home/default.nix`
- [x] Test build

### 2.6: Create Neovim Configuration
- [x] Create `home/programs/neovim.nix`
- [x] Enable neovim
- [x] Add LSP servers to extraPackages
- [x] Add formatters to extraPackages
- [x] Add symlink to existing config: `xdg.configFile."nvim".source`
- [x] Import in `home/default.nix`
- [x] Test build

### 2.7: Create FZF Configuration
- [x] Create `home/programs/fzf.nix`
- [x] Enable fzf
- [x] Configure with fd integration
- [x] Import in `home/default.nix`
- [x] Test build

### 2.8: Create Direnv Configuration
- [x] Create `home/programs/direnv.nix`
- [x] Enable direnv
- [x] Enable nix-direnv
- [x] Import in `home/default.nix`
- [x] Test build

### 2.9: Update home/default.nix
- [x] Import all program modules
- [x] Import packages.nix
- [x] Set session variables (EDITOR, VISUAL)
- [x] Enable XDG directories
- [x] Add symlinks for opencode, ghostty configs
- [x] Test build one final time

### 2.10: **ACTIVATE HOME MANAGER** 🚀
- [x] **CRITICAL:** Commit all changes first!
- [x] Run: `nix run home-manager/master -- switch --flake .#chrisloidolt -b backup`
- [x] Watch for errors
- [x] **Close and reopen terminal**

### 2.11: Validate Activation
- [x] Terminal opens without errors
- [x] Run: `echo $SHELL` (shows /bin/zsh configured via Home Manager)
- [x] Run: `which nvim` (shows ~/.nix-profile/bin/nvim)
- [x] Test: `nvim --version` (v0.11.5)
- [x] Test: `tmux -V` (v3.6)
- [x] Test: `git --version` (v2.51.2)
- [x] Check starship prompt appears ✨
- [x] Test aliases: `ls`→eza, `cat`→bat
- [x] Zoxide initialized and working
- [x] All programs working perfectly

### Phase 2 Completion
- [x] Update MIGRATION_LOG.md Phase 2 section
- [x] Mark Phase 2 as complete
- [ ] Commit final Phase 2 updates
- [ ] Tag: `git tag -a phase-2-complete -m "Home Manager working on macOS"`
- [ ] Push: `git push origin nix-migration --tags`

---

## Phase 3: NixOS Test Environment (6 hours)

### 3.1: Download NixOS ISO
- [ ] Visit https://nixos.org/download
- [ ] Download minimal ISO (x86_64 or aarch64)
- [ ] Verify checksum
- [ ] Note ISO version in MIGRATION_LOG.md

### 3.2: Create VM
**VirtualBox Users:**
- [ ] Create new VM: "NixOS Test"
- [ ] Type: Linux, Version: Other Linux (64-bit)
- [ ] RAM: 4096 MB (or 8192 MB)
- [ ] Create virtual disk: 30 GB, VDI, dynamically allocated
- [ ] Settings → System → Enable EFI
- [ ] Settings → Storage → Attach ISO to optical drive
- [ ] Start VM

**UTM Users (macOS ARM):**
- [ ] Create new VM
- [ ] Choose "Virtualize"
- [ ] Select Linux
- [ ] Use downloaded ARM ISO
- [ ] RAM: 4096 MB
- [ ] Disk: 30 GB
- [ ] Start VM

### 3.3: Install NixOS Manually in VM
- [ ] Boot from ISO
- [ ] Set root password: `sudo passwd`
- [ ] Partition disk (commands in NIX_MIGRATION_GUIDE.md)
- [ ] Format partitions (ext4 for root, fat32 for boot)
- [ ] Mount filesystems
- [ ] Generate config: `sudo nixos-generate-config --root /mnt`
- [ ] Edit config to enable flakes
- [ ] Run: `sudo nixos-install`
- [ ] Set root password when prompted
- [ ] Reboot: `reboot`

### 3.4: Clone Dotfiles in VM
- [ ] Boot into installed system
- [ ] Log in as root
- [ ] Install git: `nix-shell -p git`
- [ ] Clone dotfiles: `git clone https://github.com/YOUR_USERNAME/dotfiles /root/dotfiles`
- [ ] Copy hardware config: `cp /etc/nixos/hardware-configuration.nix /root/dotfiles/hosts/nixos-desktop/`

### 3.5: Create NixOS Configuration
- [ ] Create `hosts/common.nix` (from NIX_MIGRATION_GUIDE.md)
- [ ] Create `hosts/nixos-desktop/default.nix` (from guide)
- [ ] Update timezone in common.nix
- [ ] Update username in nixos-desktop/default.nix
- [ ] Review hardware-configuration.nix

### 3.6: Test and Activate NixOS Config
- [ ] Test build: `nixos-rebuild build --flake /root/dotfiles#desktop`
- [ ] Fix any errors
- [ ] Activate: `sudo nixos-rebuild switch --flake /root/dotfiles#desktop`
- [ ] Reboot: `reboot`

### 3.7: Validate VM Installation
- [ ] VM boots to KDE login screen
- [ ] Log in with user account
- [ ] Terminal (Konsole) opens
- [ ] Zsh with starship prompt works
- [ ] Neovim works: `nvim --version`
- [ ] Tmux works: `tmux -V`
- [ ] Docker works: `docker --version`
- [ ] Firefox launches
- [ ] Test rebuild: `sudo nixos-rebuild switch --flake ~/dotfiles#desktop`

### Phase 3 Completion
- [ ] Update MIGRATION_LOG.md Phase 3 section
- [ ] Document VM specs
- [ ] Mark Phase 3 as complete
- [ ] Commit hardware config: `git add hosts/nixos-desktop/`
- [ ] Commit: `git commit -m "Phase 3 complete: NixOS tested in VM"`
- [ ] Tag: `git tag -a phase-3-complete -m "NixOS VM working"`
- [ ] Push: `git push origin nix-migration --tags`

---

## Phase 4: NixOS Production Installation (3 hours)

### ⚠️ PRE-INSTALLATION CRITICAL CHECKS ⚠️
- [ ] **ALL DATA BACKED UP** from target machine
- [ ] Backup verified and can be restored
- [ ] Have rescue USB ready (Ubuntu Live or SystemRescue)
- [ ] Know WiFi password (if using wireless)
- [ ] Have phone/tablet with this guide available
- [ ] Dotfiles committed and pushed to GitHub
- [ ] Identified correct target disk (e.g., /dev/nvme0n1)
- [ ] **TRIPLE CHECK** disk identifier!

### 4.1: Create Bootable NixOS USB
**macOS:**
- [ ] Insert USB drive
- [ ] Find disk: `diskutil list`
- [ ] Unmount: `diskutil unmountDisk /dev/diskX`
- [ ] Write ISO: `sudo dd if=nixos.iso of=/dev/rdiskX bs=4m status=progress`
- [ ] Eject: `diskutil eject /dev/diskX`

**Linux:**
- [ ] Insert USB drive
- [ ] Find disk: `lsblk`
- [ ] Write ISO: `sudo dd if=nixos.iso of=/dev/sdX bs=4M status=progress`
- [ ] Sync: `sync`

### 4.2: Boot Target Machine
- [ ] Insert USB into target machine
- [ ] Power on and enter BIOS (F2/F12/Del)
- [ ] Disable Secure Boot (if enabled)
- [ ] Set USB as first boot device
- [ ] Save and reboot
- [ ] Boot to NixOS installer

### 4.3: Partition Real Hardware
- [ ] Connect to internet (ethernet or `sudo systemctl start wpa_supplicant`)
- [ ] Set root password: `sudo passwd`
- [ ] Identify disk: `lsblk` (note the disk name!)
- [ ] **VERIFY CORRECT DISK!**
- [ ] Partition disk (commands in NIX_MIGRATION_GUIDE.md)
- [ ] Format partitions
- [ ] Mount filesystems

### 4.4: Generate Hardware Config
- [ ] Generate: `sudo nixos-generate-config --root /mnt`
- [ ] Review: `cat /mnt/etc/nixos/hardware-configuration.nix`
- [ ] Note any special hardware (NVIDIA GPU, etc.)

### 4.5: Clone Dotfiles and Install
- [ ] Install git: `nix-shell -p git`
- [ ] Create home dir: `sudo mkdir -p /mnt/home/YOUR_USERNAME`
- [ ] Clone: `sudo git clone https://github.com/YOUR_USERNAME/dotfiles /mnt/home/YOUR_USERNAME/dotfiles`
- [ ] Copy hardware config: `sudo cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/YOUR_USERNAME/dotfiles/hosts/nixos-desktop/`
- [ ] Fix ownership: `sudo chown -R 1000:1000 /mnt/home/YOUR_USERNAME`
- [ ] Install: `sudo nixos-install --flake /mnt/home/YOUR_USERNAME/dotfiles#desktop`
- [ ] Set root password when prompted
- [ ] Set user password when prompted
- [ ] Reboot: `reboot`

### 4.6: First Boot Validation
- [ ] Remove USB drive
- [ ] System boots to KDE
- [ ] Log in with user account
- [ ] Network/WiFi works
- [ ] Terminal opens (Konsole)
- [ ] All programs work
- [ ] Docker works
- [ ] Test rebuild: `sudo nixos-rebuild switch --flake ~/dotfiles#desktop`

### 4.7: Commit Hardware Config
- [ ] `cd ~/dotfiles`
- [ ] `git add hosts/nixos-desktop/hardware-configuration.nix`
- [ ] `git commit -m "Add production hardware configuration"`
- [ ] `git push origin nix-migration`

### Phase 4 Completion
- [ ] Update MIGRATION_LOG.md Phase 4 section
- [ ] Document hardware details
- [ ] Mark Phase 4 as complete
- [ ] Tag: `git tag -a phase-4-complete -m "NixOS production installation"`
- [ ] Push: `git push origin nix-migration --tags`

---

## Phase 5: WSL2 Setup (3 hours)

### 5.1: Enable WSL2 on Windows
- [ ] Open PowerShell as Administrator
- [ ] Run: `wsl --install`
- [ ] Reboot if prompted
- [ ] Verify: `wsl --status`
- [ ] Ensure WSL version is 2

### 5.2: Download NixOS-WSL
- [ ] Visit https://github.com/nix-community/NixOS-WSL/releases
- [ ] Download latest `nixos-wsl.tar.gz`
- [ ] Note version in MIGRATION_LOG.md

### 5.3: Import NixOS into WSL
- [ ] Open PowerShell
- [ ] Run: `wsl --import NixOS $env:USERPROFILE\NixOS nixos-wsl.tar.gz`
- [ ] Wait for import to complete
- [ ] Start: `wsl -d NixOS`

### 5.4: Configure NixOS-WSL User
- [ ] Inside WSL, become root: `sudo -i`
- [ ] Edit: `nano /etc/nixos/configuration.nix`
- [ ] Set `wsl.defaultUser = "YOUR_USERNAME";`
- [ ] Rebuild: `nixos-rebuild switch`
- [ ] Exit: `exit` (twice)
- [ ] Restart WSL: `wsl -d NixOS -u YOUR_USERNAME`

### 5.5: Clone Dotfiles and Apply Config
- [ ] `git clone https://github.com/YOUR_USERNAME/dotfiles ~/dotfiles`
- [ ] `cd ~/dotfiles`
- [ ] Create `hosts/wsl/default.nix` if not exists
- [ ] Test build: `sudo nixos-rebuild build --flake .#wsl`
- [ ] Apply: `sudo nixos-rebuild switch --flake .#wsl`
- [ ] Exit and restart WSL

### 5.6: Validate WSL Setup
- [ ] WSL starts without errors
- [ ] Zsh with starship prompt
- [ ] Neovim works
- [ ] Git works
- [ ] Can access Windows: `ls /mnt/c/`
- [ ] Docker works (or Docker Desktop integration)
- [ ] Test rebuild: `sudo nixos-rebuild switch --flake ~/dotfiles#wsl`

### Phase 5 Completion
- [ ] Update MIGRATION_LOG.md Phase 5 section
- [ ] Mark Phase 5 as complete
- [ ] Commit: `git add hosts/wsl/`
- [ ] Commit: `git commit -m "Phase 5 complete: WSL2 with NixOS"`
- [ ] Tag: `git tag -a phase-5-complete -m "WSL2 working"`
- [ ] Push: `git push origin nix-migration --tags`

---

## Phase 6: Validation & Cleanup (3 hours)

### 6.1: Create Validation Script
- [ ] Create `scripts/validate-nix.sh`
- [ ] Make executable: `chmod +x scripts/validate-nix.sh`
- [ ] Test on current platform

### 6.2: Run Validation on All Platforms
**macOS:**
- [ ] Run `./scripts/validate-nix.sh`
- [ ] All checks pass
- [ ] Document results in MIGRATION_LOG.md

**NixOS:**
- [ ] Run `./scripts/validate-nix.sh`
- [ ] All checks pass
- [ ] Document results

**WSL2:**
- [ ] Run `./scripts/validate-nix.sh`
- [ ] All checks pass
- [ ] Document results

### 6.3: Archive Ansible Configuration
- [ ] `mkdir -p legacy`
- [ ] `git mv ansible legacy/`
- [ ] `git mv bootstrap.sh legacy/`
- [ ] `git mv install.sh legacy/install-ansible.sh`
- [ ] Commit: `git commit -m "Archive Ansible to legacy/"`

### 6.4: Update README.md
- [ ] Remove Ansible setup instructions
- [ ] Add Nix installation instructions
- [ ] Add rebuild commands for each platform
- [ ] Link to new documentation
- [ ] Update "What Gets Installed" section
- [ ] Update troubleshooting section

### 6.5: Create Quick Start Documentation
- [ ] Create `docs/NIX_QUICK_START.md`
- [ ] Add rebuild commands
- [ ] Add common tasks
- [ ] Add troubleshooting

### Phase 6 Completion
- [ ] Update MIGRATION_LOG.md Phase 6 section
- [ ] Mark Phase 6 as complete
- [ ] Commit: `git add .`
- [ ] Commit: `git commit -m "Phase 6 complete: Validation and cleanup"`
- [ ] Tag: `git tag -a phase-6-complete -m "Validation complete"`
- [ ] Push: `git push origin nix-migration --tags`

---

## Phase 7: Documentation & Polish (3 hours)

### 7.1: Create Comprehensive Documentation
- [ ] Create `docs/NIX_ARCHITECTURE.md`
- [ ] Create `docs/ADDING_PACKAGES.md`
- [ ] Create `docs/TROUBLESHOOTING.md`
- [ ] Create `docs/PER_PROJECT_ENVS.md`
- [ ] Review all docs for completeness

### 7.2: Optimize Nix Settings
- [ ] Add better caching to `hosts/common.nix`
- [ ] Enable parallel builds
- [ ] Configure garbage collection
- [ ] Test rebuild with optimizations

### 7.3: Create Helper Scripts
- [ ] Create `scripts/rebuild.sh` (smart platform detection)
- [ ] Make executable: `chmod +x scripts/rebuild.sh`
- [ ] Test on current platform
- [ ] Create `scripts/update.sh` (update flake inputs)
- [ ] Make executable: `chmod +x scripts/update.sh`

### 7.4: Final Git Cleanup
- [ ] Review all files in repo
- [ ] Remove any leftover test files
- [ ] Ensure .gitignore is complete
- [ ] Final commit: `git commit -m "Phase 7 complete: Documentation and polish"`

### 7.5: Merge to Main
- [ ] `git checkout main`
- [ ] `git merge nix-migration`
- [ ] Resolve any conflicts
- [ ] Test rebuild on main branch
- [ ] `git tag -a v2.0.0 -m "Complete Nix migration"`
- [ ] `git push origin main --tags`

### Phase 7 Completion
- [ ] Update MIGRATION_LOG.md Phase 7 section
- [ ] Mark Phase 7 as complete
- [ ] Fill in "Migration Complete" section in MIGRATION_LOG.md
- [ ] Celebrate! 🎉

---

## Post-Migration Maintenance

### Weekly
- [ ] Update flake inputs: `nix flake update`
- [ ] Rebuild and test
- [ ] Commit updated flake.lock

### Monthly
- [ ] Clean old generations: `sudo nix-collect-garbage --delete-older-than 30d`
- [ ] Optimize store: `nix-store --optimise`
- [ ] Review and update documentation

### As Needed
- [ ] Add new packages to `home/packages.nix`
- [ ] Update program configurations
- [ ] Test changes before committing
- [ ] Keep MIGRATION_LOG.md as reference

---

## Quick Commands Reference

```bash
# Rebuild current system
./scripts/rebuild.sh

# Update all packages
nix flake update && ./scripts/rebuild.sh

# Rollback (NixOS)
sudo nixos-rebuild switch --rollback

# Rollback (Home Manager)
home-manager generations
/nix/store/HASH/activate

# Clean old generations
sudo nix-collect-garbage --delete-older-than 30d

# Optimize Nix store
nix-store --optimise

# Search for packages
nix search nixpkgs PACKAGE_NAME
```
