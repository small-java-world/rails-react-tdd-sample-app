# Compare local .claude/commands files to official Tsumiki repo (GitHub API)
# Usage:
#   pwsh ./scripts/compare-claude-commands-official.ps1
#   pwsh ./scripts/compare-claude-commands-official.ps1 -LocalDir .claude/commands -Repo classmethod/tsumiki -Ref main

param(
  [string]$LocalDir = ".claude/commands",
  [string]$Repo = "classmethod/tsumiki",
  [string]$Ref = "main"
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $LocalDir)) {
  Write-Error "LocalDir not found: $LocalDir"
  exit 1
}

$api = "https://api.github.com/repos/$Repo/contents/.claude/commands?ref=$Ref"
$headers = @{ 'User-Agent' = 'curl'; 'Accept' = 'application/vnd.github.v3+json' }
$resp = Invoke-WebRequest -UseBasicParsing -Headers $headers -Uri $api
$items = $resp.Content | ConvertFrom-Json

$upstreamMap = @{}
foreach ($it in $items) {
  if ($it.type -eq 'file') {
    $upstreamMap[$it.name] = $it.download_url
  }
}

$localFiles = Get-ChildItem -Path $LocalDir -File | Sort-Object Name

$rows = @()

# Check local files vs upstream
foreach ($f in $localFiles) {
  $name = $f.Name
  if (-not $upstreamMap.ContainsKey($name)) {
    $rows += [pscustomobject]@{ File = $name; Status = 'LOCAL_ONLY' }
    continue
  }
  $u = (Invoke-WebRequest -UseBasicParsing -Uri $upstreamMap[$name]).Content
  $l = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
  $ln = $l -replace "`r`n","`n" -replace "`r","`n"
  $un = $u -replace "`r`n","`n" -replace "`r","`n"
  if ($ln -eq $un) {
    $rows += [pscustomobject]@{ File = $name; Status = 'OK' }
  } else {
    $rows += [pscustomobject]@{ File = $name; Status = 'DIFF' }
  }
}

# Check upstream-only
foreach ($name in $upstreamMap.Keys | Sort-Object) {
  if (-not (Test-Path -LiteralPath (Join-Path $LocalDir $name))) {
    $rows += [pscustomobject]@{ File = $name; Status = 'UPSTREAM_ONLY' }
  }
}

$rows | Sort-Object Status, File | Format-Table -AutoSize | Out-String | Write-Output


