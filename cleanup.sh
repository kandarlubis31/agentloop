#!/bin/bash
# ============================================
#  Freebuff Looping - CLEANUP
#  Remove worktrees, config dirs, branches
#  Usage: ./cleanup.sh
# ============================================

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
PROJECT_NAME="$(basename "$PROJECT_ROOT")"
PARENT_DIR="$(dirname "$PROJECT_ROOT")"

echo "============================================="
echo "  Freebuff Looping - CLEANUP"
echo "============================================="
echo ""
echo "This will remove:"
echo "  - Worktrees: ${PROJECT_NAME}-w1, ${PROJECT_NAME}-w2"
echo "  - Branches: worker-1, worker-2"
echo "  - Config dirs: ~/.config/manicode-w1, ~/.config/manicode-w2"
echo "  - Runtime files: queue/*.json, results/*.json, in-progress/*.json"
echo ""

read -p "Continue? (y/N): " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Aborted."
    exit 0
fi

cd "$PROJECT_ROOT" || exit 1

# Remove worktrees
echo ""
echo "[1/3] Removing worktrees..."
for wt in w1 w2; do
    WT_PATH="$PARENT_DIR/${PROJECT_NAME}-${wt}"
    if git worktree list 2>/dev/null | grep -q "${PROJECT_NAME}-${wt}"; then
        echo "  - Removing $WT_PATH..."
        git worktree remove "$WT_PATH" 2>/dev/null || {
            echo "    Force removing..."
            git worktree remove --force "$WT_PATH" 2>/dev/null
        }
    fi
    # Clean up leftover directory
    [ -d "$WT_PATH" ] && rm -rf "$WT_PATH" && echo "    Cleaned leftover directory."
done

# Remove branches
echo "[2/3] Removing branches..."
git branch -D worker-1 2>/dev/null || true
git branch -D worker-2 2>/dev/null || true

# Remove config dirs
echo "[3/3] Removing worker config dirs..."
rm -rf "$HOME/.config/manicode-w1"
rm -rf "$HOME/.config/manicode-w2"

# Clean runtime files
echo "    Cleaning queue/results/in-progress..."
rm -f "$PROJECT_ROOT/queue/"*.json 2>/dev/null
rm -f "$PROJECT_ROOT/results/"*.json 2>/dev/null
rm -f "$PROJECT_ROOT/in-progress/"*.json 2>/dev/null

echo ""
echo "============================================="
echo "  CLEANUP COMPLETE!"
echo "============================================="
