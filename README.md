# claude-config (~/.claude dotfiles)

My Claude Code setup — synced across machines via git. Paths are portable
(`%USERPROFILE%`), so the same repo works on any Windows username.

## What's tracked
- `CLAUDE.md`, `AGENTS.md` — global instructions
- `agents/`, `commands/`, `hooks/` — custom agents, slash commands, hooks
- `skills/` — standalone skills (minus cloud-synced + Orca junctions)
- `settings.json` — hooks/statusline/permissions wiring (portable paths)
- `projects/C--Users-tasde--claude/memory/` — auto-memory
- `bootstrap/` — restore scripts

## What's NOT tracked (see `.gitignore`)
Secrets (`.credentials.json`), caches, logs, sessions, daemon/state, `settings.local.json`
(machine-local permissions), cloud-synced skills/plugins (`skills/synced`, `plugins/synced`
— restored by logging in), and the whole `plugins/` tree. Marketplace plugins are reinstalled
via `bootstrap/plugins.ps1`; the local ECC plugin is re-cloned + patched by
`bootstrap/setup.ps1` (pinned commit + `ecc-local.patch`).

## Restore on a new machine
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

## Keep in sync later
```powershell
cd $HOME/.claude
git add -A && git commit -m "chore: config güncelle" && git push
# other machine:
git pull
```
