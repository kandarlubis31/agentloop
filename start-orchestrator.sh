#!/bin/bash
# ============================================
#  AgentLoop - Orchestrator Launcher
#  Usage: ./start-orchestrator.sh
# ============================================

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "============================================="
echo "  AgentLoop - ORCHESTRATOR"
echo "============================================="
echo ""
echo "Project: $PROJECT_ROOT"
echo "Config:  \$HOME/.config/manicode"
echo "Mode:    Orchestrator (planning & monitoring)"
echo ""
echo "============================================="
echo "  COPY-PASTE isi orchestrator-prompt.md"
echo "  LALU kasih task besar ke orchestrator!"
echo "============================================="
echo ""

cd "$PROJECT_ROOT"
freebuff
