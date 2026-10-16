# Session-start sync for the ~/.claude dotfiles repo (any Windows machine, any username).
# Wired as a SessionStart hook in settings.json:
#   powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/bootstrap/sync.ps1"
#
# Safe by design:
#   - fast-forward pull only; pushes only commits that already exist; never merges, rebases or forces
#   - throttled to once per 30 minutes after a successful fetch; offline is silent and retried next start
#   - re-runs setup.ps1 / plugins.ps1 in the background (run-bootstrap.ps1) only when their content
#     changed since the last SUCCESSFUL run; a first sight on a machine only records the hash
#   - prints one line per issue into the session; silent when nothing happened
# Disable: set CLAUDE_CONFIG_SYNC=off. State/logs: hooks-state/sync/
# Keep this file ASCII-only: Windows PowerShell 5.1 misreads BOM-less UTF-8.

$ErrorActionPreference = 'Continue'
if ($env:CLAUDE_CONFIG_SYNC -eq 'off') { exit 0 }

$claude = Split-Path $PSScriptRoot -Parent
$state  = Join-Path $claude 'hooks-state\sync'
$stamp  = Join-Path $state 'last-run.txt'
New-Item -ItemType Directory -Force -Path $state | Out-Null
if ((Test-Path $stamp) -and ((Get-Date) - (Get-Item $stamp).LastWriteTime).TotalMinutes -lt 30) { exit 0 }

$env:GIT_TERMINAL_PROMPT = '0'
$msgs = @()

# 1) Portable-settings clean filter (local git config, idempotent). required: a filter crash blocks the
#    commit instead of silently storing machine-specific paths.
git -C $claude config filter.portable-settings.clean 'node bootstrap/settings-clean.js'
git -C $claude config filter.portable-settings.required true

# 2) Memory. Claude Code reads it from projects\<encoded path>\memory, where every non-alphanumeric
#    character of the ~/.claude path becomes '-'. The repo copy lives under the source machine's folder.
#    Mirror both ways, newer file wins; local -> repo BEFORE the pull, so local edits become git changes
#    and a conflicting pull refuses instead of overwriting them. Deletions are not propagated.
$enc      = ($claude -replace '[^A-Za-z0-9]', '-')
$repoMem  = Join-Path $claude 'projects\C--Users-tasde--claude\memory'
$localMem = Join-Path $claude "projects\$enc\memory"
$mirror   = ($localMem -ne $repoMem) -and (Test-Path $repoMem)
function Mirror($from, $to) {
    robocopy $from $to /E /XO /NJH /NJS /NFL /NDL /NP | Out-Null
    if ($LASTEXITCODE -ge 8) { $script:msgs += "[config-sync] memory copy $from -> $to failed (robocopy $LASTEXITCODE)." }
}
if ($mirror -and (Test-Path $localMem)) { Mirror $localMem $repoMem }

# 3) Pull or push.
$fetchErr = git -C $claude fetch --quiet 2>&1
if ($LASTEXITCODE -ne 0) {
    # offline/DNS: stay silent and retry next start; auth or missing remote: say so
    if ("$fetchErr" -match 'Authentication|Permission denied|could not read Username|not found|403|401') {
        $msgs += "[config-sync] git fetch failed (check 'gh auth status' / repo access): $fetchErr"
    }
} else {
    Set-Content -Path $stamp -Value (Get-Date -Format o)
    $counts = git -C $claude rev-list --left-right --count 'HEAD...@{u}' 2>$null
    if ($LASTEXITCODE -ne 0) {
        $msgs += "[config-sync] ~/.claude has no upstream branch; run 'git -C ~/.claude push -u origin main' once."
    } else {
        $parts = "$counts" -split '\s+'
        $ahead = [int]$parts[0]; $behind = [int]$parts[1]
        if ($behind -gt 0 -and $ahead -eq 0) {
            $out = git -C $claude pull --ff-only --quiet 2>&1
            if ($LASTEXITCODE -eq 0) { $msgs += "[config-sync] pulled $behind new commit(s) into ~/.claude; restart Claude Code to load changed settings/agents." }
            else { $msgs += "[config-sync] pull blocked by local changes in ~/.claude (see 'git -C ~/.claude status'; commit them, then the next start pushes/pulls): $out" }
        } elseif ($ahead -gt 0 -and $behind -eq 0) {
            $out = git -C $claude push --quiet 2>&1
            if ($LASTEXITCODE -eq 0) { $msgs += "[config-sync] pushed $ahead local commit(s) from ~/.claude." }
            else { $msgs += "[config-sync] push failed: $out" }
        } elseif ($ahead -gt 0 -and $behind -gt 0) {
            $msgs += "[config-sync] ~/.claude diverged from origin (ahead $ahead, behind $behind); run 'git -C ~/.claude pull --rebase' by hand."
        }
    }
}

