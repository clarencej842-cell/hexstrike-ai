#!/usr/bin/env bash
# Run Strix against a target, using a local Ollama model (e.g. Qwen) instead of a paid API.
# Usage: ./run_strix.sh <target-path-or-url> [extra strix args...]
# Needs Docker running. Requires ./setup_ollama_agents.sh to have installed the strix CLI.
# Only use against systems you own or are explicitly authorized to test.
set -euo pipefail
MODEL="${QWEN_MODEL:-qwen2.5:14b}"
TARGET="${1:-}"
shift || true

if [ -z "$TARGET" ]; then
  echo "Usage: $0 <target-path-or-url> [extra strix args]"
  exit 1
fi

command -v strix >/dev/null || { echo "strix not found; run ./setup_ollama_agents.sh first."; exit 1; }
command -v docker >/dev/null || { echo "Docker is required for Strix's sandbox."; exit 1; }

# Strix uses LiteLLM-style provider/model strings. For a local Ollama model, that's
# "ollama/<model>" with LLM_API_BASE pointing at the Ollama server; LLM_API_KEY is
# required by the CLI but ignored by Ollama, so any placeholder value works.
export STRIX_LLM="ollama/${MODEL}"
export LLM_API_BASE="${OLLAMA_BASE_URL:-http://localhost:11434}"
export LLM_API_KEY="${LLM_API_KEY:-ollama-local}"

exec strix --target "$TARGET" "$@"
