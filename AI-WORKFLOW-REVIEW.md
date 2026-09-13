# AI development workflow review

Historical pre-migration audit. For the implemented V2 setup and Neovim ACP
integration, see [OPENCODE-V2.md](OPENCODE-V2.md) and [README.md](README.md).

Research snapshot: 2026-09-13. Scope: the local development configuration, public OpenCode v2 documentation/source, and selected practitioner workflows. The Hetzner host and WSL installation were not accessed. Recommendations below are proposals; this report does not install or migrate software.

## Decision

Keep OpenCode. Prioritize persistent project/task context and executable verification, then migrate to v2 with the existing integrations explicitly tested. Retain SSH + tmux as the default server interface. Add a small number of workflows before adding orchestration or memory services.

The target is less human re-explanation and review effort per accepted change. Agent count, token throughput, and plugin count are poor optimization targets.

## 1. What the local audit established

| Finding | Consequence |
| --- | --- |
| `opencode` resolves to `~/.opencode/bin/opencode`, version `1.18.30`. | This machine has not migrated to v2. |
| tmux is `3.7c`. | Configuration is the immediate priority; no old-binary explanation is needed. |
| OpenCode, tmux and Neovim paths resolve into `~/dotfiles`; a GitHub origin is configured. | A shared configuration foundation already exists. Local edits reach other machines only after deliberate commit/push/pull and installation/reload. |
| `opencode/opencode.json` is 240 lines, largely manual GPT-5.1/5.2 model definitions and OAuth settings; its only configured plugin is `opencode-openai-codex-auth`. | Test v2 built-in ChatGPT authentication and its model catalog before retaining this legacy configuration. Manual definitions alone do not prove which model current sessions use. |
| Global OpenCode permission is `allow`. | There is no useful interactive/autonomous policy distinction in this global file. |
| No global OpenCode `AGENTS.md`; two global skills: communication preferences and `grill-me`. | Stable instructions and project-specific context deserve attention before another memory product. Project instructions must be audited per active repository. |
| Plannotator commands exist and its executable is on PATH, but no Plannotator plugin is registered in the inspected global configuration. | `/plannotator-review` merely asks the model to acknowledge that a UI is opening. `/plannotator-last` has no template body. These files are not evidence of a working integration. |
| `/worktree` and `/devcontainer` call named tools without implementations in the inspected global plugins directory. | Check effective project tools; repair commands that cannot actually run. |
| `opencode/package.json` pins the v1 `@opencode-ai/plugin` SDK at `1.4.7`; local plugins directory contains only `.gitkeep`. | Reconsider the dependency after deciding which local plugins actually exist. |
| `setup-native.sh:84–85` installs `opencode-ai@latest` when either OpenCode or Prettier is missing. | Separate tool installation checks and change the OpenCode distribution for v2. The existing combined condition can install another OpenCode even when only Prettier is missing. |
| tmux-continuum is configured and installed, but tmux-resurrect is neither configured nor installed in the inspected plugin directory. | Its documented dependency is missing. Automatic restore is also not enabled in the config. |
| tmux copy mode binds `y` twice; the final binding executes `wl-copy`. | It fits a local Wayland session, not copying from a headless server into the laptop clipboard. |
| Neovim already configures `nickjvandyke/opencode.nvim`, gopls and formatters. | This is an existing editor integration to verify, not a missing plugin to install. |
| Tracked README/VPS setup edits and untracked setup/cheatsheet files already exist. | Preserve and review this existing work during implementation. |

## 2. Persistent context: the largest expected improvement

Use three kinds of context with explicit ownership:

1. **Global preferences**, in `opencode/AGENTS.md`: concise communication rules and general working preferences. Avoid project architecture and machine-specific paths.
2. **Durable project facts**, in each repository's `AGENTS.md`: exact verification commands, environment quirks, important invariants, and pointers to architecture/domain docs. Add a rule when it prevents an observed recurring mistake; prune redundant rules.
3. **Current task state**, in a named task document or GitHub issue: objective, acceptance criteria, decisions, progress, evidence, and next action. Keep one record per concurrent task, not a shared `CURRENT.md` that multiple agents overwrite.

Suggested project layout, adapted to existing documentation rather than imposed everywhere:

