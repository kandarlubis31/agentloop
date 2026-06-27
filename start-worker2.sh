#!/bin/bash
# ============================================
#  AgentLoop - Worker 2 Launcher
#  Usage: ./start-worker2.sh
# ============================================

# Prerequisite check
command -v freebuff >/dev/null 2>&1 || command -v codebuff >/dev/null 2>&1 || {
    echo "[ERROR] freebuff not found in PATH!"
    echo "        Install: npm install -g freebuff"
    exit 1
}

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
PARENT_DIR="$(dirname "$PROJECT_ROOT")"
PROJECT_NAME="$(basename "$PROJECT_ROOT")"
WT="$PARENT_DIR/${PROJECT_NAME}-w2"

export HOME="$HOME/.config/manicode-w2"

echo "============================================="
echo "  AgentLoop - WORKER 2"
echo "============================================="
echo ""
echo "Project:  $WT"
echo "Config:   $HOME"
echo "Mode:     Worker 2 (task execution)"
echo ""
echo "============================================="
echo "  COPY-PASTE isi worker-prompt.md"
echo "  Worker akan auto-scan queue/ & eksekusi!"
echo "============================================="
echo ""

if [ ! -d "$WT" ]; then
    echo "[ERROR] Worktree folder not found: $WT"
    echo "        Run ./setup.sh first!"
    exit 1
fi

cd "$WT"
freebuff
