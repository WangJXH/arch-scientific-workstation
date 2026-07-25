#!/usr/bin/env bash
set -e

TPM_DIR="$HOME/.tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
    mkdir -p "$HOME/.tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    git -C "$TPM_DIR" pull
fi