if ($mirror) { Mirror $repoMem $localMem }

# 4) Bootstrap scripts: report the last background result, then start a new run if content changed.
$changed = @()
foreach ($name in 'setup.ps1', 'plugins.ps1') {
    $statusFile = Join-Path $state "$name.status"
    if ((Test-Path $statusFile) -and ((Get-Content $statusFile -Raw) -match '^FAILED')) {
        $msgs += "[config-sync] last background $name run failed: $((Get-Content $statusFile -Raw).Trim()) (logs: $state\bootstrap.log, bootstrap.err.log)"
    }
    $hash = (Get-FileHash -Path (Join-Path $PSScriptRoot $name) -Algorithm SHA256).Hash
    $hashFile = Join-Path $state "$name.sha256"
    if (-not (Test-Path $hashFile)) { Set-Content -Path $hashFile -Value $hash; continue }  # first sight: adopt
    if ($hash -ne (Get-Content $hashFile -Raw).Trim()) { $changed += $name }
}
if ($changed.Count -gt 0) {
    $runner = Join-Path $PSScriptRoot 'run-bootstrap.ps1'
    Start-Process -FilePath 'powershell' -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $state 'bootstrap.log') -RedirectStandardError (Join-Path $state 'bootstrap.err.log') `
        -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$runner`"", '-Name', ($changed -join ','))
    $msgs += "[config-sync] bootstrap changed ($($changed -join ', ')); re-running in background, log: $state\bootstrap.log"
}

# 5) Plugin versions vs bootstrap/plugins.lock.json: WARN only, never update. The message tells Claude
#    the safe procedure (CLAUDE.md "Plugin Guncelleme"); updating is the user's call.
$lockFile = Join-Path $PSScriptRoot 'plugins.lock.json'
if (Test-Path $lockFile) {
    $installed = @{}
    try { (claude plugin list --json 2>$null | ConvertFrom-Json) | ForEach-Object { $installed[$_.id] = "$($_.version)" } } catch { }
    if ($installed.Count -gt 0) {   # ponytail: CLI missing/failing -> skip silently; plugins.ps1 reports install problems
        $behind = @(); $ahead = @(); $lock = $null
        try { $lock = Get-Content $lockFile -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop }
        catch { $msgs += "[config-sync] bootstrap/plugins.lock.json could not be read (version check skipped): $($_.Exception.Message)" }
        foreach ($prop in @($lock.PSObject.Properties | Where-Object { $lock })) {
            $id = $prop.Name; $want = "$($prop.Value)"
            if (-not $installed.ContainsKey($id) -or $installed[$id] -eq $want) { continue }   # missing = plugins.ps1's job
            $have = $installed[$id]; $hv = $null; $wv = $null
            if ([version]::TryParse($have, [ref]$hv) -and [version]::TryParse($want, [ref]$wv) -and $hv -gt $wv) { $ahead += "$id $have (lock $want)" }
            else { $behind += "$id $have (lock $want)" }
        }
        if ($behind.Count) { $msgs += "[config-sync] plugin version behind/different from bootstrap/plugins.lock.json: $($behind -join '; '). Tell the user; do NOT update unless asked. If asked, follow CLAUDE.md 'Plugin Guncelleme' (only 'claude plugin update <id>'; never touch agents/, skills/, hooks/, CLAUDE.md, settings.json or plugins/cache)." }
        if ($ahead.Count)  { $msgs += "[config-sync] plugin newer here than bootstrap/plugins.lock.json: $($ahead -join '; '). If intended, run 'bootstrap/plugins.ps1 -Record' and commit so other machines get the warning." }
    }
}

if ($msgs.Count -gt 0) { $msgs -join "`n" }
exit 0
