# Ollama Pentest Agent Stack

This fork wires three AI pentesting tools to run on a local **Ollama** model instead of a
paid API, so the whole stack can run offline.

| Tool | Upstream | Role |
|---|---|---|
| **HexStrike AI** | this repo (`0x4m4/hexstrike-ai`) | MCP server exposing 150+ security tools (nmap, nuclei, sqlmap, etc.) as callable functions. |
| **PentestGPT** | `github.com/GreyDGL/PentestGPT` | Multi-stage reasoning agent; has **native** Ollama support in its "legacy" interactive mode. |
| **Strix** | `github.com/usestrix/strix` | Autonomous multi-agent pentester that runs targets in a Docker sandbox and validates exploits with real PoCs. |

Default model: **`qwen2.5:14b`** (tool-calling capable; use a bigger one if your machine can
run it — small models struggle to orchestrate many tools reliably).

> ⚠️ **Only point any of these at systems you own or are explicitly authorized to test.**
> They execute real scanning/exploitation tools and can run autonomously — review each
> tool's command before letting it run unattended against a live target.

## 1. One-time setup

```bash
chmod +x setup_ollama_agents.sh
./setup_ollama_agents.sh
```

This installs Ollama's `qwen2.5:14b` model, sets up this repo's Python venv for HexStrike,
clones and builds PentestGPT into `./pentestgpt` (git-ignored — it's a separate upstream
project, not vendored into this fork), and installs the `strix` CLI.

## 2. Running each tool against Qwen

```bash
./run_ollama.sh                   # HexStrike's 150 tools, interactive chat via ollmcp
./run_pentestgpt.sh               # PentestGPT legacy interactive mode (type target, then next/discuss)
./run_strix.sh <target-path-or-url>  # Strix autonomous pentest
```

Swap the model everywhere with `QWEN_MODEL`, e.g. `QWEN_MODEL=qwen2.5:32b ./run_strix.sh ./app`.

## 3. Notes

- Ollama must be running (`ollama serve`) and reachable at `http://localhost:11434`.
- Strix also needs Docker running — it sandboxes the target in a container.
- HexStrike's 150 tools only work if their underlying CLI programs (nmap, gobuster, nuclei, …)
  are installed on your machine; the server reports which ones it found at `/health`.
- PentestGPT's legacy mode is interactive — there's no fixed `--target` flag; you describe
  the target once the session starts.