```text
AGENTS.md                 # Short always-loaded operating instructions
docs/architecture.md      # Relevant structure and domain terms; read on demand
docs/decisions/            # Only consequential decisions and their reasons
docs/tasks/<task-id>.md    # Active objective and cross-session handoff
```

These documentation paths are a proposed convention, not magical OpenCode auto-discovery paths. `AGENTS.md` tells the agent when to read them. Completed task records can be archived; do not preload their history.

### Handoff contract

```markdown
# Task: <name>
Updated: <date>; branch: <branch>; base/HEAD: <commit>
## Outcome and acceptance criteria
## Decisions and reasons
## Completed work and relevant paths
## Verification actually run
Commands, results, and evidence paths; distinguish not-run checks.
## Remaining work and blockers
## Next action
```

Refresh this at meaningful handoffs: changing machines, changing sessions, pausing a substantial task, or entering implementation after planning. Do not rewrite it after every message. A resuming agent should compare it with Git state and current files rather than trust stale claims.

Same task on the same server: resume its existing OpenCode session. New machine or clean implementation session: read the task record plus relevant project instructions. Git synchronizes checked-in context; it does not synchronize the running OpenCode conversation database.

For planning/research unrelated to a code repository, use a dedicated notes/workspace directory with its own `AGENTS.md` and topic documents. Avoid conducting every unrelated project and research task from the home directory in one enormous session.

V2 specifically discovers `AGENTS.md`. Its instructions page currently says the accepted `instructions` setting does not load its listed files/URLs, and `CLAUDE.md` fallback is absent. Use documented instruction discovery rather than relying on successful config parsing. [1][2]

## 3. Make generated changes easy to verify

Give each repository one documented verification entry point, using its existing Makefile or package scripts when available. Proposed names such as `make verify` are conventions to implement, not commands confirmed present in the user's projects.

For a conventional single-module Go repository, the baseline is formatting checks, `go test ./...`, and `go vet ./...`, from the module root. Use focused package tests while iterating. Add `go test -race ./...` where supported and appropriate, particularly for concurrency-sensitive changes or CI. Race detection only finds races in executed paths. Existing lint/staticcheck conventions take precedence; no need for overlapping lint suites by default. Fuzz parsers and boundary-heavy logic when there is a concrete benefit, with a bounded run.

For HTML/CSS/JavaScript, run the actual project scripts, exercise the changed browser flow, and inspect screenshots when appearance matters. Include console/network failures, keyboard interaction, and mobile sizing when relevant. For APIs, verify actual HTTP behavior as well as unit tests.

Use this completion contract:

> Implement the agreed scope. Run the relevant documented checks. Review the diff against the acceptance criteria. Report changed behavior, checks actually run and their results, evidence paths, and remaining gaps. Do not treat a written test as a passing test.

For a bug, first demonstrate the failure when practical, then fix it and rerun the regression. Tests should verify behavior, not duplicate implementation details. Do not manufacture a large test suite for a trivial reversible edit.

For nontrivial changes, use **one fresh-context reviewer** with the acceptance criteria, base commit, diff, and relevant files. Request actionable correctness findings with file/line evidence; allow “no findings.” Do not ask it to invent a fixed number of problems. Human review focuses on whether the behavior and architecture are right, especially critical business rules and data changes.

Run the same deterministic checks in GitHub Actions before accepting a PR. Agent review supplements executable checks. For visual feedback, test Plannotator after its integration is working. [3][4][5]

## 4. What to borrow from practitioners

| Source | Documented practice | Translation for this setup |
| --- | --- | --- |
| Boris Cherny, January 2, 2026 thread, accessed through Thread Reader | Shared versioned instructions; plan before substantial implementation; reusable commands; verification tools; multiple sessions. | Borrow the instructions/commands/verification loop. His large parallel setup and then-current model choice are not requirements. [3] |
| Matt Pocock's skills repository | Small composable skills, clarification, domain vocabulary/decision records, TDD and disciplined debugging. | Start with handoff and debugging/TDD guidance. Keep the existing interview skill for ambiguous work. Do not impose exhaustive interviews on tiny changes. [6] |
| DHH, January 7, 2026 | OpenCode agents as supervised collaborators; terminal/tools/tests; review quality and cohesion. | Preserve manual editing and deliberate human review while delegating bounded contributions. His article is not a specific plugin prescription. [7] |
| Theo/T3 team's public T3 Code project | A remote-ready control surface for agents with desktop/web/mobile interfaces. | Consider it only if managing remote sessions remains the bottleneck after improving tmux. This is product evidence, not a verified account of Theo's complete personal workflow. [8] |
| Mitchell Hashimoto, February 5, 2026 | Scope tasks, separate planning/execution, engineer checks and instructions after failures, delegate known-fit work. Describes one background coding agent as a useful balance. | Begin with one implementation task plus occasional independent review; increase concurrency when review capacity permits. [4] |
| Simon Willison, Agentic Engineering Patterns | Execute generated code, supplement tests with actual app/browser exploration, capture demonstrations and results. | Require reproducible evidence instead of “it should work.” Preserve enough understanding to assess the resulting code. [5] |

