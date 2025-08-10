# Add "Cursor レビュー依頼テンプレート" to the latest tasks doc after the "実行コマンド例" section
# Usage:
#   pwsh ./scripts/add-cursor-review-template.ps1               # auto-detect latest tasks file under docs/tasks
#   pwsh ./scripts/add-cursor-review-template.ps1 -Path path/to/tasks.md

param(
  [Parameter(Position=0)]
  [string]$Path
)

$ErrorActionPreference = 'Stop'

function Get-TasksFilePath {
  param([string]$p)
  if ($p) {
    if (-not (Test-Path -LiteralPath $p)) {
      throw "File not found: $p"
    }
    return (Resolve-Path -LiteralPath $p).Path
  }
  $candidates = Get-ChildItem -Path "docs/tasks" -Filter "*-tasks.md" -File -Recurse -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
  if (-not $candidates -or $candidates.Count -eq 0) {
    throw "No tasks file found under docs/tasks. Specify -Path explicitly."
  }
  return $candidates[0].FullName
}

function ConvertToFullWidthDigits {
  param([string]$input)
  $map = @{ '0'='０'; '1'='１'; '2'='２'; '3'='３'; '4'='４'; '5'='５'; '6'='６'; '7'='７'; '8'='８'; '9'='９' }
  $s = $input
  foreach ($k in $map.Keys) { $s = $s -replace [regex]::Escape($k), $map[$k] }
  return $s
}

function BuildTemplateForTasks {
  param([System.Text.RegularExpressions.MatchCollection]$matches)
  $nl = [Environment]::NewLine
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.AppendLine("### Cursor レビュー依頼テンプレート")
  [void]$sb.AppendLine()
  [void]$sb.AppendLine("tsumiki のスラッシュコマンド実行後に、以下を Cursor にコピペしてください。")
  [void]$sb.AppendLine()

  foreach ($m in $matches) {
    $taskId = $m.Groups[1].Value
    if (-not $taskId) { continue }
    $taskIdFull = ConvertToFullWidthDigits $taskId

    # /tdd-green
    [void]$sb.AppendLine("#### TASK-$taskIdFull /tdd-green 用")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("```text")
    [void]$sb.AppendLine("TASK-$taskIdFull に対する /tdd-green の成果物をレビューしてください。")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("対象:")
    [void]$sb.AppendLine("- 機能: ユーザープリファレンス UI の最小実装（Theme / Refresh Interval / Display Density）")
    [void]$sb.AppendLine("- 変更ファイル（例）:")
    [void]$sb.AppendLine("  - frontend/src/UserPreferences.jsx")
    [void]$sb.AppendLine("  - frontend/src/UserPreferences.test.jsx")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("確認観点:")
    [void]$sb.AppendLine("- 要件の満たし方（REQ-001, REQ-101, REQ-102）")
    [void]$sb.AppendLine("- テストの妥当性と網羅性（Red → Green が成立しているか）")
    [void]$sb.AppendLine("- 命名・責務分割・可読性（過剰な実装がないか）")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("補足:")
    [void]$sb.AppendLine("- ローカルでテストはグリーンです（npm test）。")
    [void]$sb.AppendLine("```")
    [void]$sb.AppendLine()

    # /tdd-refactor
    [void]$sb.AppendLine("#### TASK-$taskIdFull /tdd-refactor 用")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("```text")
    [void]$sb.AppendLine("TASK-$taskIdFull に対する /tdd-refactor の成果物をレビューしてください。")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("対象:")
    [void]$sb.AppendLine("- 重複排除・命名改善・責務整理のリファクタリング")
    [void]$sb.AppendLine("- 変更ファイル（例）:")
    [void]$sb.AppendLine("  - frontend/src/UserPreferences.jsx")
    [void]$sb.AppendLine("  - frontend/src/UserPreferences.test.jsx")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("確認観点:")
    [void]$sb.AppendLine("- 動作は維持されているか（テストはグリーン）")
    [void]$sb.AppendLine("- 重複の削減・見通しの良さ・拡張性")
    [void]$sb.AppendLine("- コンポーネント分割と依存方向が適切か")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("補足:")
    [void]$sb.AppendLine("- 必要に応じて重複検出ツール（jscpd など）の観点もお願いします。")
    [void]$sb.AppendLine("```")
    [void]$sb.AppendLine()
  }
  return $sb.ToString()
}

function InsertTemplateAfterCommandsSection {
  param([string]$text, [string]$template)

  # If already present anywhere, do not insert again
  if ($text -match "###\s*Cursor\s+レビュー依頼テンプレート") {
    Write-Host "🔁 Template already present. Skipping insertion."
    return $text
  }

  $commandsHeaderPattern = "###\s*実行コマンド例"
  $headerMatch = [regex]::Match($text, $commandsHeaderPattern)
  if (-not $headerMatch.Success) {
    throw "Commands section (### 実行コマンド例) not found."
  }

  # Find the end of the first fenced code block after the header
  $postHeader = $text.Substring($headerMatch.Index + $headerMatch.Length)
  $openingFenceIndex = $postHeader.IndexOf("```")
  if ($openingFenceIndex -lt 0) { throw "Opening code fence after commands header not found." }
  $rest = $postHeader.Substring($openingFenceIndex + 3)
  $closingFenceIndex = $rest.IndexOf("```")
  if ($closingFenceIndex -lt 0) { throw "Closing code fence for commands block not found." }

  $insertPos = $headerMatch.Index + $headerMatch.Length + $openingFenceIndex + 3 + $closingFenceIndex + 3
  $before = $text.Substring(0, $insertPos)
  $after = $text.Substring($insertPos)

  $insertion = "`r`n`r`n" + $template.TrimEnd() + "`r`n"
  return $before + $insertion + $after
}

try {
  $filePath = Get-TasksFilePath -p $Path
  Write-Host "📝 Target: $filePath"
  $raw = Get-Content -LiteralPath $filePath -Raw -Encoding UTF8

  $taskMatches = [regex]::Matches($raw, "####\s*TASK-(\d{3,}):\s*(.+)")
  if ($taskMatches.Count -eq 0) {
    Write-Warning "No TASK-xxx headings found. The template will still be inserted for TASK-００１ only."
    # fabricate a single task id
    $temp = New-Object System.Collections.ArrayList
    [void]$temp.Add(([regex]::Match("#### TASK-001: dummy", "####\s*TASK-(\d{3,}):\s*(.+)")))
    $taskMatches = $temp
  }

  $template = BuildTemplateForTasks -matches $taskMatches
  $updated = InsertTemplateAfterCommandsSection -text $raw -template $template

  if ($updated -ne $raw) {
    Set-Content -LiteralPath $filePath -Value $updated -Encoding UTF8 -NoNewline:$false
    Write-Host "✅ Inserted review template for $($taskMatches.Count) task(s)."
  }
}
catch {
  Write-Error $_
  exit 1
}


