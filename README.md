# Arch workstation profile

A reusable Arch Linux command-line workstation configuration for development,
writing, and scientific computing. It installs a reviewed package set, links
Bash/Vim/tmux configuration, restores pinned editor plugins, and verifies the
result.

This public edition intentionally excludes credentials, personal hostnames,
research projects, private repositories, and machine-specific software.

## Quick start

Read [`START-HERE.md`](START-HERE.md), then preview and run the complete
bootstrap:

```bash
./scripts/bootstrap-workstation.sh --dry-run
./scripts/bootstrap-workstation.sh
```

The bootstrap runs the Arch package, dotfile, plugin, and verification stages
in order. Use `--skip-packages` when the system package layer is already ready.
The Arch stage performs a full upgrade and invokes `sudo`; review
`arch/packages.txt` first. Existing dotfiles are backed up under
`~/.local/state/linux-profile/backups/`. Each stage can also be run separately
for troubleshooting or selective installation.

## Layout

- `arch/` — Arch package list, installer, and exact-version snapshots
- `common/bash/` — generic interactive Bash configuration
- `common/vim/` — Vim configuration and pinned plugins
- `common/tmux/` — tmux configuration and pinned plugins
- `scripts/` — complete bootstrap, previewable installers, verification, and
  snapshot tools

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
