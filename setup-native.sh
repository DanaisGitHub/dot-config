#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
install_args=()
install_packages=true

for argument in "$@"; do
    case "$argument" in
        --adopt)
            install_args+=(--adopt)
            ;;
        --skip-packages)
            install_packages=false
            ;;
        --help|-h)
            printf '%s\n' 'Usage: bash setup-native.sh [--adopt] [--skip-packages]'
            exit 0
            ;;
        *)
            printf 'Unknown option: %s\n' "$argument" >&2
            exit 1
            ;;
    esac
done

if [[ "$install_packages" == true ]]; then
    if [[ "$(id -u)" -eq 0 ]]; then
        printf '%s\n' 'Run this script as the development user, not root.' >&2
        exit 1
    fi

    if ! command -v dnf >/dev/null 2>&1; then
        printf '%s\n' 'This setup script requires Fedora and dnf.' >&2
        exit 1
    fi

    if ! command -v sudo >/dev/null 2>&1; then
        printf '%s\n' 'sudo is required to install system packages.' >&2
        exit 1
    fi

    sudo dnf install -y \
        bash \
        ca-certificates \
        curl \
        git \
        openssh-clients \
        tmux \
        neovim \
        ripgrep \
        fd-find \
        fzf \
        gcc \
        gcc-c++ \
        make \
        cmake \
        pkgconf-pkg-config \
        openssl-devel \
        libffi-devel \
        golang \
        rust \
        cargo \
        rustfmt \
        nodejs \
        npm \
        python3 \
        python3-pip \
        python3-devel \
        python3-black \
        clang \
        clang-tools-extra \
        clang-format \
        unzip \
        tar \
        gzip \
        bzip2 \
        xz \
        procps-ng \
        findutils \
        which

    bash "$repo_dir/install-opencode.sh"

    if ! command -v prettier >/dev/null 2>&1; then
        sudo npm install --global prettier
    fi
fi

bash "$repo_dir/install.sh" "${install_args[@]}"

mkdir -p "$HOME/.tmux/plugins"
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

(cd "$repo_dir/opencode" && npm ci)

# Install pinned Neovim plugins without updating the tracked lockfile.
nvim --headless '+Lazy! install' '+qa'

printf '%s\n' 'Native development environment is ready.'
