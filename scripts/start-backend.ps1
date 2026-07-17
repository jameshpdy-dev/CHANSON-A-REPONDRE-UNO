$ErrorActionPreference = "Stop"

$serverPath = Join-Path $PSScriptRoot "..\server"
Set-Location $serverPath

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    throw "Node.js is not installed or unavailable in PATH. Install Node.js 20 LTS and restart the terminal."
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    throw "npm is not installed or unavailable in PATH. Install Node.js 20 LTS and restart the terminal."
}

if (-not (Test-Path ".env")) {
    throw "server/.env is missing. Copy .env.example to .env and add OPENAI_API_KEY."
}

if (Get-NetTCPConnection -State Listen -LocalPort 3000 -ErrorAction SilentlyContinue) {
    throw "Port 3000 is already in use. Stop the owning process or set the same alternate port in server/.env and AI_BACKEND_URL."
}

if (-not (Test-Path "node_modules")) {
    npm.cmd install
}

npm.cmd start
