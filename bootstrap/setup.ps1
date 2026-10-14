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
} else {
    Write-Host 'ECC already present — skipping clone/patch.' -ForegroundColor Yellow
}
Write-Host '== ECC: npm install ==' -ForegroundColor Cyan
Push-Location $eccDir
npm install
Pop-Location

# 2) Auto-memory: the committed copy lives under the SOURCE machine's project folder
#    (C--Users-tasde--claude). Claude Code reads memory from a folder named after THIS
#    machine's ~/.claude path, so copy it there if the username differs.
$enc = ($claudeDir -replace '[:\\/.]','-')
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
Write-Host '  2) pwsh ./bootstrap/plugins.ps1   (reinstall marketplace plugins)'
Write-Host '  3) Ensure Orca is installed if you use its hooks (~/.orca/agent-hooks/claude-hook.cmd).'
