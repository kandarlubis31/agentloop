#!/bin/bash
# test-takeover.sh — Bypass takeover pake HOME override
# Jalanin di Git Bash / bash

echo "============================================="
echo "  Freebuff Looping - HOME Override Test"
echo "============================================="
echo ""

BASE="C:/Users/KandarLubis/Desktop/Project/dan lain lain"
CONFIG_W1="$HOME/.config/manicode-w1"

echo "[1] Setup config worker..."
mkdir -p "$CONFIG_W1"
cp "$HOME/.config/manicode/credentials.json" "$CONFIG_W1/" 2>/dev/null
echo "    Config worker siap di: $CONFIG_W1"
echo ""

echo "[2] Cek instance-owner SAAT INI..."
cat "$HOME/.config/manicode/freebuff-instance-owner.json" 2>/dev/null
echo ""

echo "[3] BUKA TERMINAL BARU (jangan tutup ini!)"
echo ""
echo "    Ketik ini di terminal baru:"
echo "    ┌────────────────────────────────────────────────────┐"
echo "    │ cd \"$BASE/freebuffdual-w1\"                         │"
echo "    │ HOME=\"$CONFIG_W1\" freebuff                         │"
echo "    └────────────────────────────────────────────────────┘"
echo ""
echo "[4] HARUSNYA worker jalan TANPA takeover!"
echo "    ✅ Session baru → BERHASIL"
echo "    ❌ Takeover / another session → GAGAL"
echo ""
echo "[5] Di worker, ketik:"
echo "    'Tulis hello dari worker HOME override ke test-loop.txt'"
echo ""
echo "[6] Di orchestrator (INI), ketik:"
echo "    'Baca test-loop.txt dan verifikasi isinya'"
echo ""
echo "============================================="
echo "  Kalau worker jalan tanpa takeover"
echo "  → HOME OVERRIDE BERHASIL BYPASS LOCK! 🔥"
echo "============================================="
