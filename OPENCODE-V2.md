# OpenCode V2

Both native development environments use the release pinned in
`install-opencode.sh` (currently 2.0.3), installed for the development user at
`~/.opencode/bin/opencode`.

## Install or reproduce

Run as the normal user:

```bash
bash install-opencode.sh
hash -r
opencode --version
```

The tracked Bash configuration already prepends `~/.opencode/bin` to PATH.
`setup-native.sh` calls this installer separately from the Prettier installation.
Remove an older package-managed OpenCode using its owning package manager when
replacing it; the application-level uninstall command can remove session data.

## First launch after upgrading from V1

Quit existing OpenCode clients on the machine before launching V2 against the
normal data directory. Open a fresh shell, change to the intended project, and
run `opencode`. Existing running clients continue executing their old binary.

V2 reads the supported V1 configuration format used here. The obsolete external
ChatGPT authentication plugin has been removed; authentication is built in.
Existing credentials are imported from local state. If reauthentication is
needed, use `/connect` or, on a headless server:

```bash
opencode auth login openai --method chatgpt-headless
```

Complete the device login in a browser. Credentials and the session database
remain machine-local and are not synchronized through this repository.

If a just-started service reports `Integration not found: openai`, let its model
catalog initialize with `opencode models`, then retry login against that same
service. This first-start issue was observed during migration.

V2 runs a shared background service by default. After later startup-time config
changes, restart the client and, when needed, `opencode service restart`.

## Neovim

The currently pinned `opencode.nvim` uses the V1 HTTP API and launches with a
`--port` flag that is absent from V2's TUI. For V2, this configuration skips that
plugin and its Snacks picker action. CodeCompanion v19.24.1 now provides native
editor chat through the supported `opencode acp` protocol.

- **Ctrl+A** in Normal mode toggles the existing editor chat.
- **Ctrl+A** in Visual mode adds selected code to that chat.
- **Ctrl+X** opens CodeCompanion's action palette.
- **Space a c / a s / a n** provide chat-toggle, add-selection and new-chat bindings.
- **Ctrl+.** toggles the separate OpenCode terminal using Snacks.

Use `#{diagnostics}` or `#{diff}` in chat to attach editor context. Press `Esc`
then `Enter` to submit a message. ACP chat is a separate conversation by default;
use `/resume` for the adapter's session picker. OpenCode credentials remain in
OpenCode, rather than being copied into Neovim configuration.

The default model is `openai/gpt-6-astra`, overridable through
`OPENCODE_NVIM_MODEL`. This config enables ACP chat, not CodeCompanion's separate
HTTP-backed inline actions. Neovim's language servers remain independent of
OpenCode. Treesitter now uses the rewritten plugin's installation API, with
matching parsers and queries under Neovim's data-directory `site/`.

## Migration verification and backups

During migration, private per-machine backups are created beneath:

```text
~/.local/state/opencode-migration/<timestamp>/
  manifest.json     # Original version and paths; no credential contents
  opencode-v1       # Original executable
  config/           # Config without downloaded node_modules
  state/            # Client preferences without runtime locks
  opencode.db       # SQLite online backup, checked with PRAGMA quick_check
  data.tar.gz       # Auth and other persistent data, including snapshots
  validation/       # Isolated copy used for migration and model smoke tests
```

Caches, downloaded tools/repositories, logs and tool-output archives are omitted.
The backups contain credentials and are stored under private directories outside
Git. Do not publish them.

Validation uses separate XDG configuration/data/state/cache locations, leaving
the live V1 database available to existing sessions until they are closed.
Checks include database migration, a real model request, editing and testing a
small Go fixture, session resumption, and Neovim startup.

For rollback, stop all OpenCode clients and its V2 service, preserve any new V2
work, then restore the original executable, configuration and data from the same
backup. Restore SQLite only with writers stopped and handle its WAL/SHM sidecars
consistently. Replacing the executable alone does not reverse data migration.

## Verified on 2026-09-13

- Laptop: V2 executable installed; all 272 V1 sessions migrated in the isolated
  database copy. Built-in ChatGPT OAuth, a Go edit/test/vet cycle, session resume,
  and the Neovim terminal mapping passed. The live database switches on the first
  V2 launch after the existing V1 clients are closed.
- Hetzner development account (`ssh myvps-dev`): V2 installed, the old global
  `opencode-ai` package removed, and both existing development-account sessions
  migrated. ChatGPT was reauthenticated using device login. A Go edit/test/vet
  cycle and session resume after a service restart passed; database quick-check
  and Neovim startup passed.
- A separately running root-owned V1 client predates this migration. Its process
  is not the development account's V2 service. Development now uses `myvps-dev`.
- Service configuration is machine-local and ignored by Git because it may
  contain server credentials.

## References

- https://opencode.ai/v2/docs/migrate-v1/
- https://opencode.ai/v2/docs/cli/
- https://opencode.ai/v2/docs/cli/providers/
