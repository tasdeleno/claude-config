# claude-config (~/.claude dotfiles)

My Claude Code setup — synced across machines via git. Works on any Windows machine and
username: committed paths use `$HOME` (Claude Code runs hook commands in Git Bash or
PowerShell — both expand `$HOME`, neither expands `%USERPROFILE%`).

> **Full setup & maintenance guide (Turkish): [`bootstrap/KURULUM.md`](bootstrap/KURULUM.md)** —
> prerequisites, fresh install, updating an already-cloned machine, `/brag` full mode, how the
> automatic sync works and what its messages mean, portable `settings.json`, memory sync, ECC pin
> upgrades, adding/removing plugins, verification, troubleshooting, eval set, known limits.

## What's tracked
- `CLAUDE.md`, `AGENTS.md` — global instructions
- `agents/`, `commands/`, `hooks/` — custom agents, slash commands, hooks
- `skills/` — standalone skills (minus cloud-synced + Orca junctions)
- `settings.json` — hooks/statusline/permissions wiring. A git clean filter
  (`bootstrap/settings-clean.js`, wired by `.gitattributes`) stores it with `$HOME` paths and
  without Orca's per-machine hooks, so local rewrites by Orca never show up as changes.
- `projects/C--Users-tasde--claude/memory/` — auto-memory (mirrored to other usernames' folders by `sync.ps1`)
- `bootstrap/` — restore + auto-sync scripts
- `evals/reviewers/` — reviewer eval set; `reports/` — improvement reports
- `backups/agents-archive-*/` — archived agents (restore with one `git mv`)

## What's NOT tracked (see `.gitignore`)
Secrets (`.credentials.json`), caches, logs, sessions, daemon/state, `settings.local.json`
(machine-local permissions), cloud-synced skills/plugins (`skills/synced`, `plugins/synced`
— restored by logging in), and the whole `plugins/` tree. Marketplace plugins are reinstalled
via `bootstrap/plugins.ps1`; the local ECC plugin is re-cloned + patched by
`bootstrap/setup.ps1` (pinned commit + `ecc-local.patch`).

## Restore on a new machine
Short version below; details, the already-cloned-machine case (e.g. the laptop) and
troubleshooting are in [`bootstrap/KURULUM.md`](bootstrap/KURULUM.md) §3–§4.
```powershell
# 1. Clone into ~/.claude (back up any existing one first)
cd $HOME
if (Test-Path .claude) { Rename-Item .claude ".claude.bak-$(Get-Date -f yyyyMMdd-HHmmss)" }
git clone https://github.com/tasdeleno/claude-config .claude

# 2. One-time setup: ECC npm install + memory placement
cd .claude
powershell -ExecutionPolicy Bypass -File ./bootstrap/setup.ps1

# 3. Log in (re-syncs account-bound skills/plugins), then reinstall marketplace plugins
claude            # log in
powershell -ExecutionPolicy Bypass -File ./bootstrap/plugins.ps1
```

Orca hooks (`~/.orca/agent-hooks/claude-hook.cmd`) live outside this repo — install the
Orca app on the new machine if you use them.

`/brag` full mode (Hyperframes render) also needs, outside this repo:
- **FFmpeg on PATH** — no admin needed: download `ffmpeg-n8.1-latest-win64-gpl-8.1.zip` from
  [BtbN/FFmpeg-Builds](https://github.com/BtbN/FFmpeg-Builds/releases), verify against
  `checksums.sha256`, extract to `%LOCALAPPDATA%\ffmpeg`, add its `bin` to the user PATH.
- **Kokoro TTS** (only for `/brag --voice`): `python -m pip install --user kokoro-onnx soundfile`.
- Check with `npx hyperframes doctor` (whisper-cpp, MusicGen and Docker are optional).

Prereqs on the new machine: Git for Windows, Node.js 22+, Python 3, the `claude` CLI, and
`gh auth login` (or any git credential) so the private repo can be pulled/pushed.

## Keep in sync (automatic)
After the one-time restore above, every Claude Code **session start** runs
`bootstrap/sync.ps1` (SessionStart hook, at most once per 30 min, ~3 s):
- pulls new commits — fast-forward only; never merges, rebases or forces
- pushes commits you already made on this machine (it never commits for you)
- mirrors auto-memory between the repo copy and this machine's folder (newer file wins)
- re-runs `setup.ps1` / `plugins.ps1` in the background (`run-bootstrap.ps1`) when their content
  changed since the last *successful* run (new plugin, new ECC pin); the first time a machine sees
  them it only records their hash. Both scripts are idempotent (only missing plugins are
  installed; ECC moves to a new pin only if the clone has no edits outside `ecc-local.patch`).
  A failed run is retried next start and reported in the session — log: `hooks-state/sync/bootstrap.log`
- warns (never updates) when an installed plugin's version differs from `bootstrap/plugins.lock.json`;
  Claude updates only when asked, following the CLAUDE.md "Plugin Güncelleme" rule
- prints one line into the session only when something happened or needs attention
  (local changes blocking a pull, diverged branches, failed push)

So: commit here → next session on the other machine picks it up (restart Claude Code to load
changed settings/agents). Disable with `CLAUDE_CONFIG_SYNC=off`. What each `[config-sync]`
message means and how to fix it: [`bootstrap/KURULUM.md`](bootstrap/KURULUM.md) §6.