There are real disagreements: Boris uses many sessions and notifications; Mitchell describes protecting focus and a single background worker. Choose concurrency and notifications based on review capacity and interruptions, not the most impressive demonstration. Practitioner reports are qualitative evidence, not controlled productivity benchmarks.

## 5. Small extension shortlist

| Addition | Decision | Compatibility and cost considerations |
| --- | --- | --- |
| Native AGENTS.md, session resume, compaction, commands, stats, diff view | **First** | Built-in v2 capabilities. Persistent guidance and compaction serve different purposes. [1][2][9] |
| `/handoff`, `/verify`, focused `/review` workflows | **First** | Plain Markdown commands/skills are portable. Existing supported v1 command/skill files remain accepted. Avoid names that collide with built-ins or installed commands. |
| Selected Matt Pocock skills | **Adopt selectively** | Read the chosen files and dependencies before installation. Current engineering flows can depend on setup/domain/issue-tracker skills and Claude-specific orchestration. Adapt a small set; do not assume every frontmatter field or invocation rule transfers. [6] |
| Playwright CLI + skill, plus project Playwright tests | **First browser addition** | Microsoft's MCP README explicitly recommends considering CLI+skills for coding agents and token efficiency. CLI integration avoids the OpenCode plugin API. Fedora browser dependencies and headless execution still need a real test. MCP remains an option for persistent exploratory browser interaction. [10] |
| `gh` | **Use existing executable** | Good default for GitHub issues, PRs, CI results, and diffs. Add GitHub MCP only for a concrete missing workflow. Authentication was not tested. |
| Plannotator | **Trial after migration** | Published `@plannotator/opencode` `0.27.14` exposes a dedicated v2 server adapter and source includes a v2 smoke-test fixture. That is stronger evidence than merely mentioning OpenCode. Actual installed v2 behavior, SSH browser access and feedback round-trip remain untested. [11] |
| Context7 | **On demand** | Retrieves version-specific docs; current project offers CLI+skills as well as MCP. Useful when dependencies are unfamiliar or changing. Lookup results still need matching to the project's installed version; retrieval is not free context. [12] |
| `opencode.nvim` | **Verify existing integration** | Current README still describes exposing a server with `opencode --port`; v2 changed server contracts. The installed lockfile pins a particular commit. Compatibility must be tested, not inferred from the project name. Keep side-by-side terminals usable. [13] |
| Supermemory | **Defer** | Persistent external recall can help across projects, but adds capture/recall behavior and another source of truth. Inspected source manifest still uses the v1 plugin package/hooks. Its own version `2.0.13` does not establish OpenCode v2 support. [14] |
| Dynamic Context Pruning | **Defer; measure first** | Compression/deduplication can shrink context, but summaries can omit details and changed prompts can affect caching. Inspected manifest uses v1 SDK dependencies; released v2 compatibility was not established. Native compaction plus narrower context is the baseline. [15] |
| Large orchestration bundles and unattended retry loops | **Defer** | No demonstrated need before basic context and verification work. More agents add aggregate usage and review load. This is a fit recommendation, not a benchmark claiming every bundle is inferior. |
| T3 Code | **Optional later trial** | Public project supports OpenCode in general; released v2 compatibility was not established. Local Node `22.15.1` is below its README's stated Node 22 minimum of `22.16`. [8] |

Do not stack multiple browser controllers or memory/compression systems initially. Add one extension for one observed gap and compare results on similar tasks.

## 6. Laptop/server and tmux workflow

