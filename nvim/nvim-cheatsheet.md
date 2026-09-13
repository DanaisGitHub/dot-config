# Neovim Cheat Sheet

Your personal reference for the Neovim setup in this directory.

## Read This First: Modes

Neovim is modal. The same key can mean something completely different
depending on the current mode.

| Mode | Use it for | Enter it with | Leave it with |
|---|---|---|---|
| Normal | Move, edit, run commands | `Esc` from anywhere | Usually stay here |
| Insert | Type text | `i`, `a`, `o` | `Esc` |
| Visual | Select text | `v`, `V`, `Ctrl-v` | `Esc` |
| Command | Run `:w`, `:q`, and tools | `:` | Enter or `Esc` |
| Terminal | Use a shell inside Neovim | `:terminal` | `Ctrl-\ Ctrl-n` |
|

Your **leader key is Space**. For example, `<leader>pf` means press Space,
then `p`, then `f` while in Normal mode.

## Start and Finish Safely

```text
:edit path/to/file       Open a file
:w                       Save
:q                       Quit
:wq                      Save and quit
:x                       Save only if changed, then quit
:q!                      Quit and discard this buffer's changes
```

Before forcing quit, ask yourself whether you meant to use `:q` and save the
file instead. `:qa` quits all windows; `:qa!` discards all unsaved changes.

## Movement: The Small Set That Goes Far

Use counts with almost everything: `5j` moves down five lines and `3dw`
deletes three words.

| Key | Meaning |
|---|---|
| `h` `j` `k` `l` | Left, down, up, right |
| `w` / `b` | Next / previous word start |
| `e` | End of word |
| `0` / `^` / `$` | Line start / first non-space / line end |
| `gg` / `G` | Top / bottom of file |
| `:{number}` | Go to a line, such as `:42` |
| `%` | Jump between matching brackets |
| `Ctrl-d` / `Ctrl-u` | Half-page down / up, centered by your config |
| `Ctrl-f` / `Ctrl-b` | Full page down / up |
| `zz` | Center the current line |
| `Ctrl-o` / `Ctrl-i` | Back / forward through jump history |
|

## Editing: Think in Verbs and Motions

The powerful pattern is:

```text
verb + motion
```

Examples: `dw` deletes to the next word, `ci(` changes inside parentheses,
and `y$` copies to the end of the line.

| Key | Meaning |
|---|---|
| `i` / `a` | Insert before / after the cursor |
| `I` / `A` | Insert at line start / end |
| `o` / `O` | New line below / above |
| `x` | Delete one character |
| `dd` / `D` | Delete a line / to line end |
| `cc` / `C` | Change a line / to line end |
| `yy` | Copy a line |
| `p` / `P` | Paste after / before |
| `u` / `Ctrl-r` | Undo / redo |
| `.` | Repeat the last change |
| `r{char}` | Replace one character |
| `~` | Toggle character case |
|

### Text Objects

Text objects let you edit a whole logical region without carefully selecting
it. Use `i` for inside and `a` for around:

```text
diw       delete inside word
ci"       change inside double quotes
da(       delete parentheses and their contents
yap       copy around a paragraph
cit       change inside an HTML tag
```

## Visual Mode and Your Custom Editing Keys

| Key | Meaning |
|---|---|
| `v` / `V` / `Ctrl-v` | Character / line / block selection |
| `>` / `<` | Indent right / left; selection stays active |
| `=` | Re-indent selection |
| `J` | Move selected lines down and re-indent |
| `K` | Move selected lines up and re-indent |
| `<leader>p` | Paste over selection without losing your clipboard |
| `<leader>y` | Copy selection to the system clipboard |
| `<leader>d` | Delete to the black-hole register; do not overwrite clipboard |
|

## Search and Replace

```text
/text                  search forward
?text                  search backward
n / N                  next / previous match, centered by your config
* / #                  search word under cursor forward / backward
:noh                   clear highlighted matches
```

Your custom replacement map starts a whole-file replacement for the word
under the cursor:

```text
<leader>s
```

For explicit control:

```text
:%s/old/new/g          replace every match in the file
:%s/old/new/gc         confirm every replacement
:%s/old/new/gI         case-sensitive replacement
```

## Files and Project Navigation

| Key or command | What it does |
|---|---|
| `<leader>pv` | Open the built-in Netrw file explorer |
| `<leader>pf` | Telescope: find any file |
| `Ctrl-p` | Telescope: find Git-tracked files |
| `<leader>ps` | Telescope: grep for text across the project |
| `:Ex` | Open Netrw |
| `:vsplit file` | Open a file in a vertical split |
| `:find name` | Search the runtime path for a file |
|

Inside Telescope, type to filter, use `Ctrl-n`/`Ctrl-p` to move, `Enter` to
open, and `Esc` to cancel. Your `<leader>ps` command asks for the search text
first, then searches the project.

## Windows, Buffers, and Tabs

These are different things:

- A **buffer** is an open file in memory.
- A **window** is a view onto a buffer.
- A **tab** is a collection of windows.

```text
Ctrl-w s            horizontal split
Ctrl-w v            vertical split
Ctrl-w h/j/k/l      move between windows
Ctrl-w q            close the current window
Ctrl-w o            keep only the current window
Ctrl-w =            equalize window sizes
:ls                list buffers
:bn / :bp          next / previous buffer
:bd                close the current buffer
gt / gT            next / previous tab
:tabnew            create a tab
```

## Harpoon: Your Fastest File Switching

Harpoon is for the few files you are actively working on, not for every file
in the repository.

