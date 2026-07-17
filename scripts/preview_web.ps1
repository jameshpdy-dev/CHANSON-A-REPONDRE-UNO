$ErrorActionPreference = 'Stop'

$repositoryBasePath = '/CHANSON-A-REPONDRE-UNO/'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$previewRoot = Join-Path $projectRoot '.preview'
$previewApp = Join-Path $previewRoot 'CHANSON-A-REPONDRE-UNO'

Push-Location $projectRoot
try {
  flutter build web --release `
    --base-href $repositoryBasePath

  Copy-Item `
    build\web\index.html `
    build\web\404.html `
    -Force

  if (Test-Path -LiteralPath $previewApp) {
    $resolvedPreview = (Resolve-Path -LiteralPath $previewApp).Path
    if (-not $resolvedPreview.StartsWith($previewRoot)) {
      throw "Refusing to remove an unexpected preview path: $resolvedPreview"
    }
    Remove-Item -LiteralPath $resolvedPreview -Recurse -Force
  }

  New-Item -ItemType Directory -Force $previewApp | Out-Null
  Copy-Item build\web\* $previewApp -Recurse -Force

  Write-Host ''
  Write-Host 'Preview URL:'
  Write-Host 'http://localhost:8080/CHANSON-A-REPONDRE-UNO/'
  Write-Host ''

  Push-Location $previewRoot
  try {
    python -m http.server 8080
  } finally {
    Pop-Location
  }
} finally {
  Pop-Location
}
