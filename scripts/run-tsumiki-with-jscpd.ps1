param(
  [Parameter(Mandatory = $true)]
  [string]$Command,
  [switch]$Report
)

$ErrorActionPreference = 'Stop'

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

exit $dupExit


