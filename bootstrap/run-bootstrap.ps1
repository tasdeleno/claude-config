# Background runner for bootstrap/setup.ps1 or plugins.ps1, started by sync.ps1 when the script changed.
# Records the script hash ONLY on success, so a failed run is retried next session and reported by
# sync.ps1 (it reads <name>.status). Started with -File and no in-PowerShell redirection: under PS 5.1,
# redirecting native stderr (npm/git warnings) turns it into terminating errors in 'Stop' scripts.
# Keep this file ASCII-only (Windows PowerShell 5.1 misreads BOM-less UTF-8).
# -Name takes a comma-separated list ("setup.ps1,plugins.ps1"): powershell -File cannot pass arrays.
param([Parameter(Mandatory = $true)][string]$Name)
$Name = @($Name -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
foreach ($n in $Name) { if ($n -notin 'setup.ps1', 'plugins.ps1') { throw "unknown bootstrap script: $n" } }

$state = Join-Path (Split-Path $PSScriptRoot -Parent) 'hooks-state\sync'
$lock  = Join-Path $state 'bootstrap.lock'

# ponytail: lock-file mutex; a crashed run leaves a stale lock that is ignored after 2 hours
if ((Test-Path $lock) -and ((Get-Date) - (Get-Item $lock).LastWriteTime).TotalHours -lt 2) { exit 0 }
Set-Content -Path $lock -Value $PID
$failed = $false
try {
    foreach ($n in $Name) {
        $status = Join-Path $state "$n.status"
        $script = Join-Path $PSScriptRoot $n
        try {
            $hash = (Get-FileHash -Path $script -Algorithm SHA256).Hash
            $global:LASTEXITCODE = 0
            & $script
            if ($LASTEXITCODE -ne 0) { throw "$n exited with code $LASTEXITCODE" }
            Set-Content -Path (Join-Path $state "$n.sha256") -Value $hash
            Set-Content -Path $status -Value "OK $(Get-Date -Format o)"
        } catch {
            Set-Content -Path $status -Value "FAILED $(Get-Date -Format o) $($_.Exception.Message)"
            $failed = $true
        }
    }
} finally {
    Remove-Item -Path $lock -ErrorAction SilentlyContinue
}
if ($failed) { exit 1 }
