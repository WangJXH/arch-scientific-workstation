#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN=false

usage() {
    cat <<'EOF'
Usage: install-dotfiles.sh [--dry-run]

Create symlinks for the tracked dotfiles. Existing files are moved to a
timestamped backup directory before links are created.
EOF
}

case "${1:-}" in
    "")
        ;;
    --dry-run)
        DRY_RUN=true
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

SOURCES=(
    "${ROOT}/common/bash/.bashrc"
    "${ROOT}/common/bash/.bash_aliases"
    "${ROOT}/common/vim/.vimrc"
    "${ROOT}/common/tmux/.tmux.conf"
)

TARGETS=(
    "${HOME}/.bashrc"
    "${HOME}/.bash_aliases"
    "${HOME}/.vimrc"
    "${HOME}/.tmux.conf"
)

BACKUP_ROOT="${XDG_STATE_HOME:-${HOME}/.local/state}/linux-profile/backups"
BACKUP_DIR="${BACKUP_ROOT}/$(date +%Y%m%d-%H%M%S)"
BACKUP_CREATED=false

for index in "${!SOURCES[@]}"; do
    source_path="${SOURCES[index]}"
    target_path="${TARGETS[index]}"

    if [[ ! -f "${source_path}" ]]; then
        printf 'Error: source file not found: %s\n' "${source_path}" >&2
        exit 1
    fi

    if [[ -L "${target_path}" ]] &&
       [[ "$(readlink -f "${target_path}")" == "$(readlink -f "${source_path}")" ]]; then
        printf 'Unchanged: %s\n' "${target_path}"
        continue
    fi

    if [[ -e "${target_path}" || -L "${target_path}" ]]; then
        backup_path="${BACKUP_DIR}/${target_path#"${HOME}/"}"
        printf 'Backup:    %s -> %s\n' "${target_path}" "${backup_path}"

        if [[ "${DRY_RUN}" == false ]]; then
            mkdir -p "$(dirname "${backup_path}")"
            mv "${target_path}" "${backup_path}"
            BACKUP_CREATED=true
        fi
    fi

    printf 'Link:      %s -> %s\n' "${target_path}" "${source_path}"
    if [[ "${DRY_RUN}" == false ]]; then
        ln -s "${source_path}" "${target_path}"
    fi
done

if [[ "${DRY_RUN}" == true ]]; then
    printf 'Dry run complete; no files were changed.\n'
elif [[ "${BACKUP_CREATED}" == true ]]; then
    printf 'Installation complete. Backups: %s\n' "${BACKUP_DIR}"
else
    printf 'Installation complete. No backups were needed.\n'
fi
