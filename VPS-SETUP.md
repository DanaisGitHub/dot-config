# VPS Development Environment

Last updated: 2026-07-31

## Goal

Use the VPS as a remote development machine:

```text
Ghostty on laptop -> SSH as dev -> Docker container -> tmux -> Neovim/OpenCode
```

The host account is `dev`. The container will provide the development tools while project files and configuration remain persistent outside the image.

## Completed

- Dotfiles repository published at `DanaisGitHub/dot-config`.
- Repository path on the laptop is `~/dotfiles`.
- Neovim, tmux, Bash, Ghostty, and OpenCode configuration are tracked.
- Active local configuration symlinks resolve to `~/dotfiles`.
- OpenCode commands and skills are tracked under `opencode/`.
- OpenCode dependencies are ignored from Git and can be recreated with `npm ci`.
- A non-root VPS user named `dev` was created.
- The VPS `dev` user was given `wheel` and `docker` group membership.
- `Containerfile` was created but has not been built.
- `compose.yaml` was created but has not been run.

## SSH Aliases

The local SSH configuration currently uses these aliases:

```text
myvps-root
myvps-dev
```

The VPS address and private keys are intentionally not documented here.

## Container Files

### `Containerfile`

Builds a Fedora 43 development image containing:

- Go
- Rust and Cargo
- Node.js and npm
- Python and pip
- Neovim
- tmux
- Git and SSH client tools
- Compilers and common build tools
- OpenCode

The image creates a non-root `dev` user. UID and GID are supplied at build time so files created in mounted project directories match the host user.

### `compose.yaml`

Defines one service named `dev`:

- Uses `Containerfile` to build the image.
- Keeps the container running with `sleep infinity`.
- Persists the container home directory in the `dev-home` volume.
- Mounts `~/dotfiles` at `/home/dev/dotfiles`.
- Mounts `~/projects` at `/workspace`.
- Does not mount private SSH keys or the Docker socket.
- Does not publish any application ports yet.

## Next Steps

Run these commands on the VPS as `dev` after cloning or updating the repository:

```bash
cd ~/dotfiles
mkdir -p ~/projects
export DEV_UID="$(id -u)"
export DEV_GID="$(id -g)"
docker compose config
docker compose build --pull
docker compose up -d
```

Verify the image tools and user:

```bash
docker compose exec dev id
docker compose exec dev bash -lc 'command -v go rustc cargo node npm python3 nvim tmux opencode'
```

Install the tracked configuration inside the container:

```bash
docker compose exec dev bash -lc 'bash ~/dotfiles/install.sh'
docker compose exec dev bash -lc 'cd ~/dotfiles/opencode && npm ci'
```

Install the tmux plugin manager:

```bash
docker compose exec dev bash -lc '
  mkdir -p ~/.tmux/plugins
  if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
'
```

Start the persistent development session:

```bash
docker compose exec -it dev tmux new-session -A -s main
```

From the laptop, the eventual one-command entry point will be:

```bash
ssh -t myvps-dev 'cd ~/dotfiles && docker compose exec -it dev tmux new-session -A -s main'
```

## OpenCode Authentication

Authentication is not tracked in Git. Run OpenCode inside the container and use its `/connect` command. The `dev-home` volume preserves the resulting authentication state.

Do not run `docker compose down -v` unless deleting the persisted home volume, plugins, and authentication state is intentional.

## GitHub Access

The VPS should use a separate SSH key for GitHub rather than copying the laptop or root private key. Add only the public key to the repository's GitHub deploy keys. Keep the deploy key read-only unless pushing from the VPS is explicitly required.

## Known Follow-Ups

- Build the image and resolve any Fedora package-name issues.
- Decide whether to keep C# support. The current Neovim configuration requests `csharp_ls`, but the image currently targets Go, Rust, Node.js, and Python and does not install a .NET SDK.
- Decide how Git operations from inside the container will use SSH. The initial setup does not mount private keys or an SSH agent.
- Add application port mappings only when a project needs them.
- Pin the OpenCode version instead of using `latest` if exact image reproducibility is required.
