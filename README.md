<div align="center">

# 🔁 AgentLoop

**Break Freebuff's single-session limit.** Run multiple Freebuff/Codebuff sessions in parallel on the same project — with atomic task delegation, Git worktrees, and zero takeover.

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Platform: Windows | Linux | macOS](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-blue)
![Agents: Freebuff | Claude | Cursor | Aider](https://img.shields.io/badge/Agents-Freebuff%20%7C%20Claude%20%7C%20Cursor%20%7C%20Aider-orange)
![Setup: 30s](https://img.shields.io/badge/Setup-30%20seconds-green)

---

**[Quick Start](#quick-start)** •
**[How It Works](#how-it-works)** •
**[Other Agents](#use-with-other-ai-agents)** •
**[Demo](#visual-demo)** •
**[Troubleshooting](#troubleshooting)**

</div>

---

## 🤔 Why?

Freebuff (and Codebuff free tier) limits you to **1 active session**. Open a second terminal anywhere on your system → it **takes over** the existing session. Want two workers coding different parts of your app simultaneously? Impossible.

**Root cause:** `~/.config/manicode/freebuff-instance-owner.json` stores a single global PID. Any new `freebuff` process sees it alive and takes over — regardless of directory.

**This tool fixes that.**

---

## 📦 Quick Start

### 1. Copy files to your project

```bash
# One-liner: copy everything you need
cp -r queue/ results/ in-progress/ YOUR_PROJECT/
cp *.json *.md *.sh *.bat YOUR_PROJECT/
cp .gitignore .gitattributes YOUR_PROJECT/
# ⚠️  If YOUR_PROJECT already has README.md/.sh/.bat, add -n to skip: cp -n ...
```

<details>
<summary>Or download & extract (click to expand)</summary>

```bash
# Clone to a temp location, then copy to your project
git clone https://github.com/YOUR_USER/agentloop /tmp/fl
cp -r /tmp/fl/{queue,results,in-progress,*.json,*.md,*.sh,*.bat,.gitignore,.gitattributes} YOUR_PROJECT/
rm -rf /tmp/fl
```
</details>

### 2. Setup (once, ~10 seconds)

```bash
chmod +x *.sh     # IMPORTANT: make scripts executable after download
cd YOUR_PROJECT/
./setup.sh          # Linux / macOS / Git Bash
# OR
setup.bat           # Windows CMD (double-click!)
```

Setup automatically: initializes git → creates 2 worktrees → config directories → copies credentials.

### 3. Launch — pick one:

| Method | Command | Best for |
|--------|---------|----------|
| **One-click** ⚡ | `./run-all.sh` or `run-all.bat` | Quick daily use |
| **Manual** | `./start-orchestrator.sh/.bat` + workers | Debugging / custom |

> 💡 **`run-all.bat`** double-click = 3 CMD windows auto-launched with correct configs!
> **`run-all.sh`** = tmux 3-pane layout (split-screen).

### 4. Workflow

```
You: "Build a fullstack todo app"
  ↓
Orchestrator: writes queue/task-001.json, task-002.json, task-003.json
  ↓
Worker 1: grabs task-001 (atomic), builds Express backend, commits ✓
Worker 2: grabs task-002 (parallel!), builds React frontend, commits ✓
  ↓
Orchestrator: reads results, merges worktrees, writes task-003
  ↓
Worker 1: grabs task-003, builds API client, commits ✓
  ↓
Orchestrator: merges everything → 🎉 DONE!
```

### 5. Cleanup

```bash
./cleanup.sh        # Removes worktrees, branches, config dirs
```

---

## 🧠 How It Works

### Architecture

```
                        BIG TASK
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
     ┌─ Orchestrator ────┐    ┌─ Worker 1 ──────┐   HOME: normal
     │ Plan & decompose  │    │ Atomic grab task │   HOME: manicode-w1
     │ Write queue/*.json│    │ Execute & commit │   HOME: manicode-w2
     │ Merge results     │    └────────┬─────────┘
     └────────┬──────────┘    ┌─ Worker 2 ──────┐
              │               │ Atomic grab task │
              │               │ Execute & commit │
              │               └────────┬─────────┘
              │                        │
              └────────────┬───────────┘
                           ▼
                    queue/ → results/
                           │
                           ▼
                    Git merge → LOOP 🔁
```

### The HOME Override Trick

```
~/.config/manicode/freebuff-instance-owner.json   ← Orchestrator (PID 1234)
~/.config/manicode-w1/.config/manicode/...        ← Worker 1   (PID 5678)
~/.config/manicode-w2/.config/manicode/...        ← Worker 2   (PID 9012)
                    3 independent ≈ 3 sessions ✅
```

Freebuff checks `$HOME/.config/manicode/` for the session lock. By giving each worker a different `$HOME`, each gets its own lock. On Windows, `USERPROFILE` is also overridden (Node.js reads it for `os.homedir()`).

### Atomic Task Claiming

Two workers scanning `queue/` simultaneously? No collision:

1. Worker finds `queue/task-001.json` (status: pending)
2. **Renames** it to `in-progress/task-001.json` — OS-level atomic
3. If rename fails → another worker claimed it → try next task
4. Only after successful rename → reads file → executes

---

## 📝 Task & Result Format

<details open>
<summary><code>queue/task-001.json</code></summary>

```json
{
  "id": "task-001",
  "prompt": "Create src/auth.ts with login, register, logout. TypeScript strict. Export class. Use bcrypt.",
  "output_files": ["src/auth.ts"],
  "context_files": ["src/models/User.ts"],
  "depends_on": [],
  "status": "pending"
}
```
> 🔑 **`prompt` must be hyper-detailed.** Workers never ask questions — they execute as-is.
</details>

<details>
<summary><code>results/result-001.json</code></summary>

```json
{
  "task_id": "task-001",
  "worker": "worker-1",
  "status": "completed",
  "summary": "Created AuthService with 3 methods + bcrypt",
  "files_created": ["src/auth.ts"],
  "errors": [],
  "completed_at": "2026-06-27T12:05:00Z"
}
```
</details>

---

## 🎯 Use With Other AI Agents

This is **agent-agnostic**. The queue is just JSON files — any agent that reads/writes files can participate.

| Agent | Orchestrator | Worker | Needs HOME override? |
|-------|-------------|--------|---------------------|
| **Freebuff / Codebuff** | `freebuff` + `orchestrator-prompt.md` | `HOME=... freebuff` + `worker-prompt.md` | ✅ Yes |
| **Claude Code** | `claude` + `orchestrator-prompt.md` | `claude` + `worker-prompt.md` | ❌ No |
| **Cursor / Windsurf** | Chat → paste orchestrator prompt | Chat → paste worker prompt | ❌ No |
| **Aider** | `aider` + prompt | `aider` + prompt | ❌ No |
| **GitHub Copilot** | Chat → paste prompt | Chat → paste prompt | ❌ No |
| **Any CLI agent** | Feed prompt via stdin | Feed prompt via stdin | Depends |

> 💡 **For non-Freebuff agents**, skip the HOME override entirely. Just `cd project-w1 && your-agent`.

---

## 📈 Scaling

Need 3+ workers? The pattern scales infinitely:

```bash
# Add worker N
git worktree add -b worker-N ../project-wN main
mkdir -p ~/.config/manicode-wN/.config/manicode
cp ~/.config/manicode/credentials.json ~/.config/manicode-wN/.config/manicode/
cd ../project-wN && HOME=~/.config/manicode-wN freebuff
```

Copy `start-worker1.sh` → `start-workerN.sh`, update the paths. Orchestrator merge: `git merge worker-N`.

---

## 🎬 Visual Demo

See **[DEMO.md](DEMO.md)** for a full step-by-step visual walkthrough with ASCII art showing exactly what you'll see at each step.

---

## 🔧 Requirements

| Tool | Install |
|------|---------|
| Freebuff / Codebuff | `npm install -g freebuff` |
| Git | [git-scm.com](https://git-scm.com) |
| Bash (Linux/Mac) or Git Bash (Windows) | Included with Git for Windows |
| tmux (optional, for `run-all.sh`) | `sudo apt install tmux` |

---

## 📁 Project Structure

```
your-project/
├── queue/                     ← Pending tasks
├── in-progress/               ← Tasks being executed
├── results/                   ← Completed task outputs
├── README.md                  ← This file
├── DEMO.md                    ← Visual walkthrough
├── CONTEXT.md                 ← System internals (for AI agents)
├── orchestrator-prompt.md     ← Copy-paste: orchestrator role
├── worker-prompt.md           ← Copy-paste: worker role
├── task-template.json         ← Task JSON template
├── result-template.json       ← Result JSON template
├── setup.sh / .bat            ← One-time setup
├── cleanup.sh / .bat          ← Tear down everything
├── run-all.sh / .bat          ← ⚡ One-click launch all 3
├── start-*.sh / .bat          ← Individual launchers
├── test-takeover.sh / .bat    ← Verify bypass works
├── .gitignore / .gitattributes
└── LICENSE                    ← MIT
```

---

## ❓ Troubleshooting

| Symptom | Fix |
|---------|-----|
| **"Takeover" still appears** | Ensure `HOME=...` (Linux) or `USERPROFILE=...` (Windows) is set before `freebuff` |
| **Worker can't find tasks** | `queue/` must have `.json` files with `"status": "pending"` |
| **Worker keeps asking questions** | Task prompt too vague — add specific file paths, libraries, constraints |
| **Git merge conflict** | Orchestrator assigned overlapping `output_files` → never let 2 tasks touch the same file |
| **Credentials missing** | `cp ~/.config/manicode/credentials.json ~/.config/manicode-w1/.config/manicode/` |
| **`freebuff` not in PATH** | Reinstall: `npm install -g freebuff` |

---

## 🤝 Contributing

Found a bug? Want to add support for another AI agent? PRs welcome!

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/amazing`)
3. Commit your changes
4. Push to your fork
5. Open a Pull Request

See [CONTEXT.md](CONTEXT.md) for technical internals.

---

## 📄 License

MIT — see [LICENSE](LICENSE).

---

<div align="center">

**Made for the AI coding community.**  
If this saved you time, ⭐ the repo!

</div>
