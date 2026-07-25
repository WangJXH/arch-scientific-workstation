#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="${SCRIPT_DIR}/packages.txt"

error() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

if [[ ! -f "${PACKAGE_FILE}" ]]; then
    error "Package list not found: ${PACKAGE_FILE}"
fi

if ! command -v pacman >/dev/null 2>&1; then
    error "pacman was not found. This script must be run on Arch Linux."
fi

if [[ ${EUID} -eq 0 ]]; then
    error "Run this script as a normal user. It will invoke sudo when required."
fi

if ! command -v sudo >/dev/null 2>&1; then
    error "sudo is required."
fi

mapfile -t PACKAGES < <(
    sed         -e 's/[[:space:]]*#.*$//'         -e '/^[[:space:]]*$/d'         "${PACKAGE_FILE}" |
    sort -u
)

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
    error "No packages were found in ${PACKAGE_FILE}"
fi

printf 'Package file: %s\n' "${PACKAGE_FILE}"
printf 'Packages to install: %d\n\n' "${#PACKAGES[@]}"

printf '%s\n' "${PACKAGES[@]}"
printf '\n'

read -r -p "Proceed with a full system upgrade and installation? [y/N] " reply

case "${reply}" in
    y|Y|yes|YES)
        ;;
    *)
        printf 'Installation cancelled.\n'
        exit 0
        ;;
esac

sudo pacman -Syu --needed "${PACKAGES[@]}"

printf '\nInstallation completed successfully.\n'
printf 'To refresh packages.txt later, run:\n'
printf '  pacman -Qqen | sort > %q\n' "${PACKAGE_FILE}"
