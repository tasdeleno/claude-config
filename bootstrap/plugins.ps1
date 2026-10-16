# Reinstall marketplace plugins on a fresh machine.
# Derived from installed_plugins.json + known_marketplaces.json on the source PC (2026-10-14).
# Run AFTER `claude` is installed and you have logged in.
# Usage:  powershell -ExecutionPolicy Bypass -File ./bootstrap/plugins.ps1

$ErrorActionPreference = 'Continue'

$marketplaces = @(
    'anthropics/claude-plugins-official',
    'forrestchang/andrej-karpathy-skills',
    'openai/codex-plugin-cc',
    'AgriciDaniel/claude-seo',
    'DietrichGebert/ponytail',
    'pbakaus/impeccable',
    'nextlevelbuilder/ui-ux-pro-max-skill',
    'uditgoenka/autoresearch',
    'AgriciDaniel/claude-ads',
    'latent-spaces/brag',
    'heygen-com/hyperframes'
)

$plugins = @(
    'andrej-karpathy-skills@karpathy-skills',
    'codex@openai-codex',
    'frontend-design@claude-plugins-official',
    'claude-seo@agricidaniel-claude-seo',
    'ponytail@ponytail',
    'impeccable@impeccable',
    'ui-ux-pro-max@ui-ux-pro-max-skill',
    'autoresearch@autoresearch',
    'figma@claude-plugins-official',
    'claude-ads@ai-marketing-hub-claude-ads',
    'brag@brag',
    'hyperframes@hyperframes'
)

# Idempotent: only adds/installs what is missing, so sync.ps1 can re-run it whenever this file changes.
$haveRepos   = @(claude plugin marketplace list --json | ConvertFrom-Json | ForEach-Object { $_.repo })
$havePlugins = @(claude plugin list --json | ConvertFrom-Json | ForEach-Object { $_.id })
$failures = 0

Write-Host '== Adding marketplaces ==' -ForegroundColor Cyan
foreach ($m in $marketplaces | Where-Object { $haveRepos -notcontains $_ }) {
    Write-Host "  + $m"
    claude plugin marketplace add $m
    if ($LASTEXITCODE -ne 0) { $failures++ }
}

Write-Host '== Installing plugins ==' -ForegroundColor Cyan
foreach ($p in $plugins | Where-Object { $havePlugins -notcontains $_ }) {
    Write-Host "  + $p"
    claude plugin install $p
    if ($LASTEXITCODE -ne 0) { $failures++ }
}

if ($failures -gt 0) { Write-Warning "$failures marketplace/plugin step(s) failed"; exit 1 }
Write-Host 'Done. Run `claude plugin list` to verify.' -ForegroundColor Green
exit 0
