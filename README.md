# Dotfiles

Portable configuration for the development environment.

## Tracked configuration

- `nvim/`: Neovim configuration and plugin lockfile.
- `tmux/tmux.conf`: tmux settings. Plugins themselves are intentionally not tracked.
- `shell/`: Bash startup files.
- `ghostty/config`: local desktop terminal configuration.
- `opencode/`: global OpenCode configuration, commands, skills, local plugins, and Node dependency manifest.

Downloaded plugins, caches, language servers, SSH keys, tokens, and other machine-specific state are deliberately excluded. Neovim bootstraps `lazy.nvim` and restores plugins from `lazy-lock.json` when it starts. Install tmux plugins with TPM after installing the configuration.

## OpenCode

OpenCode V2 installation, authentication and rollback are documented in
[OPENCODE-V2.md](OPENCODE-V2.md).

`~/.config/opencode` links to `~/dotfiles/opencode`. Add global OpenCode files through either path; they are the same files.

- Skills: `~/dotfiles/opencode/skills/<name>/SKILL.md`
- Commands: `~/dotfiles/opencode/command/<name>.md`
- Local plugins: `~/dotfiles/opencode/plugins/<name>.ts`

`package.json` and `package-lock.json` are tracked so local TypeScript plugins can import `@opencode-ai/plugin`. `node_modules`, OAuth credentials, and other runtime state are not tracked. After cloning on a new machine, run `npm ci` in `~/dotfiles/opencode` if local plugins need those dependencies.

## Install locally

The installer creates symlinks from the home directory to this repository. On the first local run, `--adopt` moves existing files to a timestamped directory under `~/.dotfiles-backup` before linking this repository.

```bash
cd ~/dotfiles
bash install.sh --adopt --desktop
```

Use `--desktop` only on a machine that runs Ghostty. Omit it on the headless VPS:

```bash
cd ~/dotfiles
bash install.sh
```

After tmux starts, install its plugins with `prefix` then `I` (capital i).
Quit and restart OpenCode after changing its configuration, commands, skills, or plugins; it loads them at startup.

## Neovim and OpenCode V2

The pinned setup requires Neovim 0.12+ and tree-sitter-cli 0.26.1+.
CodeCompanion provides editor chat through `opencode acp`, using OpenCode's
existing authentication. Its release is pinned in the plugin specification and
`nvim/lazy-lock.json`.

- **Space a c** or **Ctrl+a** in Normal mode: toggle the existing chat.
- Select code, then **Space a s** or **Ctrl+a**: add just that selection to chat.
- **Space a n**: start a new chat.
- **Ctrl+x**: open the editor action palette.
- **Ctrl+.**: toggle the separate OpenCode terminal.

In chat, type your request, press `Esc`, then `Enter` to send it. Use
`#{buffer}`, `#{diagnostics}`, or `#{diff}` to attach context, `ga` to change
adapter/model, and `/resume` to select an existing ACP session. Open the editor
from the intended project directory so the agent receives the correct workspace.

The default editor model is `openai/gpt-6-astra`. Set `OPENCODE_NVIM_MODEL` to an
available `provider/model` before starting Neovim to override it per machine.
For example, choose a model from `opencode models` on the work laptop. Editor
chat and the terminal have separate conversations by default. The generic
CodeCompanion inline/HTTP actions require their own HTTP adapter; this setup
configures OpenCode-backed **chat**.

See [Neovim shortcuts](nvim/nvim-cheatsheet.md) and
[tmux shortcuts](tmux/tmux-cheatsheet.md). Historical workflow research is in
[AI-WORKFLOW-REVIEW.md](AI-WORKFLOW-REVIEW.md).

## Install on the Fedora VPS

Run this as the non-root development user on the VPS. It installs the native toolchain, links the configuration, installs TPM, restores OpenCode dependencies, and installs the pinned Neovim plugins:

```bash
cd ~/dotfiles
bash setup-native.sh --adopt
```

The VPS workflow is native rather than container-based:

```text
Ghostty -> SSH -> tmux -> Neovim/OpenCode
```

The Docker `Containerfile` and `compose.yaml` remain available as an optional future development environment, but are not required for the native setup.

## Put it on GitHub

Review the initial files before creating the first commit:

```bash
cd ~/dotfiles
git status
git add -A
git commit -m "Add initial dotfiles"
git remote add origin git@github.com:YOUR-ACCOUNT/dotfiles.git
git push -u origin main
```

Do not add SSH keys, API tokens, password-store data, shell history, or private `.local` overrides to this repository.
