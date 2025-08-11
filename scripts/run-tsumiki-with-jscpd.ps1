param(
  [Parameter(Mandatory = $true)]
  [string]$Command,
  [switch]$Report,
  [switch]$SkipTemplate,
  [switch]$OpenOutputs,
  [string]$TasksFile
)

$ErrorActionPreference = 'Stop'

function Get-LatestTasksFile {
  param([string]$Specified)
  if ($Specified) {
    if (-not (Test-Path -LiteralPath $Specified)) {
      throw "Tasks file not found: $Specified"
    }
    return (Resolve-Path -LiteralPath $Specified).Path
  }
  $candidates = Get-ChildItem -Path (Join-Path $repoRoot 'docs/tasks') -Filter '*-tasks.md' -File -Recurse -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending
  if (-not $candidates -or $candidates.Count -eq 0) { return $null }
  return $candidates[0].FullName
}

function Open-PathCrossPlatform {
  param([string]$PathToOpen)
  try {
    if ($IsWindows) { Start-Process -FilePath $PathToOpen | Out-Null; return }
    if ($IsMacOS) { & open $PathToOpen | Out-Null; return }
    if ($IsLinux) { & xdg-open $PathToOpen | Out-Null; return }
  } catch { }
}

try {
  $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
} catch {
  Write-Host "❌ プロジェクトルートの解決に失敗しました: $_"
  exit 1
}

Push-Location $repoRoot
try {
  Write-Host "▶ tsumiki コマンド実行: $Command"
  & claude -p "$Command" | Out-Host
  Write-Host "✔ tsumiki コマンド終了"

  # Insert Cursor review template into the latest tasks doc (post-process)
  $tasksPath = $null
  if (-not $SkipTemplate.IsPresent) {
    try {
      $addScript = Join-Path $repoRoot 'scripts/add-cursor-review-template.ps1'
      if (Test-Path -LiteralPath $addScript) {
        if ($TasksFile) {
          & $addScript -Path $TasksFile | Out-Host
          $tasksPath = (Resolve-Path -LiteralPath $TasksFile).Path
        } else {
          & $addScript | Out-Host
          $tasksPath = Get-LatestTasksFile -Specified $null
        }
        Write-Host "✔ テンプレ挿入完了: $tasksPath"
      } else {
        Write-Host "⚠ 後処理スクリプトが見つかりませんでした: $addScript"
      }
    } catch {
      Write-Host "⚠ テンプレ挿入でエラーが発生しましたが続行します: $_"
    }
  }

  $frontendDir = Join-Path $repoRoot 'frontend'
  if (-not (Test-Path $frontendDir)) {
    Write-Host "❌ frontend ディレクトリが見つかりません: $frontendDir"
    exit 1
  }

  Push-Location $frontendDir
  try {
    Write-Host "▶ jscpd 実行 (npm run dup)"
    & npm run -s dup
    $dupExit = $LASTEXITCODE
    if ($dupExit -ne 0) {
      Write-Host "❌ jscpd のしきい値を超える重複が検出されました (exit=$dupExit)"
    } else {
      Write-Host "✔ jscpd 実行完了 (exit=0)"
    }

    if ($Report.IsPresent) {
      Write-Host "▶ jscpd レポート生成 (npm run dup:report)"
      & npm run -s dup:report
      $repExit = $LASTEXITCODE
      if ($repExit -ne 0) {
        Write-Host "❌ レポート生成に失敗しました (exit=$repExit)"
      } else {
        Write-Host "✔ レポート生成完了: reports/jscpd/html/index.html"
      }
    }
  }
  finally {
    Pop-Location
  }
}
finally {
  Pop-Location
}

if ($OpenOutputs.IsPresent) {
  try {
    if ($tasksPath) { Open-PathCrossPlatform -PathToOpen $tasksPath }
    $reportHtml = Join-Path $repoRoot 'reports/jscpd/html/index.html'
    if (Test-Path -LiteralPath $reportHtml) { Open-PathCrossPlatform -PathToOpen $reportHtml }
  } catch { }
}

exit $dupExit


