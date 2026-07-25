#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SNAPSHOT_DATE="${1:-$(date +%F)}"
OUTPUT_DIR="${ROOT}/arch/snapshots/${SNAPSHOT_DATE}"
PACKAGE_FILE="${ROOT}/arch/packages.txt"

usage() {
    cat <<'EOF'
Usage: capture-arch-snapshot.sh [YYYY-MM-DD]

Record exact versions of the Arch packages listed in arch/packages.txt and
non-identifying system/toolchain information. Existing snapshots are never
overwritten.
EOF
}

if [[ "${SNAPSHOT_DATE}" == "-h" || "${SNAPSHOT_DATE}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ ! "${SNAPSHOT_DATE}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    usage >&2
    exit 2
fi

if [[ "$(date --date="${SNAPSHOT_DATE}" +%F 2>/dev/null || true)" != "${SNAPSHOT_DATE}" ]]; then
    printf 'Error: invalid calendar date: %s\n' "${SNAPSHOT_DATE}" >&2
    exit 2
fi

if ! command -v pacman >/dev/null 2>&1; then
    printf 'Error: pacman is required; this script must run on Arch Linux.\n' >&2
    exit 1
fi

if [[ -e "${OUTPUT_DIR}" ]]; then
    printf 'Error: snapshot already exists: %s\n' "${OUTPUT_DIR}" >&2
    exit 1
fi

mkdir -p "${ROOT}/arch/snapshots"
temporary_dir="$(mktemp -d "${ROOT}/arch/snapshots/.${SNAPSHOT_DATE}.XXXXXX")"
trap 'rm -r "${temporary_dir}"' EXIT

while IFS= read -r package_name; do
    [[ -n "${package_name}" && "${package_name}" != \#* ]] || continue
    if ! pacman -Q "${package_name}"; then
        printf 'Error: recorded package is not installed: %s\n' \
            "${package_name}" >&2
        exit 1
    fi
done < "${PACKAGE_FILE}" > "${temporary_dir}/packages.txt"

{
    printf 'snapshot_date: %s\n' "${SNAPSHOT_DATE}"
    printf 'archive_repository: https://archive.archlinux.org/repos/%s/$repo/os/$arch\n' \
        "${SNAPSHOT_DATE//-//}"
    printf 'architecture: %s\n' "$(uname -m)"
    printf 'kernel: %s\n' "$(uname -r)"
    printf 'gcc: %s\n' "$(gcc --version | sed -n '1p')"
    printf 'g++: %s\n' "$(g++ --version | sed -n '1p')"
    printf 'gfortran: %s\n' "$(gfortran --version | sed -n '1p')"
    printf 'clang: %s\n' "$(clang --version | sed -n '1p')"
    printf 'glibc: %s\n' "$(ldd --version | sed -n '1p')"
} > "${temporary_dir}/system.txt"

mv "${temporary_dir}" "${OUTPUT_DIR}"
trap - EXIT

printf 'Created Arch snapshot: %s\n' "${OUTPUT_DIR}"
