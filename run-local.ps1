$ErrorActionPreference = 'Stop'

$configPath = Join-Path $PSScriptRoot 'config\local.json'
if (-not (Test-Path -LiteralPath $configPath)) {
  throw 'config/local.json is missing. Copy config/local.example.json and add real client-safe values first.'
}

flutter run -d windows `
  --dart-define-from-file="$configPath"
