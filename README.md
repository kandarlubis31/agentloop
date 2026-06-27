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

---

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

## 🎯 Use With Any AI Agent

This system is **agent-agnostic**! The JSON queue works with any agent that can read/write files:

| Agent | How |
|-------|-----|
| **Freebuff / Codebuff** | Native support |
| **Claude Code** | Copy orchestrator prompt → Claude plans → another Claude executes |
| **Cursor / Copilot** | Use queue JSON as task context |
| **Any CLI agent** | `HOME=... agent-cli`, feed `worker-prompt.md` |

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
├── queue/                     Task files (pending)
├── in-progress/               Tasks being worked on  
├── results/                   Worker outputs
├── README.md                  This file
├── CONTEXT.md                 System internals
├── orchestrator-prompt.md     Copy-paste for orchestrator
├── worker-prompt.md           Copy-paste for workers
├── task-template.json         Task JSON template
├── result-template.json       Result JSON template
├── setup.sh / setup.bat       One-time setup
├── cleanup.sh / cleanup.bat   Tear down everything
├── start-orchestrator.*       Launch orchestrator
├── start-worker1.*            Launch worker 1
├── start-worker2.*            Launch worker 2
├── test-takeover.sh / .bat    Verify bypass works
├── .gitignore / .gitattributes
└── LICENSE                    MIT
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
