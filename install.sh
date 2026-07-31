#!/usr/bin/env bash

set -euo pipefail

adopt=false
desktop=false

for argument in "$@"; do
    case "$argument" in
        --adopt)
            adopt=true
            ;;
        --desktop)
            desktop=true
            ;;
        --help|-h)
            printf '%s\n' 'Usage: bash install.sh [--adopt] [--desktop]'
            exit 0
            ;;
        *)
            printf 'Unknown option: %s\n' "$argument" >&2
            exit 1
            ;;
    esac
done

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
backup_dir=""

link_file() {
    local source="$1"
    local target="$2"
    local relative_target

    if [[ -L "$target" && "$(readlink -f -- "$target")" == "$(readlink -f -- "$source")" ]]; then
        printf 'Already linked: %s\n' "$target"
        return
    fi

    if [[ -e "$target" || -L "$target" ]]; then
        if [[ "$adopt" != true ]]; then
            printf 'Refusing to replace existing path: %s\n' "$target" >&2
            printf '%s\n' 'Run again with --adopt to back it up and create the link.' >&2
            exit 1
        fi

        if [[ -z "$backup_dir" ]]; then
            backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
        fi

        relative_target="${target#$HOME/}"
        mkdir -p -- "$backup_dir/$(dirname -- "$relative_target")"
        mv -- "$target" "$backup_dir/$relative_target"
        printf 'Backed up: %s\n' "$target"
    fi

    mkdir -p -- "$(dirname -- "$target")"
    ln -s -- "$source" "$target"
    printf 'Linked: %s\n' "$target"
}

link_file "$repo_dir/nvim" "$HOME/.config/nvim"
link_file "$repo_dir/opencode" "$HOME/.config/opencode"
link_file "$repo_dir/tmux/tmux.conf" "$HOME/.tmux.conf"
link_file "$repo_dir/shell/bashrc" "$HOME/.bashrc"
link_file "$repo_dir/shell/bash_profile" "$HOME/.bash_profile"

if [[ "$desktop" == true ]]; then
    link_file "$repo_dir/ghostty/config" "$HOME/.config/ghostty/config"
fi

if [[ -n "$backup_dir" ]]; then
    printf 'Backups are in: %s\n' "$backup_dir"
fi
