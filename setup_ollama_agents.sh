#!/usr/bin/env bash
# One-time setup for running this repo's HexStrike AI alongside PentestGPT and Strix,
# all on a local Ollama model (e.g. Qwen) instead of a paid API.
# Only use against systems you own or are explicitly authorized to test.
set -euo pipefail
cd "$(dirname "$0")"
ROOT="$(pwd)"
MODEL="${QWEN_MODEL:-qwen2.5:14b}"

echo "==> Checking Ollama"
if ! command -v ollama >/dev/null; then
  echo "Ollama not found. Install it from https://ollama.com/download and re-run this script."
  exit 1
fi
ollama list | grep -q "^${MODEL}" || ollama pull "$MODEL"

echo "==> HexStrike AI (this repo)"
[ -d hexstrike_env ] || python3 -m venv hexstrike_env
./hexstrike_env/bin/pip install -r requirements.txt
./hexstrike_env/bin/pip install mcp-client-for-ollama

echo "==> PentestGPT (legacy interactive mode, native Ollama support)"
if [ ! -d "$ROOT/pentestgpt" ]; then
  git clone https://github.com/GreyDGL/PentestGPT "$ROOT/pentestgpt"
fi
if ! command -v uv >/dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi
(cd "$ROOT/pentestgpt" && make install)

echo "==> Strix"
if ! command -v strix >/dev/null; then
  curl -sSL https://strix.ai/install | bash
  export PATH="$HOME/.local/bin:$PATH"
fi
command -v docker >/dev/null || echo "WARNING: Docker not found — Strix needs it to sandbox targets."

echo
echo "Setup done. Model: $MODEL"
echo "Next:"
echo "  ./run_ollama.sh          # HexStrike's 150 tools via ollmcp"
echo "  ./run_pentestgpt.sh      # PentestGPT legacy interactive mode"
echo "  ./run_strix.sh <target>  # Strix autonomous pentest"
