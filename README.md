# Arch workstation profile

A reusable Arch Linux command-line workstation configuration for development,
writing, and scientific computing. It installs a reviewed package set, links
Bash/Vim/tmux configuration, restores pinned editor plugins, and verifies the
result.

This public edition intentionally excludes credentials, personal hostnames,
research projects, private repositories, and machine-specific software.

## Quick start

Read [`START-HERE.md`](START-HERE.md), then preview each change before applying
it:

```bash
./arch/install.sh
./scripts/install-dotfiles.sh --dry-run
./scripts/install-dotfiles.sh
./scripts/install-plugins.sh --dry-run
./scripts/install-plugins.sh
./scripts/verify-setup.sh
```

`arch/install.sh` performs a full Arch upgrade and invokes `sudo`; review
`arch/packages.txt` before running it. Existing dotfiles are backed up under
`~/.local/state/linux-profile/backups/`.

## Layout

- `arch/` — Arch package list, installer, and exact-version snapshots
- `common/bash/` — generic interactive Bash configuration
- `common/vim/` — Vim configuration and pinned plugins
- `common/tmux/` — tmux configuration and pinned plugins
- `scripts/` — previewable installers, verification, and snapshot tools

## Exact-version snapshots

`arch/packages.txt` installs current Arch packages. Before a major upgrade,
record the exact installed versions and toolchain:

```bash
./scripts/capture-arch-snapshot.sh
```

Snapshots under `arch/snapshots/` are comparison and recovery references; the
installer does not automatically downgrade to them.

## Local customization

Keep credentials and private values outside this repository. The Bash
configuration optionally sources:

```text
~/.config/linux-profile/secrets.sh
```

Add machine-specific aliases and project paths locally rather than committing
them to a public fork.
