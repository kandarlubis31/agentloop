# 🎬 Freebuff Looping — Visual Demo

Panduan visual step-by-step. Liat apa yang terjadi di tiap langkah.

---

## ⚡ One-Click: `./run-all.sh` atau `run-all.bat`

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│   Double-click:  run-all.bat     (Windows)          │
│   Terminal:      ./run-all.sh    (Linux/Mac/tmux)   │
│                                                     │
│   ▼ 3 terminal langsung kebuka otomatis! ▼          │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 🖥️ Yang Lo Liat (Windows — 3 CMD windows)

```
┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│  ORCHESTRATOR    │ │  WORKER 1        │ │  WORKER 2        │
│  Config: normal  │ │  Config: manicode-w1│  Config: manicode-w2│
│                  │ │                  │ │                  │
│ COPY-PASTE       │ │ COPY-PASTE       │ │ COPY-PASTE       │
│ orchestrator-    │ │ worker-prompt.md │ │ worker-prompt.md │
│ prompt.md        │ │                  │ │                  │
│                  │ │ Auto-scan queue/ │ │ Auto-scan queue/ │
│ LALU kasih       │ │ & eksekusi task! │ │ & eksekusi task! │
│ task besar!      │ │                  │ │                  │
└──────────────────┘ └──────────────────┘ └──────────────────┘
```

---

## 🖥️ Yang Lo Liat (Linux/Mac — tmux 3-pane)

```
┌────────────────────────┬────────────────────────┐
│  ORCHESTRATOR          │  WORKER 1              │
│  cd ~/project          │  cd ~/project-w1       │
│  Config: normal        │  Config: manicode-w1   │
│                        │                        │
│  > freebuff            │  > freebuff            │
│  (session baru)        │  (session baru)        │
│                        │                        │
│  "Gua mau bikin..."    │  "Lo worker. Scan..."  │
├────────────────────────┼────────────────────────┤
│  INSTRUCTIONS          │  WORKER 2              │
│                        │  cd ~/project-w2       │
│  Ctrl+B + Arrow keys   │  Config: manicode-w2   │
│  buat pindah pane      │                        │
│                        │  > freebuff            │
│                        │  (session baru)        │
│                        │                        │
│                        │  "Lo worker. Scan..."  │
└────────────────────────┴────────────────────────┘
```

---

## 📋 Step-by-Step Workflow

### STEP 1: Setup (sekali aja, 10 detik)

```bash
./setup.sh
```

```
┌─────────────────────────────────────────┐
│  Freebuff Looping - SETUP               │
│=========================================│
│ Project: my-project                     │
│                                         │
│ [1/5] Git repo exists — skipping.       │
│ [2/5] Git commit exists — skipping.     │
│ [3/5] Creating worktrees...             │
│   - Creating worker-1 worktree... ✓     │
│   - Creating worker-2 worktree... ✓     │
│ [4/5] Setting up worker config dirs...  │
│   - Credentials copied to worker configs│
│ [5/5] Setup complete!                   │
│                                         │
│  SETUP SELESAI! Cara mulai:             │
│  Orchestrator:  start-orchestrator.bat  │
│  Worker 1:      start-worker1.bat       │
│  Worker 2:      start-worker2.bat       │
│  OR:            run-all.bat (1-click!)  │
└─────────────────────────────────────────┘
```

### STEP 2: Orchestrator — Planning

Buka terminal orchestrator, copy-paste `orchestrator-prompt.md`, lalu:

```
User: "Bikin fullstack todo app: React frontend + Express backend + SQLite"

Orchestrator:
  → Baca project structure
  → Pecah jadi 3 sub-tasks independen:
     task-001: Bikin Express server + SQLite schema
     task-002: Bikin React App + components
     task-003: Bikin API client + integration
  → Tulis queue/task-001.json, task-002.json, task-003.json

Orchestrator: "Tasks udah di queue/. 
               Buka Worker & copy-paste worker-prompt.md"
```

```
queue/
├── task-001.json  → "Bikin Express server..."
├── task-002.json  → "Bikin React App..."
└── task-003.json  → "Bikin API client..."
```

### STEP 3: Worker 1 — Execution

Buka terminal worker 1, copy-paste `worker-prompt.md`:

```
Worker 1:
  → Scan queue/...
  → Found: task-001.json (status: pending)
  → RENAME queue/task-001.json → in-progress/task-001.json
     (ATOMIC — kalau worker 2 juga mau ambil, salah satu gagal)
  → Baca prompt: "Bikin Express server dengan..."
  → Execute: bikin src/server.ts, src/db.ts, package.json
  → Tulis results/result-001.json
  → git commit -m "worker-1: task-001 - Express server"
  → STOP. "Task task-001 selesai."
```

### STEP 4: Worker 2 — Execution (PARALEL!)

Di saat yang sama, worker 2:

```
Worker 2:
  → Scan queue/...
  → Found: task-002.json (status: pending)
  → RENAME queue/task-002.json → in-progress/task-002.json ✓
  → Baca prompt: "Bikin React App dengan..."
  → Execute: bikin src/App.tsx, src/components/*.tsx
  → Tulis results/result-002.json
  → git commit -m "worker-2: task-002 - React App"
  → STOP. "Task task-002 selesai."

  (task-001 udah diambil worker 1 → worker 2 gak sentuh)
```

### STEP 5: Orchestrator — Merge & Loop

Balik ke orchestrator:

```
Orchestrator: "Cek results/ dan merge"

  → Baca results/result-001.json ✓ (Express server done)
  → Baca results/result-002.json ✓ (React App done)
  → git merge worker-1 ✓
  → git merge worker-2 ✓
  → Task-003 masih pending...
  → "Worker masih ada task. Lanjut eksekusi task-003?"

  INI LOOPING-NYA! 🔁
  Orchestrator pantau terus, bikin task baru kalau perlu,
  sampai project SELESAI.
```

### STEP 6: Cleanup

```bash
./cleanup.sh
```

```
┌─────────────────────────────────────────┐
│  Freebuff Looping - CLEANUP             │
│=========================================│
│ Remove worktrees, branches, config dirs │
│                                         │
│ Continue? (y/N): y                      │
│                                         │
│ [1/3] Removing worktrees... ✓           │
│ [2/3] Removing branches... ✓            │
│ [3/3] Removing config dirs... ✓         │
│                                         │
│  CLEANUP COMPLETE!                      │
└─────────────────────────────────────────┘
```

---

## 🔥 Yang Bikin Ini Keren

| Feature | Kenapa |
|---------|--------|
| **Atomic task claim** | 2 worker gak bakal ngerjain task sama |
| **HOME override** | Bypass takeover lock totally |
| **Git worktrees** | Isolasi perubahan, merge gampang |
| **Queue JSON** | Agent-agnostic, bisa pake Claude/Cursor/dll |
| **One-click run-all** | 3 terminal kebuka otomatis |
| **Cleanup script** | Rapiin semua dalam 1 command |

---

## 🎯 TL;DR Visual

```
SETUP (1x)         →  ./setup.sh
                        │
ONE-CLICK (tiap kali) →  ./run-all.sh / run-all.bat
                        │
         ┌──────────────┼──────────────┐
         ▼              ▼              ▼
    ORCHESTRATOR   WORKER 1      WORKER 2
    (planning)     (execute)     (execute)
         │              │              │
         └──────────────┴──────────────┘
                        │
                    RESULTS
                        │
         ┌──────────────▼──────────────┐
         │  MERGE → LOOP → SELESAI 🎉  │
         └─────────────────────────────┘
                        │
CLEANUP              ./cleanup.sh
```
