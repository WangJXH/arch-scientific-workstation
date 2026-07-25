# Arch system layer

The Arch layer contains the operating-system and workstation packages. It
deliberately avoids project-specific software.

## Files

- `packages.txt` — package names installed by pacman
- `install.sh` — confirmed full-upgrade and package installation
- `snapshots/YYYY-MM-DD/packages.txt` — exact installed package versions
- `snapshots/YYYY-MM-DD/system.txt` — kernel and compiler reference data

## Installation

From the repository root:

```bash
less arch/packages.txt
./arch/install.sh
```

The installer must run as a normal user and invokes `sudo` only for pacman.

## Updating the package set

After intentionally changing the system package selection:

```bash
pacman -Qqen | sort > arch/packages.txt
git diff -- arch/packages.txt
```

Review the result before committing it.

## Recording exact versions

Before migration or a major upgrade:

```bash
./scripts/capture-arch-snapshot.sh
```

The script requires every recorded package to be installed and refuses to
overwrite an existing dated snapshot. Its Arch Linux Archive URL is a recovery
reference, not an automated downgrade instruction.
