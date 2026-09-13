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

V2 runs a shared background service by default. After later startup-time config
changes, restart the client and, when needed, `opencode service restart`.

## Neovim

The currently pinned `opencode.nvim` uses the V1 HTTP API and launches with a
`--port` flag that is absent from V2's TUI. For V2, this configuration skips that
plugin and its Snacks picker action. **Ctrl+.** instead toggles an ordinary
OpenCode terminal using Snacks. The old Ctrl+A/Ctrl+X agent actions are not
installed for V2; normal editor bindings remain available.

This fallback does not automatically send selections or diagnostics. OpenCode
beside Neovim in tmux also works without the editor API integration. Neovim's
own language servers remain independent of OpenCode.

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

## References

- https://opencode.ai/v2/docs/migrate-v1/
- https://opencode.ai/v2/docs/cli/
- https://opencode.ai/v2/docs/cli/providers/