For projects already developed on Hetzner, make that server the normal execution location: checkout, OpenCode session, tests, development process. Connect via SSH and attach the same named tmux session from either personal machine. On VS Code, Remote SSH is an option for editing that same checkout. Independent/offline/work projects can keep local checkouts and their own providers; use portable task records when deliberately moving execution.

Suggested layout:

```text
tmux session: project-name
  window 1: Neovim / shell
  window 2: OpenCode
  window 3: tests / dev server / logs
```

Use `tmux new-session -A -s project-name` for create-or-attach. Name sessions and windows meaningfully. Add worktrees only for concurrent independent edits; a worktree separates files but not ports, databases, credentials, or process resources. Allocate those explicitly where necessary.

Tmux changes, in order:

1. Add `tmux-resurrect` before `tmux-continuum`, enable `@continuum-restore`, and verify a save/restore cycle. Restore is not a checkpoint of a running agent's in-memory execution; resume OpenCode's stored session explicitly. [16]
2. Replace the unconditional remote-inappropriate `wl-copy` binding with a tested terminal clipboard/OSC 52 approach or machine-aware fallback. Test Fedora terminal → SSH → tmux and Windows Terminal/WSL separately. [17]
3. Let continuum manage its documented status integration; review the manually embedded `continuum_save.sh` call before changing it. Simplify status to session/window/path/time and genuinely useful activity.
4. Review overlapping session-switch plugins. Keep one picker if built-in session/window selection is insufficient. CPU/network decorations are lower priority than reliable session switching.
5. Keep a machine-local override for desktop/server differences, outside the synchronized base configuration.

V2 also supports a local TUI connected to a remote OpenCode server. It is a later option, not required to obtain server persistence: credentials/tool execution remain server-side, project paths must refer to the server, and the external prompt editor runs client-side. SSH directly into the server avoids that split initially. [18]

## 7. Interactive through unattended work, with controlled usage

Define three workflows:

- **Discuss/plan:** clarify consequential uncertainty, explore relevant files, save the decision and acceptance criteria.
- **Build:** implement one bounded task and run its checks. Most routine coding fits here.
- **Background:** same acceptance criteria, a separate worktree if concurrent, explicit completion/stop conditions, and final evidence for later review.

V2 supports `opencode run` and `--auto`. Autoaccept preserves configured denies; noninteractive runs otherwise reject permission requests and cannot obtain useful answers to interactive questions. Supply required facts before dispatch. Plan mode and tool permissions are not OS-level isolation; denying the edit tool alone does not make unrestricted shell read-only. [19]

Cost policy to start:

- Keep the current subscription/provider mix until a demonstrated model limitation warrants another service.
- Use one capable default model at moderate effort. Escalate reasoning for difficult bugs/architecture or a justified review; do not use maximum effort for every question.
- One writer by default. Delegate independent research/review when its value exceeds duplicate context and coordination costs.
- Read relevant files and concise outputs. Keep complete logs in artifacts and return failing sections plus paths.
- After two unsuccessful repair attempts with no new evidence, require diagnosis and a new approach or report a blocker. This is a workflow limit, not a guaranteed billing cap.
- Resume relevant sessions; start fresh for unrelated work. Record durable knowledge outside chat. Avoid proactive context warming until usage measurements justify it.
- Compare accepted tasks, rework, human review effort, cumulative tokens and subscription quota. `opencode stats --days 7 --models --cost` is a useful v2 baseline. OAuth can show zero API cost while still consuming subscription allowance. [9][18]

## 8. V2 migration proposal for this repository

At research time, npm `@opencode/cli` latest was `2.0.3`. Stable v2 had only just appeared; the unversioned curl installer and npm latest did not resolve identically. Recheck release metadata at implementation and use one explicit tested version. Both v1 and v2 now use the `opencode` command. [1][20]

