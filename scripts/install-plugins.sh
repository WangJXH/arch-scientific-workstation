#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN=false

usage() {
    cat <<'EOF'
Usage: install-plugins.sh [--dry-run]

Install the Vim and tmux plugins recorded in plugins.lock. Existing clean
repositories are moved to their recorded commits; repositories with local
changes are left untouched.
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

if ! command -v git >/dev/null 2>&1; then
    printf 'Error: git is required.\n' >&2
    exit 1
fi

install_plugins() {
    local lock_file="$1"
    local destination_root="$2"
    local name repository commit destination current_commit changes

    while IFS=$'\t' read -r name repository commit; do
        [[ -n "${name}" && "${name}" != \#* ]] || continue
        destination="${destination_root}/${name}"

        if [[ ! -e "${destination}" ]]; then
            printf 'Clone:     %s at %s\n' "${repository}" "${commit}"
            if [[ "${DRY_RUN}" == false ]]; then
                mkdir -p "${destination_root}"
                git clone "${repository}" "${destination}"
                git -C "${destination}" checkout --detach "${commit}"
            fi
            continue
        fi

        if [[ ! -d "${destination}/.git" ]]; then
            printf 'Error: destination is not a Git repository: %s\n' \
                "${destination}" >&2
            return 1
        fi

        changes="$(
            git -C "${destination}" status --porcelain --untracked-files=all |
                sed '/^?? doc\/tags$/d'
        )"
        if [[ -n "${changes}" ]]; then
            printf 'Error: local changes prevent updating %s:\n%s\n' \
                "${destination}" "${changes}" >&2
            return 1
        fi

        current_commit="$(git -C "${destination}" rev-parse HEAD)"
        if [[ "${current_commit}" == "${commit}" ]]; then
            printf 'Unchanged: %s\n' "${destination}"
            continue
        fi

        printf 'Checkout:  %s -> %s\n' "${destination}" "${commit}"
        if [[ "${DRY_RUN}" == false ]]; then
            git -C "${destination}" fetch --tags origin
            git -C "${destination}" checkout --detach "${commit}"
        fi
    done < "${lock_file}"
}

install_plugins \
    "${ROOT}/common/vim/plugins.lock" \
    "${HOME}/.vim/bundle"
install_plugins \
    "${ROOT}/common/tmux/plugins.lock" \
    "${HOME}/.tmux/plugins"

snippet_source="${ROOT}/common/vim/.vim/UltiSnips"
snippet_target="${HOME}/.vim/UltiSnips"

if [[ -L "${snippet_target}" ]] &&
   [[ "$(readlink -f "${snippet_target}")" == "$(readlink -f "${snippet_source}")" ]]; then
    printf 'Unchanged: %s\n' "${snippet_target}"
else
    if [[ -e "${snippet_target}" || -L "${snippet_target}" ]]; then
        backup_dir="${XDG_STATE_HOME:-${HOME}/.local/state}/linux-profile/backups/$(date +%Y%m%d-%H%M%S)-$$"
        backup_path="${backup_dir}/.vim/UltiSnips"
        printf 'Backup:    %s -> %s\n' "${snippet_target}" "${backup_path}"
        if [[ "${DRY_RUN}" == false ]]; then
            mkdir -p "$(dirname "${backup_path}")"
            mv "${snippet_target}" "${backup_path}"
        fi
    fi

    printf 'Link:      %s -> %s\n' "${snippet_target}" "${snippet_source}"
    if [[ "${DRY_RUN}" == false ]]; then
        mkdir -p "$(dirname "${snippet_target}")"
        ln -s "${snippet_source}" "${snippet_target}"
    fi
fi

if [[ "${DRY_RUN}" == true ]]; then
    printf 'Dry run complete; no files were changed.\n'
else
    printf 'Plugin installation complete.\n'
fi
