# 🔁 Freebuff Looping System

> **Break Freebuff's single-session limit!** Run multiple Freebuff/Codebuff sessions simultaneously on the same project using Git Worktrees + HOME override.

## 🤔 The Problem

Freebuff limits you to **1 active session**. Open a second terminal → "takeover" (steals your session).

Why? `~/.config/manicode/freebuff-instance-owner.json` stores a **global PID** — if alive, Freebuff takes over regardless of directory.

## 💡 The Solution

Give each Freebuff session its **own config directory** via `HOME` override:

```
Orchestrator  →  HOME: ~/.config/manicode/        (normal)
Worker 1      →  HOME: ~/.config/manicode-w1/      (override)
Worker 2      →  HOME: ~/.config/manicode-w2/      (override)
```

3 config dirs = 3 independent `instance-owner.json` = no takeover! 🎉

## ⚡ One-Click (Easiest)

```bash
./run-all.sh        # Linux/Mac (tmux — 3 panes in 1 window)
run-all.bat         # Windows (3 CMD windows auto-launched)
```

> 💡 **Double-click `run-all.bat`** → 3 terminals launch with correct configs automatically!
> See **[DEMO.md](DEMO.md)** for full visual walkthrough.

## 📦 Quick Start

### 1. Copy files to your project

Copy these to your project's root:
```
queue/  results/  in-progress/
task-template.json  result-template.json
orchestrator-prompt.md  worker-prompt.md
setup.sh  setup.bat  cleanup.sh  cleanup.bat
start-orchestrator.sh  start-orchestrator.bat
start-worker1.sh  start-worker1.bat
start-worker2.sh  start-worker2.bat
CONTEXT.md
```

### 2. Run setup (once)

```bash
./setup.sh          # Linux/Mac/Git Bash
# OR
setup.bat           # Windows CMD
```

Setup will: init git (if needed) → create 2 worktrees → config directories → copy credentials.

### 3. Start sessions

| Terminal | Command | Role |
|----------|---------|------|
| **1** | `./start-orchestrator.sh` or `.bat` | Planning & monitoring |
| **2** | `./start-worker1.sh` or `.bat` | Task execution |
| **3** | `./start-worker2.sh` or `.bat` | Task execution |

### 4. Workflow

**Terminal 1 (Orchestrator):** Copy-paste `orchestrator-prompt.md`, then:
> "Bikin fullstack todo app. Pecah jadi sub-tasks independen, tulis ke queue/"

**Terminal 2 (Worker 1):** Copy-paste `worker-prompt.md` → worker auto-scans `queue/` and executes 1 task.

**Terminal 3 (Worker 2):** Same, takes a different task.

**Back to Terminal 1:**
> "Cek results/, merge branch worker-1 dan worker-2"

This is the **loop**! 🔁 Orchestrator keeps writing tasks until the project is done.

### 5. Cleanup

```bash
./cleanup.sh        # Linux/Mac/Git Bash
# OR
cleanup.bat         # Windows CMD
```

---

## 🧠 Architecture

```
User gives big task
        │
        ▼
┌─ Orchestrator ──────────────┐    HOME: normal
│ Decompose → write queue/    │    
└──────────────┬──────────────┘    
               │ delegate via JSON files
      ┌────────┴────────┐
      ▼                 ▼
┌─ Worker 1 ───┐  ┌─ Worker 2 ───┐   HOME: manicode-w1
│ Scan queue/  │  │ Scan queue/  │   HOME: manicode-w2
│ Atomic grab  │  │ Atomic grab  │   (isolated!)
│ Execute task │  │ Execute task │
│ Write result │  │ Write result │
│ Git commit   │  │ Git commit   │
└──────┬───────┘  └──────┬───────┘
       └────────┬────────┘
                ▼
     ┌─ Orchestrator ──────┐
     │ Read results/       │
     │ Git merge workers   │
     │ More tasks? → LOOP  │
     └─────────────────────┘
```

### Why HOME override matters

```
With HOME override, each worker has its own instance-owner.json:
~/.config/manicode/              → Orchestrator PID: 1234
~/.config/manicode-w1/           → Worker 1 PID: 5678
     └── .config/manicode/
~/.config/manicode-w2/           → Worker 2 PID: 9012
     └── .config/manicode/

3 instance-owners = 3 parallel sessions ✅
```

### Task collision prevention

Workers use **atomic file move** to claim tasks:
1. Worker scans `queue/` for `status: "pending"`
2. **Moves** (renames) file to `in-progress/` — this is atomic
3. If move fails → another worker already claimed it → try next task
4. Only AFTER successful move, reads and executes the task

---

## 📝 Task Format (queue/task-XXX.json)

```json
{
  "id": "task-001",
  "type": "code-generation",
  "assigned_to": null,
  "prompt": "Bikin file src/services/AuthService.ts dengan method: login, register, logout. TypeScript strict. Jangan pake any. Export class.",
  "context_files": ["src/models/User.ts", "package.json"],
  "output_files": ["src/services/AuthService.ts"],
  "depends_on": [],
  "status": "pending",
  "created_at": "2026-06-27T12:00:00Z"
}
```

