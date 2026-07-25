#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

pass() {
    printf 'PASS: %s\n' "$*"
    ((PASS_COUNT += 1))
}

warn() {
    printf 'WARN: %s\n' "$*"
    ((WARN_COUNT += 1))
}

fail() {
    printf 'FAIL: %s\n' "$*"
    ((FAIL_COUNT += 1))
}

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        pass "command available: $1"
    else
        fail "command missing: $1"
    fi
}

check_link() {
    local source_path="$1"
    local target_path="$2"

    if [[ ! -L "${target_path}" ]]; then
        warn "not linked: ${target_path}"
    elif [[ "$(readlink -f "${target_path}")" == "$(readlink -f "${source_path}")" ]]; then
        pass "dotfile linked: ${target_path}"
    else
        fail "wrong link: ${target_path} -> $(readlink "${target_path}")"
    fi
}

check_plugin_lock() {
    local lock_file="$1"
    local destination_root="$2"
    local name repository commit destination current_commit changes

    while IFS=$'\t' read -r name repository commit; do
        [[ -n "${name}" && "${name}" != \#* ]] || continue
        destination="${destination_root}/${name}"

        if [[ ! -d "${destination}/.git" ]]; then
            fail "plugin missing: ${destination}"
            continue
        fi

        current_commit="$(git -C "${destination}" rev-parse HEAD)"
        if [[ "${current_commit}" == "${commit}" ]]; then
            pass "plugin revision: ${name}"
        else
            fail "plugin revision differs: ${name}"
        fi

        changes="$(
            git -C "${destination}" status --porcelain --untracked-files=all |
                sed '/^?? doc\/tags$/d'
        )"
        if [[ -n "${changes}" ]]; then
            warn "plugin has local changes: ${name}"
        fi
    done < "${lock_file}"
}

printf 'System commands\n'
for command_name in bash git vim tmux; do
    check_command "${command_name}"
done

printf '\nArch system layer\n'
if command -v pacman >/dev/null 2>&1; then
    missing_packages=()
    while IFS= read -r package_name; do
        [[ -n "${package_name}" && "${package_name}" != \#* ]] || continue
        if ! pacman -Q "${package_name}" >/dev/null 2>&1; then
            missing_packages+=("${package_name}")
        fi
    done < "${ROOT}/arch/packages.txt"

    if [[ ${#missing_packages[@]} -eq 0 ]]; then
        pass "all recorded Arch packages are installed"
    else
        warn "missing Arch packages: ${missing_packages[*]}"
    fi
else
    warn "pacman unavailable; Arch package verification skipped"
fi

printf '\nDotfiles\n'
check_link "${ROOT}/common/bash/.bashrc" "${HOME}/.bashrc"
check_link "${ROOT}/common/bash/.bash_aliases" "${HOME}/.bash_aliases"
check_link "${ROOT}/common/vim/.vimrc" "${HOME}/.vimrc"
check_link "${ROOT}/common/tmux/.tmux.conf" "${HOME}/.tmux.conf"

printf '\nPlugins\n'
check_plugin_lock "${ROOT}/common/vim/plugins.lock" "${HOME}/.vim/bundle"
check_plugin_lock "${ROOT}/common/tmux/plugins.lock" "${HOME}/.tmux/plugins"

printf '\nRepository\n'
if [[ -n "$(git -C "${ROOT}" status --short)" ]]; then
    warn "Git worktree has uncommitted changes"
else
    pass "Git worktree is clean"
fi

printf '\nSummary: %d passed, %d warnings, %d failures\n' \
    "${PASS_COUNT}" "${WARN_COUNT}" "${FAIL_COUNT}"

if [[ ${FAIL_COUNT} -gt 0 ]]; then
    exit 1
fi
