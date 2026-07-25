# New workstation setup

This repository configures an already installed Arch Linux system. It does not
partition disks, install Arch, configure a bootloader, or create users.

## Requirements

- an updated Arch Linux installation;
- a normal user with `sudo` access;
- Git and a working network connection.

Do not run these scripts as root.

## 1. Clone and review

```bash
git clone <public-repository-url> linux-profile
cd linux-profile
less README.md
less arch/packages.txt
```

## 2. Install system packages

```bash
./arch/install.sh
```

The script shows the package list and asks for confirmation before invoking
`sudo pacman -Syu`.

## 3. Install dotfiles

```bash
./scripts/install-dotfiles.sh --dry-run
./scripts/install-dotfiles.sh
```

Existing targets are moved to a timestamped directory below
`~/.local/state/linux-profile/backups/`. Open a new shell after installation.

## 4. Install pinned plugins

```bash
./scripts/install-plugins.sh --dry-run
./scripts/install-plugins.sh
```

Repositories with local changes are left untouched.

## 5. Verify

```bash
./scripts/verify-setup.sh
```

`PASS` indicates a matching component, `WARN` indicates an optional or
unlinked component, and `FAIL` indicates a required mismatch.

## Before upgrading

```bash
./scripts/capture-arch-snapshot.sh
```

Commit the new `arch/snapshots/YYYY-MM-DD/` directory before changing the
system.

## Recovery

Dotfile backups are stored under:

```text
~/.local/state/linux-profile/backups/
```

To restore one, remove the installed symlink and move the desired backup back
to its original home-directory location.

