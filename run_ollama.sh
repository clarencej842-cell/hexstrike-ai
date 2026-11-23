#!/usr/bin/env bash
# HexStrike AI + Ollama (Qwen) launcher.
# Usage: ./run_ollama.sh [model]   (default: qwen2.5:14b)
# Only use against systems you own or are authorized to test.
set -euo pipefail
cd "$(dirname "$0")"
DIR="$(pwd)"
MODEL="${1:-qwen2.5:14b}"
PORT=8888

command -v ollama >/dev/null || { echo "Install Ollama first: https://ollama.com"; exit 1; }

# 1. venv + dependencies (first run only)
if [ ! -d hexstrike_env ]; then
  python3 -m venv hexstrike_env
  ./hexstrike_env/bin/pip install -r requirements.txt
fi
./hexstrike_env/bin/pip show mcp-client-for-ollama >/dev/null 2>&1 || ./hexstrike_env/bin/pip install mcp-client-for-ollama

# 2. model
ollama list | grep -q "^${MODEL}" || ollama pull "$MODEL"

# 3. MCP config with absolute paths (no auto-approve)
cat > hexstrike.json <<JSON
{
  "mcpServers": {
    "hexstrike-ai": {
      "command": "$DIR/hexstrike_env/bin/python3",
      "args": ["$DIR/hexstrike_mcp.py", "--server", "http://127.0.0.1:$PORT"]
    }
  }
}
JSON

# 4. start the API server if it isn't already up
if ! curl -sf "http://127.0.0.1:$PORT/health" >/dev/null; then
  ./hexstrike_env/bin/python3 hexstrike_server.py --port "$PORT" > hexstrike_server.out 2>&1 &
  SERVER_PID=$!
  trap 'kill $SERVER_PID 2>/dev/null' EXIT
  for _ in $(seq 1 30); do curl -sf "http://127.0.0.1:$PORT/health" >/dev/null && break; sleep 1; done
fi
curl -sf "http://127.0.0.1:$PORT/health" >/dev/null || { echo "Server failed to start; see hexstrike_server.out"; exit 1; }

# 5. chat with Qwen using HexStrike tools
./hexstrike_env/bin/ollmcp --servers-json hexstrike.json --model "$MODEL"