1. Preserve the executable/configuration and a consistent backup of OpenCode data before first v2 startup. Database/credential migrations mean a binary rollback alone is insufficient.
2. Identify installation ownership on each machine. This machine's binary is in `~/.opencode/bin`, whereas the native setup script installs globally through npm. Resolve that PATH/distribution inconsistency.
3. Update `setup-native.sh` to install the chosen v2 distribution with independent checks for OpenCode and Prettier. Preserve its existing uncommitted work.
4. Use built-in ChatGPT OAuth, testing an actual request. Headless login is documented as `opencode auth login openai --method chatgpt-headless`. Replace the old auth plugin only as part of the tested migration. Identify the work provider separately.
5. Keep supported v1-shaped settings initially if convenient. Remove obsolete overrides only after checking their behavior against the built-in catalog. Port plugins and server clients; JSON renaming alone cannot port an implementation.
6. Repair the existing command set. Connect Plannotator and test actual feedback, or use a functioning CLI command; remove inert acknowledgments only after the replacement works. Verify worktree/devcontainer commands against actual available tools.
7. Test one real Go/web project: instructions, old-session resumption, authentication/model choice, edits, checks, diff review, browser evidence, Neovim integration, tmux reconnect and unattended completion.
8. Migrate shared config to native v2 syntax only when useful. At research time the public server schema lagged the v2 docs; validate against the running release rather than blindly following editor schema suggestions.
9. Quit/restart clients and restart the relevant v2 service when applying startup-time changes. Verify the actual running version after updating; an installed binary and a still-running daemon can differ.
10. Review the intended dotfiles diff, then deliberately commit/push/pull when requested. Install equivalent tooling on the server/WSL; syncing config alone does not install dependencies or authenticate providers.

Important v2 gaps: its migration guide says OpenCode does not run LSP servers or produce LSP diagnostics; explicit compiler/lint/test commands are necessary. Neovim's own LSP remains separate. The instructions page also documents the inactive `instructions` field. [1][2]

## 9. Remaining decisions

- What is the actual provider/package name transcribed as “OpenCodeGoth” on the work laptop? OpenCode Go, GitHub Copilot, and a custom gateway require different handling.
- Which active repository should establish the first project-specific instructions and verification command?
- Does the existing Neovim integration need to work before v2 becomes the daily driver, or is side-by-side tmux sufficient during migration?

## Sources

All retrieved during this research snapshot; evolving READMEs describe source state, not proof of installed runtime behavior.

1. OpenCode v2 migration: https://opencode.ai/v2/docs/migrate-v1/
2. OpenCode v2 instructions: https://opencode.ai/v2/docs/instructions/
3. Boris Cherny original thread: https://x.com/bcherny/status/2007179832300581177 ; accessed mirror: https://threadreaderapp.com/thread/2007179832300581177.html
4. Mitchell Hashimoto, My AI Adoption Journey: https://mitchellh.com/writing/my-ai-adoption-journey
5. Simon Willison, Agentic manual testing: https://simonwillison.net/guides/agentic-engineering-patterns/agentic-manual-testing/
6. Matt Pocock skills: https://github.com/mattpocock/skills
7. DHH, Promoting AI agents: https://world.hey.com/dhh/promoting-ai-agents-3ee04945
8. T3 Code: https://github.com/pingdotgg/t3code
9. OpenCode compaction and commands: https://opencode.ai/v2/docs/compaction/ ; https://opencode.ai/v2/docs/cli/commands/
10. Microsoft's browser tooling comparison: https://github.com/microsoft/playwright-mcp ; CLI: https://github.com/microsoft/playwright-cli
11. Plannotator adapter: https://github.com/backnotprop/plannotator/blob/main/apps/opencode-plugin/server.ts ; manifest: https://github.com/backnotprop/plannotator/blob/main/apps/opencode-plugin/package.json ; published metadata: https://registry.npmjs.org/@plannotator/opencode/latest
12. Context7: https://github.com/upstash/context7
13. Neovim integration: https://github.com/nickjvandyke/opencode.nvim
14. Supermemory: https://github.com/supermemoryai/opencode-supermemory
15. DCP: https://github.com/Opencode-DCP/opencode-dynamic-context-pruning
16. tmux-continuum dependency/restore documentation: https://github.com/tmux-plugins/tmux-continuum
17. tmux clipboard reference for implementation: https://github.com/tmux/tmux/wiki/Clipboard
18. OpenCode CLI and providers: https://opencode.ai/v2/docs/cli/ ; https://opencode.ai/v2/docs/cli/providers/
19. OpenCode permissions and agents: https://opencode.ai/v2/docs/permissions/ ; https://opencode.ai/v2/docs/agents/
20. Distribution metadata: https://registry.npmjs.org/@opencode/cli ; https://opencode.ai/v2/install ; https://opencode.ai/update/api/latest/cli/npm
21. Anthropic engineering guidance, now redirected to Claude Code best practices: https://www.anthropic.com/engineering/claude-code-best-practices
