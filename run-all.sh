#!/bin/bash
# ============================================
#  AgentLoop - RUN ALL (One-Click!)
#  Spawns 3 tmux panes: Orchestrator + 2 Workers
#  Usage: ./run-all.sh
#  Requires: tmux
# ============================================

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
PROJECT_NAME="$(basename "$PROJECT_ROOT")"
PARENT_DIR="$(dirname "$PROJECT_ROOT")"
SESSION="freebuff-loop"

WT1="$PARENT_DIR/${PROJECT_NAME}-w1"
WT2="$PARENT_DIR/${PROJECT_NAME}-w2"

# Check tmux
if ! command -v tmux >/dev/null 2>&1; then
    echo "============================================="
    echo "  tmux NOT installed!"
    echo "  Install: sudo apt install tmux"
    echo "  Or use the manual launchers:"
    echo "    ./start-orchestrator.sh"
    echo "    ./start-worker1.sh"
    echo "    ./start-worker2.sh"
    echo "============================================="
    exit 1
fi

# Check freebuff
if ! command -v freebuff >/dev/null 2>&1 && ! command -v codebuff >/dev/null 2>&1; then
    echo "[ERROR] freebuff not found!"
    exit 1
fi

# Check worktrees exist
if [ ! -d "$WT1" ] || [ ! -d "$WT2" ]; then
    echo "[ERROR] Worktrees not found. Run ./setup.sh first!"
    exit 1
fi

# Kill existing session if any
tmux kill-session -t "$SESSION" 2>/dev/null

echo "============================================="
echo "  🚀 AgentLoop — RUN ALL"
echo "============================================="
echo ""
echo "  Spawning 3-pane tmux session:"
echo "  ┌──────────────────┬──────────────────┐"
echo "  │   Orchestrator   │    Worker 1      │"
echo "  │   (HOME normal)  │  (HOME override) │"
echo "  ├──────────────────┼──────────────────┤"
echo "  │   instructions   │    Worker 2      │"
echo "  │   (this pane)    │  (HOME override) │"
echo "  └──────────────────┴──────────────────┘"
echo ""
echo "  Starting in 2 seconds..."
sleep 2

# Create session with first pane (instructions)
tmux new-session -d -s "$SESSION" -n loop -c "$PROJECT_ROOT"
tmux send-keys -t "$SESSION:loop.0" "clear" Enter
tmux send-keys -t "$SESSION:loop.0" "echo '┌─────────────────────────────────────────┐'" Enter
tmux send-keys -t "$SESSION:loop.0" "echo '│  🔁 AgentLoop — ALL SYSTEMS GO! │'" Enter
tmux send-keys -t "$SESSION:loop.0" "echo '├─────────────────────────────────────────┤'" Enter
tmux send-keys -t "$SESSION:loop.0" "echo '│ ORCHESTRATOR (top-left)                │'" Enter
tmux send-keys -t "$SESSION:loop.0" "echo '│   → copy-paste orchestrator-prompt.md  │'" Enter
tmux send-keys -t "$SESSION:loop.0" "echo '│ WORKER 1 (top-right)                   │'" Enter
tmux send-keys -t "$SESSION:loop.0" "echo '│   → copy-paste worker-prompt.md        │'" Enter
tmux send-keys -t "$SESSION:loop.0" "echo '│ WORKER 2 (bottom-right)                │'" Enter
tmux send-keys -t "$SESSION:loop.0" "echo '│   → copy-paste worker-prompt.md        │'" Enter
tmux send-keys -t "$SESSION:loop.0" "echo '│ Press Ctrl+B then Arrow to switch pane │'" Enter
tmux send-keys -t "$SESSION:loop.0" "echo '└─────────────────────────────────────────┘'" Enter

# Split horizontally → right side
tmux split-window -h -t "$SESSION:loop.0" -c "$WT1"
# Override HOME for worker 1
tmux send-keys -t "$SESSION:loop.1" "export HOME=\"\$HOME/.config/manicode-w1\"" Enter
tmux send-keys -t "$SESSION:loop.1" "clear" Enter
tmux send-keys -t "$SESSION:loop.1" "echo '===== WORKER 1 =====' && echo 'Config: \$HOME' && echo 'Run: copy-paste worker-prompt.md' && echo ''" Enter
tmux send-keys -t "$SESSION:loop.1" "freebuff" Enter

# Split bottom-right → Worker 2
tmux split-window -v -t "$SESSION:loop.1" -c "$WT2"
tmux send-keys -t "$SESSION:loop.2" "export HOME=\"\$HOME/.config/manicode-w2\"" Enter
tmux send-keys -t "$SESSION:loop.2" "clear" Enter
tmux send-keys -t "$SESSION:loop.2" "echo '===== WORKER 2 =====' && echo 'Config: \$HOME' && echo 'Run: copy-paste worker-prompt.md' && echo ''" Enter
tmux send-keys -t "$SESSION:loop.2" "freebuff" Enter

# Go back to orchestrator pane (top-left)
tmux select-pane -t "$SESSION:loop.0"
# Start orchestrator
tmux send-keys -t "$SESSION:loop.0" "cd \"$PROJECT_ROOT\"" Enter
tmux send-keys -t "$SESSION:loop.0" "clear" Enter
tmux send-keys -t "$SESSION:loop.0" "echo '===== ORCHESTRATOR =====' && echo 'Config: ~/.config/manicode (normal)' && echo 'Run: copy-paste orchestrator-prompt.md' && echo ''" Enter
tmux send-keys -t "$SESSION:loop.0" "freebuff" Enter

# Give orchestrator more horizontal space (wider instructions pane)
tmux resize-pane -t "$SESSION:loop.0" -x 55 2>/dev/null || true

# Attach to session
tmux attach-session -t "$SESSION"
