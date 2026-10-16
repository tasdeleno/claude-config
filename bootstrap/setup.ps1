# One-time laptop setup after `git clone` into ~/.claude.
# Usage (from the cloned ~/.claude):  powershell -ExecutionPolicy Bypass -File ./bootstrap/setup.ps1
# Prereqs: Node.js (for ECC + hooks) and the `claude` CLI installed.

$ErrorActionPreference = 'Stop'
$claudeDir = Split-Path $PSScriptRoot -Parent   # ...\.claude

# 1) ECC local plugin: separate git clone (not committed to this repo).
#    Clone the pinned commit, re-apply the local hook patch, then npm install.
$eccDir  = Join-Path $claudeDir 'plugins\ecc'
$eccSha  = '9ac593b55cba44c8b20152a5c7f28d300a67ec7e'
$eccPatch = Join-Path $PSScriptRoot 'ecc-local.patch'
if (-not (Test-Path (Join-Path $eccDir '.git'))) {
    Write-Host '== ECC: git clone ==' -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path (Split-Path $eccDir -Parent) | Out-Null
    git clone https://github.com/affaan-m/ECC $eccDir
    git -C $eccDir checkout $eccSha
    if (Test-Path $eccPatch) {
        Write-Host '== ECC: applying local patch ==' -ForegroundColor Cyan
        git -C $eccDir apply $eccPatch
    }
} elseif ((git -C $eccDir rev-parse HEAD) -ne $eccSha) {
    # Pin changed (sync.ps1 re-runs this script when it does). The clone is generated state:
    # its only local edit is ecc-local.patch, so a forced checkout + re-apply is safe.
    Write-Host "== ECC: moving to pinned $eccSha ==" -ForegroundColor Cyan
    # Refuse to discard anything except the patch's own files and lockfiles (npm rewrites those).
    $allowed = @('package-lock.json', 'yarn.lock')
    if (Test-Path $eccPatch) {
        $ErrorActionPreference = 'Continue'   # PS 5.1: native stderr under 'Stop' is a terminating error
        $allowed += @(git -C $eccDir apply --numstat $eccPatch 2>$null | ForEach-Object { ($_ -split "`t")[2] })
        $ErrorActionPreference = 'Stop'
    }
    $dirty = @(git -C $eccDir status --porcelain --untracked-files=no | ForEach-Object { $_.Substring(3) } | Where-Object { $allowed -notcontains $_ })
    if ($dirty.Count) { throw "ECC clone has local edits outside ecc-local.patch ($($dirty -join ', ')); move them into the patch first." }
    git -C $eccDir fetch --quiet origin
    if ($LASTEXITCODE -ne 0) { throw 'ECC: git fetch failed (offline?)' }
    git -C $eccDir checkout --quiet --force $eccSha
    if ($LASTEXITCODE -ne 0 -or (git -C $eccDir rev-parse HEAD) -ne $eccSha) { throw "ECC: could not check out $eccSha" }
    if (Test-Path $eccPatch) {
        $ErrorActionPreference = 'Continue'   # PS 5.1: native stderr under 'Stop' is a terminating error
        git -C $eccDir apply --check $eccPatch 2>$null
        $applies = ($LASTEXITCODE -eq 0)
        $ErrorActionPreference = 'Stop'
        if ($applies) {
            git -C $eccDir apply $eccPatch
            if ($LASTEXITCODE -ne 0) { throw 'ECC: applying ecc-local.patch failed' }
        } else { throw 'ecc-local.patch does not apply to the new pin; compare with upstream PR #3107, then update or drop the patch.' }
    }
} else {
    Write-Host 'ECC already at pinned commit - skipping clone/patch.' -ForegroundColor Yellow
}

# Portable settings.json: git stores it with $HOME paths and without Orca hooks (see settings-clean.js).
git -C $claudeDir config filter.portable-settings.clean 'node bootstrap/settings-clean.js'
git -C $claudeDir config filter.portable-settings.required true
Write-Host '== ECC: npm install ==' -ForegroundColor Cyan
Push-Location $eccDir
npm install
$npmExit = $LASTEXITCODE
Pop-Location
if ($npmExit -ne 0) { throw "ECC: npm install failed ($npmExit)" }

# 2) Auto-memory: the committed copy lives under the SOURCE machine's project folder
#    (C--Users-tasde--claude). Claude Code reads memory from a folder named after THIS
#    machine's ~/.claude path, so copy it there if the username differs.
$enc = ($claudeDir -replace '[^A-Za-z0-9]','-')   # Claude Code turns every non-alphanumeric char into '-'
$localMem  = Join-Path $claudeDir "projects\$enc\memory"
$sourceMem = Join-Path $claudeDir 'projects\C--Users-tasde--claude\memory'
if ((Test-Path $sourceMem) -and -not (Test-Path $localMem)) {
    Write-Host "== Memory: copying to projects\$enc\memory ==" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path (Split-Path $localMem -Parent) | Out-Null
    Copy-Item $sourceMem $localMem -Recurse
} else {
    Write-Host 'Memory already present for this machine (or source missing) — skipping.' -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'Next steps:' -ForegroundColor Green
Write-Host '  1) claude   (log in — this re-syncs skills/synced + plugins/synced from your account)'
Write-Host '  2) powershell -ExecutionPolicy Bypass -File ./bootstrap/plugins.ps1   (reinstall marketplace plugins)'
Write-Host '  3) Ensure Orca is installed if you use its hooks (Orca adds them to settings.json itself).'
Write-Host '  After that, every Claude Code session start runs bootstrap/sync.ps1 (pull/push + re-run changed bootstrap).'
