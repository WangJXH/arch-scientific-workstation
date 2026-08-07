#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN=false
INSTALL_PACKAGES=true

usage() {
    cat <<'EOF'
Usage: bootstrap-workstation.sh [OPTIONS]

Run the public Arch package, dotfile, plugin, and verification stages in order.

Options:
  --dry-run        Preview setup without changing the system
  --skip-packages  Do not run the Arch package installer
  -h, --help       Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            ;;
        --skip-packages)
            INSTALL_PACKAGES=false
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 2
            ;;
    esac
    shift
done

required_scripts=(
    "${ROOT}/arch/install.sh"
    "${ROOT}/scripts/install-dotfiles.sh"
    "${ROOT}/scripts/install-plugins.sh"
    "${ROOT}/scripts/verify-setup.sh"
)
for script in "${required_scripts[@]}"; do
    if [[ ! -x "${script}" ]]; then
        printf 'Error: required script is missing or not executable: %s\n' \
            "${script}" >&2
        exit 1
    fi
done

if [[ "${INSTALL_PACKAGES}" == true ]]; then
    if [[ "${DRY_RUN}" == true ]]; then
        printf 'Would run: %s\n' "${ROOT}/arch/install.sh"
    else
        printf 'Installing Arch packages\n'
        "${ROOT}/arch/install.sh"
    fi
fi

printf '\nInstalling dotfiles\n'
if [[ "${DRY_RUN}" == true ]]; then
    "${ROOT}/scripts/install-dotfiles.sh" --dry-run
else
    "${ROOT}/scripts/install-dotfiles.sh"
fi

printf '\nInstalling plugins\n'
if [[ "${DRY_RUN}" == true ]]; then
    "${ROOT}/scripts/install-plugins.sh" --dry-run
else
    "${ROOT}/scripts/install-plugins.sh"
fi

if [[ "${DRY_RUN}" == true ]]; then
    printf '\nDry run complete; verification was not run.\n'
else
    printf '\nVerifying workstation\n'
    "${ROOT}/scripts/verify-setup.sh"
fi
