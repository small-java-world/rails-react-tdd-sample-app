# Compare local .claude/commands files to upstream originals
# Usage:
#   pwsh ./scripts/compare-claude-commands.ps1
#   pwsh ./scripts/compare-claude-commands.ps1 -LocalDir ../tumiki-sample-project/.claude/commands

param(
  [string]$LocalDir = ".claude/commands",
  [string]$UpstreamBase = "https://raw.githubusercontent.com/classmethod/tsumiki/main/.claude/commands"
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $LocalDir)) {
  Write-Error "LocalDir not found: $LocalDir"
  exit 1
}

$files = Get-ChildItem -Path $LocalDir -File | Sort-Object Name
foreach ($f in $files) {
  $name = $f.Name
  $url = "$UpstreamBase/$name"
  try {
    $u = (Invoke-WebRequest -UseBasicParsing -Uri $url).Content
  } catch {
    Write-Output ("MISSING_UPSTREAM {0}" -f $name)
    continue
  }
  $l = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
  $ln = $l -replace "`r`n","`n" -replace "`r","`n"
  $un = $u -replace "`r`n","`n" -replace "`r","`n"
  if ($ln -eq $un) {
    Write-Output ("OK {0}" -f $name)
  } else {
    Write-Output ("DIFF {0}" -f $name)
  }
}


