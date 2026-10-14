---
name: orca-windows-account-bug
description: "Orca (stablyai/orca) Windows \"Add Account\" hang bug — root cause, workaround script, filed issue link"
metadata: 
  node_type: memory
  type: project
  originSessionId: f755f859-32b8-442c-b5c2-2c0a46a3062e
  modified: 2026-08-16T18:49:15.121Z
---

Orca (open-source Claude Code desktop wrapper, https://github.com/stablyai/orca, installed at `C:\Users\tasde\AppData\Local\Programs\orca`) has a Windows bug: both the GUI "Add Account" button and the `orca account add` CLI hang/timeout when adding a managed Claude account. Root cause (confirmed via direct testing): `orca.exe` runs as the Electron binary in `ELECTRON_RUN_AS_NODE=1` mode, and when it spawns `claude auth login` as a child, the child never actually reads stdin (pasted OAuth code sits in the console input buffer unconsumed until the process is killed). Separately, `claude auth login --claudeai` also doesn't auto-open the browser on native Windows at all (unrelated to Orca), so the manual "paste code back" flow is always required.

Filed as https://github.com/stablyai/orca/issues/14932 (2026-08-16), under GitHub account `tasdeleno` (gh CLI already authenticated with repo+workflow scopes on this machine). Issue includes a draft fix (`src/shared/windows-console-stdio.ts`, opens fresh CONIN$/CONOUT$ handles on win32 instead of inheriting) but PR not opened yet — user wants to wait, not just push a PR unprompted. [[opsiyonel-secimleri-tek-tek-sor]]

**Working workaround** (used to actually add a second account for the user): log into `claude.exe` directly (not through Orca) with a scratch `CLAUDE_CONFIG_DIR`, then call Orca's local RPC method `accounts.addClaudeFromConfigDir` directly over its named pipe (endpoint + authToken read from `%APPDATA%\orca\orca-runtime.json`, protocol is newline-delimited JSON `{id, authToken, method, params}` — see `src/cli/runtime/transport.ts` in the orca repo). This bypasses both broken interactive paths entirely. A working Node script for this exists in the session scratchpad as `add-claude-account.cjs` (not persisted elsewhere — recreate from the issue body if needed again).

**Why:** user runs multiple Claude accounts and wants to switch between them in Orca when one hits its rate limit.
**How to apply:** if the user asks again about adding/switching Claude accounts in Orca on Windows, don't re-diagnose from scratch — check issue #14932 for current status first, and reuse the RPC workaround if "Add Account" is still broken.