> ⚠️ **CRITICAL**: `prompt` must be **hyper-detailed**. Workers won't ask questions — they'll execute as-is.

---

## 📊 Result Format (results/result-XXX.json)

```json
{
  "task_id": "task-001",
  "worker": "worker-1",
  "status": "completed",
  "summary": "Created AuthService class with login, register, logout",
  "files_created": ["src/services/AuthService.ts"],
  "files_modified": [],
  "errors": [],
  "notes": "Used bcrypt for password hashing",
  "completed_at": "2026-06-27T12:05:00Z"
}
```

---

## 🎯 Use With Other AI Agents

This system is **agent-agnostic**! The core mechanism is dead simple: JSON files in a folder. ANY agent that can `readFile` / `writeFile` can participate.

### The Universal Pattern

```
┌──────────────────────────────────────────────┐
│              SHARED PROJECT (Git)             │
│                                              │
│  queue/         ← ONE agent writes tasks     │
│  in-progress/   ← Atomic claim (rename file) │
│  results/       ← Agents write outputs       │
│                                              │
│  Any agent can be orchestrator OR worker!    │
└──────────────────────────────────────────────┘
```

### How to use with specific agents:

| Agent | As Orchestrator | As Worker |
|-------|----------------|-----------|
| **Freebuff / Codebuff** | `freebuff` → copy-paste `orchestrator-prompt.md` | `HOME=~/.config/manicode-w1 freebuff` → copy-paste `worker-prompt.md` |
| **Claude Code** | `claude` → "Read orchestrator-prompt.md and follow it" | `claude` → "Read worker-prompt.md and follow it" (Claude doesn't need HOME override) |
| **Cursor / Windsurf** | Open chat → paste orchestrator prompt | Open chat → paste worker prompt → point to queue/ |
| **Aider** | `aider` → "You are the orchestrator..." | `aider` → "You are a worker. Scan queue/..." |
| **Copilot Chat** | Paste orchestrator prompt | Paste worker prompt with project context |
| **Any CLI agent** | `AGENT_CLI` → feed orchestrator prompt | `AGENT_CLI` → feed worker prompt |

### Key insight: HOME override is Freebuff-specific

Other agents (Claude Code, Cursor, Aider) don't have Freebuff's takeover problem — they allow multiple sessions natively. **But the queue system works universally** — just skip the HOME override and use the JSON files for orchestration.

For non-Freebuff agents, simplify to:
```bash
# Orchestrator
cd project && your-agent

# Worker (no HOME override needed!)
cd project-w1 && your-agent
```

---

## 📈 Scaling: 3+ Workers

Need more than 2 workers? The pattern scales:

```bash
# Add worker 3
git worktree add -b worker-3 ../project-w3 main
mkdir -p ~/.config/manicode-w3/.config/manicode
cp ~/.config/manicode/credentials.json ~/.config/manicode-w3/.config/manicode/

# Launch
cd ../project-w3
HOME="$HOME/.config/manicode-w3" freebuff
```

Create `start-worker3.sh` / `start-worker3.bat` following the same template. Orchestrator merges with `git merge worker-3`.

---

## 🔧 Requirements

- Freebuff / Codebuff (`npm install -g freebuff`)
- Git
- Bash (Linux/Mac/Git Bash) or Windows CMD

---

## 🗂️ File List

```
your-project/
├── queue/                     ← Task files (pending)
├── in-progress/               ← Tasks actively being worked
├── results/                   ← Completed task outputs
├── README.md                  ← You are here
├── DEMO.md                    ← Visual walkthrough with screenshots
├── CONTEXT.md                 ← System internals (for AI agents)
├── orchestrator-prompt.md     ← Copy-paste for orchestrator
├── worker-prompt.md           ← Copy-paste for workers
├── task-template.json         ← Task JSON template
├── result-template.json       ← Result JSON template
├── setup.sh / setup.bat       ← One-time setup
├── cleanup.sh / cleanup.bat   ← Tear down everything
├── run-all.sh / run-all.bat   ← ONE-CLICK launch all 3! ⚡
├── start-orchestrator.*       ← Individual launcher
├── start-worker1.* / 2.*      ← Individual launchers
├── test-takeover.*            ← Verify bypass works
├── .gitignore / .gitattributes
└── LICENSE                    ← MIT
```

---

## ❓ Troubleshooting

| Problem | Solution |
|---------|----------|
| "Takeover" still appears | Ensure you're using `HOME=...` before `freebuff`. On Windows CMD, both `HOME` and `USERPROFILE` must be overridden. |
| Worker can't find tasks | Check `queue/` has `.json` files with `"status": "pending"` |
| Worker asks questions | Task prompt isn't detailed enough — add specific instructions |
| Merge conflict | Two tasks touched the same file. Orchestrator should never assign overlapping `output_files` |
| Credentials not found | `cp ~/.config/manicode/credentials.json ~/.config/manicode-w1/.config/manicode/` |

---

## 📄 License

MIT — do whatever you want, no warranty.

---

Made with ❤️ — PRs welcome!
