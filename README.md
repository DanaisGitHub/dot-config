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
