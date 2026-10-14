# Reinstall marketplace plugins on a fresh machine.
# Derived from installed_plugins.json + known_marketplaces.json on the source PC (2026-10-14).
# Run AFTER `claude` is installed and you have logged in.  Usage:  pwsh ./bootstrap/plugins.ps1

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
    'AgriciDaniel/claude-ads'
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
    'claude-ads@ai-marketing-hub-claude-ads'
)

Write-Host '== Adding marketplaces ==' -ForegroundColor Cyan
foreach ($m in $marketplaces) {
    Write-Host "  + $m"
    claude plugin marketplace add $m
}

Write-Host '== Installing plugins ==' -ForegroundColor Cyan
foreach ($p in $plugins) {
    Write-Host "  + $p"
    claude plugin install $p
}

Write-Host 'Done. Run `claude plugin list` to verify.' -ForegroundColor Green
