# tmux Cheat Sheet

Your personal tmux reference, from first launch to multi-session workflows.

## The One Idea That Makes tmux Click

tmux keeps terminal programs running inside a **session**. You can detach from
that session, close your terminal, reconnect later, and find your programs
exactly where you left them.

Most tmux keyboard commands begin with a **prefix**:

```text
Ctrl-b, then another key
```

Press and release `Ctrl-b`; do not hold it while pressing the second key.
In this guide, `Prefix` means `Ctrl-b`.

## Start Here

Run these from your normal shell:

```bash
tmux                         # Start a new session
tmux new-session -A -s work  # Create or attach to the named session
tmux new -s work             # Start a named session
tmux ls                      # List sessions
tmux attach -t work          # Attach to a named session
tmux kill-session -t work   # Kill one session
```

Inside tmux:

| Key | What it does |
|---|---|
| `Prefix d` | Detach and leave everything running |
| `Prefix ?` | Show every tmux key binding |
| `Prefix r` | Reload your config |
| `Prefix :` | Open tmux's command prompt |
| `Prefix t` | Show a large clock |
| `Prefix z` | Zoom the current pane; press again to restore |
| `Prefix x` | Kill the current pane, after confirmation |
| `Prefix &` | Kill the current window, after confirmation |
|

If you only remember one recovery command, use:

```bash
tmux attach -t <session-name>
```

## Sessions: Your Workspaces

Think of a session as one project or task. Windows live inside sessions, and
panes live inside windows.

```bash
tmux new -s api                    # Create a session named api
tmux attach -t api                 # Reconnect to it
tmux rename-session -t api backend # Rename it
tmux kill-session -t api           # Delete it and its programs
tmux kill-server                   # Delete every session (be careful)
```

Inside tmux:

| Key | What it does |
|---|---|
| `Prefix s` | Choose a session from a list |
| `Prefix (` | Move to the previous session |
| `Prefix )` | Move to the next session |
| `Prefix d` | Detach without stopping programs |
| `Prefix g` | Sessionist: fuzzy-switch sessions |
| `Prefix S` | Sessionist: create a session from the current window |

### A Reliable Daily Pattern

```bash
tmux new -s project
```

Then create one window for the editor, one for running the app, and one for
logs or Git. Detach with `Prefix d` whenever you need to close the terminal.
Later:

```bash
tmux attach -t project
```

## Windows: Tabs for Different Jobs

| Key | What it does |
|---|---|
| `Prefix c` | Create a new window |
| `Prefix ,` | Rename the current window |
| `Prefix n` | Go to the next window |
| `Prefix p` | Go to the previous window |
| `Prefix 0` ... `Prefix 9` | Jump to a window by number |
| `Prefix w` | Browse windows and sessions |
| `Prefix &` | Kill the current window |
|

Your config keeps window names from changing automatically and renumbers the
remaining windows after one is closed.

From the shell, useful equivalents are:

```bash
tmux new-window -n logs -t project
tmux rename-window -t project:1 editor
tmux select-window -t project:2
tmux list-windows -t project
```

## Panes: Split One Window

Your custom split keys preserve the current pane's working directory:

| Key | What it does |
|---|---|
| `Prefix \|` | Split left/right |
| `Prefix -` | Split top/bottom |
| `Prefix h` | Move left |
| `Prefix j` | Move down |
| `Prefix k` | Move up |
| `Prefix l` | Move right |
| `Alt-Left/Right/Up/Down` | Move panes without the prefix |
| `Prefix o` | Cycle through panes |
| `Prefix q` | Briefly show pane numbers |
| `Prefix !` | Break the pane into a new window |
| `Prefix {` / `Prefix }` | Swap pane left/up or right/down |
| `Prefix Space` | Cycle pane layouts |
| `Prefix z` | Temporarily maximize the current pane |
| `Prefix x` | Kill the current pane |
|

Resize a pane with the prefix and an arrow key. For more control, use the
command prompt:

```text
Prefix :resize-pane -L 10
Prefix :resize-pane -R 10
Prefix :resize-pane -U 5
Prefix :resize-pane -D 5
```

## Copy Mode and the System Clipboard

Your copy mode uses vi keys and `wl-copy`:

1. Press `Prefix [` to enter scrollback.
2. Move with `h`, `j`, `k`, `l`, search with `/`, or jump with `g` and `G`.
3. Press `v` to begin selecting.
4. Move to the end of the selection.
5. Press `y` to copy to the system clipboard and leave copy mode.

| Key in copy mode | What it does |
|---|---|
| `q` or `Escape` | Leave copy mode |
| `v` | Begin a character selection |
| `y` | Copy selection and exit |
| `Space` | Begin selection in standard vi copy mode |
| `/` | Search forward |
| `?` | Search backward |
| `n` / `N` | Next / previous match |
| `g` / `G` | Top / bottom of scrollback |
| `Ctrl-u` / `Ctrl-d` | Half-page up / down |
|

If copying does nothing, check that Wayland's clipboard tool is installed:

```bash
command -v wl-copy
```

## Your Plugins

The status bar shows CPU, network speed, continuum save activity, time, and
date. Your installed plugins provide these workflows:

| Key | Plugin | What it does |
|---|---|---|
| `Prefix g` | Sessionist | Fuzzy session switching |
| `Prefix S` | Sessionist | Create a session from a window |
| `Prefix Ctrl-f` | Copycat | Search scrollback using a regular expression |
| `Prefix Ctrl-u` | Copycat | Find URLs in scrollback |
| `o` in copy mode | tmux-open | Open the selected URL or file |
|

TPM commands:

| Key | What it does |
|---|---|
| `Prefix I` | Install new plugins |
| `Prefix U` | Update plugins |
| `Prefix Alt-u` | Remove plugins no longer in the config |
|

Continuum is configured with a 15-minute save interval, but its required
tmux-resurrect dependency is currently missing from the tracked configuration.
Automatic restore is not enabled. Do not rely on reboot recovery until those
are configured and tested. Resurrect normally provides `Prefix Ctrl-s` to save
and `Prefix Ctrl-r` to restore once installed.

The `wl-copy` binding targets the host's Wayland clipboard. Copying from a
headless SSH host to your laptop needs a separate clipboard solution.

## Command Prompt: The Advanced Escape Hatch

Press `Prefix :` and type tmux commands directly:

```text
list-sessions
list-windows
list-panes
display-message "hello"
set-option -g history-limit 20000
source-file ~/.tmux.conf
```

From a normal shell, add `-t <target>` when you need to address a specific
session, window, or pane:

```bash
tmux list-panes -a
tmux capture-pane -p -S -100 > /tmp/pane.txt
tmux send-keys -t project:1.0 'npm test' Enter
tmux kill-pane -t project:1.0
```

Targets commonly look like:

```text
session:window.pane
project:1.0
```

## Troubleshooting

```bash
tmux ls                         # Is the session still alive?
tmux attach -t <name>           # Reconnect
tmux source-file ~/.tmux.conf   # Reload manually
tmux show-options -g            # Inspect global options
tmux list-keys                  # Inspect active key bindings
```

If `Prefix r` says the config cannot be found, your installed symlink may use
`~/.tmux.conf` while this repository stores the source at
`dotfiles/tmux/tmux.conf`. Reload the path that actually exists.

## Memorize These First

```text
Prefix d       detach
Prefix c       new window
Prefix |       vertical split
Prefix -       horizontal split
Alt + arrows   move between panes
Prefix h/j/k/l move between panes
Prefix z       zoom pane
Prefix [       copy mode
v, move, y     copy to clipboard
Prefix s       choose session
Prefix r       reload config
```
