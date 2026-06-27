# 🔁 Freebuff Looping System

> **Break Freebuff's single-session limit!** Run multiple Freebuff/Codebuff sessions simultaneously on the same project using Git Worktrees + HOME override.

## 🤔 The Problem

Freebuff (Codebuff free tier) limits you to **1 active session**. Open a second terminal → "takeover" (steals your existing session instead of creating a new one).

Why? Because `~/.config/manicode/freebuff-instance-owner.json` stores a **global PID** — if that PID is alive, Freebuff takes over regardless of what directory you're in.

## 💡 The Solution

Give each Freebuff session its **own config directory** via `HOME` override, so each gets its own `instance-owner.json`:

```
Orchestrator  →  HOME: ~/.config/manicode/        (normal)
Worker 1      →  HOME: ~/.config/manicode-w1/      (override)
Worker 2      →  HOME: ~/.config/manicode-w2/      (override)
```

3 config dirs = 3 independent sessions = no takeover! 🎉

## 📦 Quick Start (30 seconds)

```bash
# 1. Copy file-file ini ke project lo:
#    queue/ results/ task-template.json result-template.json
#    orchestrator-prompt.md worker-prompt.md
#    setup.sh setup.bat start-*.sh start-*.bat
#    CONTEXT.md USAGE.md

# 2. Run setup (creates worktrees + worker configs)
./setup.sh          # Linux/Mac/Git Bash
# OR
setup.bat           # Windows CMD

# 3. Start sessions
./start-orchestrator.sh    # Terminal 1 — planning & monitoring
./start-worker1.sh         # Terminal 2 — executes tasks
./start-worker2.sh         # Terminal 3 — executes tasks
```

> 💡 **Pake di project manapun**: Copy file-file di atas ke root project lo, lalu run `./setup.sh`.
> Gak perlu clone repo terpisah — sistem ini didesain sebagai **drop-in tool**.

## 🧠 How It Works

```
┌─ Orchestrator ──────────────┐    HOME: normal
│ Pecah task besar → queue/   │    
└──────────────┬──────────────┘    
               │ delegate via JSON files
      ┌────────┴────────┐
      ▼                 ▼
┌─ Worker 1 ───┐  ┌─ Worker 2 ───┐   HOME: manicode-w1
│ Scan queue/  │  │ Scan queue/  │   HOME: manicode-w2
│ Execute task │  │ Execute task │
│ Write result │  │ Write result │
│ Git commit   │  │ Git commit   │
└──────┬───────┘  └──────┬───────┘
       └────────┬────────┘
                ▼
     ┌─ Orchestrator ──────┐
     │ Read results/       │
     │ Git merge workers   │
     │ Repeat... (LOOP 🔁) │
     └─────────────────────┘
```

## 🗂️ File Structure

```
your-project/
├── queue/                  ← Task files (pending jobs)
├── in-progress/            ← Tasks being worked on
├── results/                ← Worker outputs
├── README.md               ← This file
├── USAGE.md                ← Detailed usage guide
├── CONTEXT.md              ← System internals
├── orchestrator-prompt.md  ← Prompt for orchestrator session
├── worker-prompt.md        ← Prompt for worker sessions
├── task-template.json      ← JSON template for tasks
├── result-template.json    ← JSON template for results
├── setup.sh / setup.bat    ← One-time setup scripts
├── start-orchestrator.*    ← Launch orchestrator
├── start-worker1.*         ← Launch worker 1
├── start-worker2.*         ← Launch worker 2
└── test-takeover.sh        ← Verify no takeover
```

## 🎯 Use With Any AI Agent

This system is **agent-agnostic**! The queue system (JSON files in `queue/` → `results/`) works with:

| Agent | How to use |
|-------|-----------|
| **Freebuff / Codebuff** | Built-in support (native) |
| **Claude Code** | Copy orchestrator prompt → Claude plans → writes queue/ → another Claude session executes |
| **Cursor / Copilot** | Use queue JSON as task context |
| **Any CLI agent** | Start with `HOME=... agent-cli`, feed `worker-prompt.md` |

## 🔧 Requirements

- Freebuff / Codebuff installed (`npm install -g codebuff` or `npm install -g freebuff`)
- Git
- Bash (Linux/Mac/Git Bash) or Windows CMD

## 📄 License

MIT — do whatever you want, no warranty.

---

Made with ❤️ by the Freebuff community. PRs welcome!
