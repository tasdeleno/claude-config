#!/usr/bin/env node
/**
 * git "clean" filter for settings.json (wired by .gitattributes + bootstrap/sync.ps1 / setup.ps1).
 * Makes the COMMITTED copy portable to any Windows machine / username:
 *  - `<drive>:/Users/<name>/` (and the `\\` form) -> `$HOME/`.
 *    Claude Code runs hook commands in Git Bash or PowerShell; both expand $HOME,
 *    neither expands %USERPROFILE% (verified: MODULE_NOT_FOUND in a 2026-10-14 transcript).
 *  - drops Orca-injected hooks (`.orca/agent-hooks`): Orca rewrites them on every machine
 *    where it is installed; committing them breaks machines without Orca.
 * The working copy is never touched; only what git stores. Invalid JSON passes through unchanged.
 */
'use strict';

const fs = require('fs');

// Runs on parsed JSON strings, so a Windows path has single backslashes here.
const HOME_RE = /[A-Za-z]:[\/\\]Users[\/\\][^\/\\"]+[\/\\]/g;

function portable(value) {
  if (typeof value === 'string') return value.replace(HOME_RE, '$$HOME/');
  if (Array.isArray(value)) return value.map(portable);
  if (value && typeof value === 'object') {
    const out = {};
    for (const [k, v] of Object.entries(value)) out[k] = portable(v);
    return out;
  }
  return value;
}

function dropOrcaHooks(hooks) {
  const out = {};
  for (const [event, groups] of Object.entries(hooks)) {
    if (!Array.isArray(groups)) { out[event] = groups; continue; }
    const kept = groups
      .map(g => ({ ...g, hooks: (g.hooks || []).filter(h => !String(h.command || '').includes('.orca/agent-hooks')) }))
      .filter(g => g.hooks.length > 0);
    if (kept.length) out[event] = kept;
  }
  return out;
}

// Never throws: on any unexpected shape the input passes through unchanged (git would otherwise
// fall back to storing the raw file). filter.portable-settings.required=true makes a crash block the commit.
function clean(raw) {
  try {
    const settings = JSON.parse(raw);
    if (!settings || typeof settings !== 'object' || Array.isArray(settings)) return raw;
    if (settings.hooks && typeof settings.hooks === 'object') settings.hooks = dropOrcaHooks(settings.hooks);
    return JSON.stringify(portable(settings), null, 2) + '\n';
  } catch {
    return raw;
  }
}

if (require.main === module) {
  process.stdout.write(clean(fs.readFileSync(0, 'utf8')));
} else {
  module.exports = { clean };
}
