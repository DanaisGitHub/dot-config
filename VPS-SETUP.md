# VPS Development Environment

Last updated: 2026-09-13

## Goal

Use the VPS as a native remote development machine:

```text
Ghostty on laptop -> SSH as dev -> tmux -> Neovim/OpenCode
```

The host account is `dev`. Development tools, configuration, plugins, and authentication live in the user's normal home directory. Docker is not part of the day-to-day workflow for now.

## Completed

- Dotfiles repository published at `DanaisGitHub/dot-config`.
- Repository path on the laptop is `~/dotfiles`.
- Neovim, tmux, Bash, Ghostty, and OpenCode configuration are tracked.
- Active local configuration symlinks resolve to `~/dotfiles`.
- OpenCode commands and skills are tracked under `opencode/`.
- OpenCode dependencies are ignored from Git and can be recreated with `npm ci`.
- A non-root VPS user named `dev` was created.
- The VPS `dev` user was given `wheel` membership for administrative package installation.
- `setup-native.sh` installs the Fedora development toolchain and user-level development state.

## SSH Aliases

The local SSH configuration uses these aliases:

```text
myvps-root
myvps-dev
```

The VPS address and private keys are intentionally not documented here.

## Native Setup

Run these commands on the VPS as `dev` after cloning or updating the repository:

```bash
cd ~/dotfiles
bash setup-native.sh --adopt
```

Use `--adopt` only when existing files under the home directory should be moved into a timestamped `~/.dotfiles-backup` directory before the symlinks are created. On later runs, use:

```bash
cd ~/dotfiles
bash setup-native.sh
```

The script installs:

- Go
- Rust and Cargo
- Node.js and npm
- Python, pip, and Black
- Neovim and tmux
- Git and SSH client tools
- Compilers and common native build tools
- Pinned OpenCode V2 and Prettier
- tree-sitter-cli and the configured language parsers
- TPM and the pinned Neovim plugins

Verify the installation:

```bash
id
command -v go rustc cargo node npm python3 nvim tmux opencode
go version
rustc --version
node --version
python3 --version
nvim --version | head -1
```

On the first Neovim launch, Mason may download the configured language servers. The configured LSPs are TypeScript, Lua, Rust, Python, Go, C/C++, and C#.

## Ghostty Terminfo

Ghostty identifies itself as `xterm-ghostty`. Install that terminal definition once from the local Ghostty terminal so tmux and other terminal programs on the VPS can recognize it:

```bash
infocmp -x xterm-ghostty | ssh myvps-dev 'tic -x -'
```

Verify it on the VPS:

```bash
ssh myvps-dev 'TERM=xterm-ghostty infocmp xterm-ghostty >/dev/null && printf "%s\n" "Ghostty terminfo is installed"'
```

## Daily Workflow

Start or reattach to the persistent tmux session on the VPS:

```bash
tmux new-session -A -s main
```

From the laptop, the one-command entry point is:

```bash
ssh -t myvps-dev 'tmux new-session -A -s main'
```

Inside tmux, work from the project directory:

```bash
cd ~/projects/<project>
nvim
```

After changing the dotfiles repository:

```bash
cd ~/dotfiles
bash setup-native.sh
```

## OpenCode Authentication

Authentication is not tracked in Git. Run `opencode` as `dev` and use its `/connect` command. Native setup stores the resulting authentication state in the normal `dev` home directory.

For ChatGPT device login, run `opencode auth login openai --method chatgpt-headless`.
The upgraded environment is accessed through `ssh myvps-dev`. See
[OPENCODE-V2.md](OPENCODE-V2.md) for the migration record and Neovim ACP integration.

## GitHub Access

The VPS should use a separate SSH key for GitHub rather than copying the laptop or root private key. Add only the public key to the repository's GitHub deploy keys. Keep the deploy key read-only unless pushing from the VPS is explicitly required.

## Optional Docker Files

`Containerfile` and `compose.yaml` remain in the repository for a possible future containerized workflow. They are not required by `setup-native.sh` and should not be started during normal native development.

If the earlier container experiment is still running, stop it from `~/dotfiles` with:

```bash
docker compose stop
```

Do not use `docker compose down -v` unless deleting the old container home volume and its persisted state is intentional.