```text
<leader>a    add the current file
Ctrl-e       open the Harpoon list
Ctrl-h       jump to file 1
Ctrl-t       jump to file 2
Ctrl-n       jump to file 3
Ctrl-s       jump to file 4
```

A practical workflow is: find a file with `Ctrl-p`, mark it with
`<leader>a`, mark two or three related files, then switch using `Ctrl-h`,
`Ctrl-t`, `Ctrl-n`, and `Ctrl-s`.

## LSP: Code Intelligence

These mappings exist after a language server attaches to the current buffer.

| Key | What it does |
|---|---|
| `gd` | Go to definition |
| `K` | Show hover documentation |
| `<leader>vws` | Search workspace symbols |
| `<leader>vd` | Show the current diagnostic in a floating window |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>vca` | Show code actions |
| `<leader>vrr` | Find references |
| `<leader>vrn` | Rename the symbol across the project |
| `Ctrl-h` in Insert mode | Show function signature help |
|

Your Mason setup installs servers for TypeScript, Lua, Rust, Python, Go, C++,
and C#. If `gd` or `K` does nothing, check `:LspInfo` before assuming the
mapping is broken.

## Completion

While typing in Insert mode:

```text
Ctrl-Space    open completion manually
Ctrl-n        next suggestion
Ctrl-p        previous suggestion
Ctrl-y        accept the selected suggestion
```

The completion sources are LSP suggestions and LuaSnip snippets.

## Formatting and Code Quality

```text
<leader>I              format the current file
:Format                use if provided by a formatter/plugin
```

Formatting also runs automatically before save through Conform. Formatters
are configured for Lua, Python, JavaScript, TypeScript, Go, Rust, C, and C++.

## Git and Undo History

Fugitive commands:

```text
:Git              open Git status
:Git add %        stage the current file
:Git commit       create a commit
:Git diff         show a diff
:Git push         push commits
:Gdiffsplit       compare the file with its index version
:GBlame            show line-by-line blame
```

Undotree:

```text
:UndotreeToggle
```

Undo is a tree, not just a straight timeline. Undotree lets you inspect and
return to an earlier branch of changes.

## Folds

Your config uses Treesitter folds and starts with them open:

```text
<leader><space>    toggle the fold under the cursor
za                toggle fold
zc                close fold
zo                open fold
zM                close all folds
zR                open all folds
```

## Registers and Clipboard

Your system clipboard is enabled with `unnamedplus`, and these custom maps
make the important cases explicit:

```text
<leader>y       yank to the system clipboard
<leader>Y       yank the whole line to the system clipboard
<leader>p       paste over a selection without losing the clipboard
<leader>d       delete into the black hole; do not copy it
:registers      inspect registers
```

Useful explicit registers:

```text
"0      last yank
"+      system clipboard
"_      black hole
"/      last search
":      last command
```

## Macros and Marks: Advanced Repetition

```text
qa          record a macro into register a
q           stop recording
@a          play macro a
@@          replay the last macro
10@a        play macro a ten times
ma          set mark a
`a          jump to the exact position of mark a
'a          jump to the line containing mark a
:marks      list marks
```

Use a macro when the same small edit must happen repeatedly. First perform it
once carefully, record it, test it on one more line, then apply a count.

## Helpful Inspection Commands

```text
:checkhealth        diagnose Neovim and provider problems
:messages           read recent messages
:map <leader>       inspect mappings beginning with Space
:verbose nmap gd    show where a mapping was defined
:LspInfo            inspect attached language servers
:Mason              manage installed language servers and tools
:Lazy               manage plugins
:TSUpdate           update Treesitter parsers
```

## OpenCode V2 in Neovim

CodeCompanion runs OpenCode via ACP using your existing OpenCode login.

| Key | Mode | Action |
|---|---|---|
| `Ctrl-a` | Normal | Toggle the existing editor chat |
| `Ctrl-a` | Visual | Add selected code to chat |
| `Space a c` | Normal/Visual | Toggle editor chat |
| `Space a s` | Visual | Add selected code to chat |
| `Space a n` | Normal/Visual | Start a new chat |
| `Ctrl-x` | Normal/Visual | Open the editor action palette |
| `Ctrl-.` | Normal/Terminal | Toggle the separate OpenCode TUI |

Start Neovim from the project directory. Select code, add it to chat, type your
question, press `Esc`, then `Enter` to send. Toggling the chat preserves its
conversation. `/resume` opens the ACP session picker.

Inside chat:

```text
#{buffer}         include the current source buffer
#{selection}      include the captured selection
#{diagnostics}    include LSP diagnostics
#{diff}           include the Git diff
ga                choose adapter/model (Normal mode)
q                 stop a running request (Normal mode)
?                 show chat keymaps (Normal mode)
```

The default model is `openai/gpt-6-astra`; override `OPENCODE_NVIM_MODEL` before
launching Neovim on a machine with different model access. The configured
integration is ACP chat; generic inline actions need a separate HTTP adapter.
The terminal and editor chat have separate conversations unless explicitly resumed.

## Memorize These First

```text
Space pf       find a file
Space ps       search project text
Space a        mark a Harpoon file
Ctrl-h/t/n/s   jump to Harpoon files
gd             go to definition
K              hover documentation
[d / ]d        navigate diagnostics
Space vrn      rename a symbol
Space I        format file
Space y        copy to system clipboard
Space d        delete without overwriting clipboard
u / Ctrl-r     undo / redo
.              repeat last change
:w / :q        save / quit
```
