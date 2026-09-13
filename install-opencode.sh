#!/usr/bin/env bash

set -euo pipefail

# Keep both development machines on the same tested release.
version=2.0.3
binary="$HOME/.opencode/bin/opencode"

installed_version() {
    local output
    output="$("$binary" --version)"
    output="${output##* }"
    printf '%s\n' "${output#v}"
}

if [[ "$(id -u)" -eq 0 ]]; then
    printf '%s\n' 'Run this installer as the development user, not root.' >&2
    exit 1
fi

if [[ ! -x "$binary" ]] || [[ "$(installed_version)" != "$version" ]]; then
    installer="$(mktemp)"
    trap 'rm -f -- "$installer"' EXIT
    curl --fail --silent --show-error --location \
        https://opencode.ai/v2/install --output "$installer"
    bash "$installer" --version "$version" --no-modify-path
fi

actual_version="$(installed_version)"
if [[ "$actual_version" != "$version" ]]; then
    printf 'Expected OpenCode %s, found %s\n' "$version" "$actual_version" >&2
    exit 1
fi

printf 'OpenCode %s installed at %s\n' "$actual_version" "$binary"
printf '%s\n' 'Start a new shell (or run hash -r) and restart OpenCode.'
