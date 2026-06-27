#!/bin/bash
# ============================================
#  Freebuff Looping - SETUP (Linux/Mac/Bash)
#  Run once: ./setup.sh
# ============================================

set -e

# Pre-flight checks
command -v git >/dev/null 2>&1 || { echo "[ERROR] git not installed!"; exit 1; }
command -v freebuff >/dev/null 2>&1 || command -v codebuff >/dev/null 2>&1 || { echo "[ERROR] freebuff/codebuff not installed!"; exit 1; }

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
PROJECT_NAME="$(basename "$PROJECT_ROOT")"
PARENT_DIR="$(dirname "$PROJECT_ROOT")"

echo "============================================="
echo "  Freebuff Looping - SETUP"
echo "============================================="
echo ""
echo "Project: $PROJECT_NAME"
echo "Root:    $PROJECT_ROOT"
echo "Parent:  $PARENT_DIR"
echo ""

# Step 1: Init git if needed
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    echo "[1/5] Initializing git repo..."
    cd "$PROJECT_ROOT"
    git init
    git checkout -b main
else
    echo "[1/5] Git repo exists — skipping init."
fi

# Step 2: Create initial commit if needed
cd "$PROJECT_ROOT"
if ! git rev-parse HEAD >/dev/null 2>&1; then
    echo "[2/5] Creating initial commit..."
    git add -A
    if git diff --cached --quiet 2>/dev/null; then
        # Allow empty commit for fresh repo
        git commit --allow-empty -m "Initial commit (freebuff-looping setup)"
    else
        git commit -m "Initial commit (freebuff-looping setup)"
    fi
else
    echo "[2/5] Git commit exists — skipping."
fi

# Step 3: Create worktrees
WT1="$PARENT_DIR/${PROJECT_NAME}-w1"
WT2="$PARENT_DIR/${PROJECT_NAME}-w2"

echo "[3/5] Creating worktrees..."

if ! git worktree list 2>/dev/null | grep -q "${PROJECT_NAME}-w1"; then
    echo "  - Creating worker-1 worktree..."
    git worktree add -b worker-1 "$WT1" main
else
    echo "  - Worktree worker-1 already exists."
fi

if ! git worktree list 2>/dev/null | grep -q "${PROJECT_NAME}-w2"; then
    echo "  - Creating worker-2 worktree..."
    git worktree add -b worker-2 "$WT2" main
else
    echo "  - Worktree worker-2 already exists."
fi

# Step 4: Create config directories (NESTED structure!)
echo "[4/5] Setting up worker config directories..."

# Worker 1: HOME=~/.config/manicode-w1 → freebuff cari $HOME/.config/manicode/
mkdir -p "$HOME/.config/manicode-w1/.config/manicode"

# Worker 2: HOME=~/.config/manicode-w2 → freebuff cari $HOME/.config/manicode/
mkdir -p "$HOME/.config/manicode-w2/.config/manicode"

if [ -f "$HOME/.config/manicode/credentials.json" ]; then
    cp "$HOME/.config/manicode/credentials.json" "$HOME/.config/manicode-w1/.config/manicode/"
    cp "$HOME/.config/manicode/credentials.json" "$HOME/.config/manicode-w2/.config/manicode/"
    echo "  - Credentials copied to worker configs."
else
    echo "  - WARNING: No credentials found. You'll need to login in each worker."
fi

# Step 5: Done
echo "[5/5] Setup complete!"
echo ""
echo "============================================="
echo "  SETUP SELESAI! Cara mulai:"
echo ""
echo "  Orchestrator:  ./start-orchestrator.sh"
echo "  Worker 1:      ./start-worker1.sh"
echo "  Worker 2:      ./start-worker2.sh"
echo "============================================="
