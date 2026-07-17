#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../server"

command -v node >/dev/null 2>&1 || {
  echo "Node.js is not installed or unavailable in PATH. Install Node.js 20 LTS."
  exit 1
}
command -v npm >/dev/null 2>&1 || {
  echo "npm is not installed or unavailable in PATH. Install Node.js 20 LTS."
  exit 1
}

if [[ ! -f .env ]]; then
  echo "server/.env is missing. Copy .env.example to .env and add OPENAI_API_KEY."
  exit 1
fi

if [[ ! -d node_modules ]]; then
  npm install
fi

npm start
