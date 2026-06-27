# 📖 USAGE — Freebuff Looping System

Cara pakai di **project manapun**. Gak perlu clone repo ini — cukup copy file-nya.

---

## 🚀 Setup di Project Baru

### Step 0: Copy system files ke project lo

```bash
# Copy file-file ini ke root project lo:
cp -r queue/ in-progress/ results/           target-project/
cp task-template.json result-template.json    target-project/
cp orchestrator-prompt.md worker-prompt.md    target-project/
cp CONTEXT.md                                 target-project/
cp setup.sh setup.bat                         target-project/
cp start-orchestrator.sh start-worker1.sh start-worker2.sh  target-project/
cp start-orchestrator.bat start-worker1.bat start-worker2.bat  target-project/
```

### Step 1: Jalankan setup

```bash
cd target-project/

# Linux / Mac / Git Bash:
./setup.sh

# Windows CMD / PowerShell:
setup.bat
```

Setup otomatis akan:
1. Init git (kalau belum)
2. Bikin initial commit
3. Bikin 2 git worktrees (`project-w1/`, `project-w2/`)
4. Bikin config directories (`~/.config/manicode-w1`, `~/.config/manicode-w2`)
5. Copy credentials ke config worker

### Step 2: Start sessions

**Terminal 1 — Orchestrator:**
```bash
./start-orchestrator.sh    # Linux/Mac/Bash
# atau double-click: start-orchestrator.bat
```

**Terminal 2 — Worker 1:**
```bash
./start-worker1.sh
# atau double-click: start-worker1.bat
```

**Terminal 3 — Worker 2:**
```bash
./start-worker2.sh
# atau double-click: start-worker2.bat
```

---

## 🎮 Cara Pakai (Workflow Normal)

### 1️⃣ Orchestrator: Planning

Di terminal orchestrator, copy-paste `orchestrator-prompt.md`, lalu kasih task:

> "Bikin fullstack todo app: React frontend + Express backend + SQLite.
> Pecah jadi sub-tasks independen, tulis ke queue/"

Orchestrator bakal bikin file kayak `queue/task-001.json`, `queue/task-002.json`, etc.

### 2️⃣ Worker: Execution

Di terminal worker, copy-paste `worker-prompt.md`. Worker akan:
- Scan `queue/` → ambil 1 task pending
- Eksekusi prompt di dalam task
- Tulis result ke `results/`
- Git commit hasilnya!

> ⚠️ **Worker Cuma kerjain 1 task per sesi.** Kalau masih ada task lain, buka worker baru atau ulangi.

### 3️⃣ Orchestrator: Merge & Loop

Balik ke orchestrator:

> "Cek results/, merge branch worker-1 dan worker-2, kalau masih ada task yang perlu dikerjain, tulis lagi ke queue/"

Ini **looping**-nya! 🔁 Orchestrator terus bikin task baru sampai project selesai.

---

## 📝 Format Task (queue/task-XXX.json)

```json
{
  "id": "task-001",
  "type": "code-generation",
  "assigned_to": null,
  "prompt": "Bikin file src/services/AuthService.ts dengan method: login(email, password), register(data), logout(). Pake TypeScript strict mode. Jangan pake any. Export sebagai class.",
  "context_files": ["src/models/User.ts", "package.json"],
  "output_files": ["src/services/AuthService.ts"],
  "depends_on": [],
  "status": "pending",
  "created_at": "2026-06-27T12:00:00Z"
}
```

**KRITIKAL**: Field `prompt` harus **SANGAT DETAIL**. Worker gak akan tanya balik — dia akan execute apa adanya.

---

## 📊 Format Result (results/result-XXX.json)

```json
{
  "task_id": "task-001",
  "worker": "worker-1",
  "status": "completed",
  "summary": "Created AuthService class with login, register, logout methods",
  "files_created": ["src/services/AuthService.ts"],
  "files_modified": [],
  "errors": [],
  "notes": "Used bcrypt for password hashing",
  "completed_at": "2026-06-27T12:05:00Z"
}
```

---

## 🔄 Manual Commands (kalau gak pake launchers)

```bash
# Orchestrator
cd /path/to/your-project
freebuff

# Worker 1 (HOME override = bypass takeover!)
cd /path/to/your-project-w1
HOME="$HOME/.config/manicode-w1" freebuff

# Worker 2
cd /path/to/your-project-w2
HOME="$HOME/.config/manicode-w2" freebuff

# Merge hasil worker
git merge worker-1
git merge worker-2
```

---

## 🧹 Cleanup

```bash
# Hapus worktrees setelah project selesai
git worktree remove ../your-project-w1
git worktree remove ../your-project-w2

# Hapus config worker (optional)
rm -rf ~/.config/manicode-w1
rm -rf ~/.config/manicode-w2
```

---

## 🌍 Pake di Agent Lain

Sistem ini **gak terikat Freebuff**. Selama agent bisa baca/tulis file, dia bisa pake queue system ini:

```bash
# Claude Code sebagai worker
HOME=/tmp/claude-config claude

# Cursor / Windsurf
# Copy prompt dari worker-prompt.md ke chat

# Aider
HOME=/tmp/aider-config aider
```

Prinsipnya sama: **HOME override bypass session lock**, **queue JSON buat komunikasi antar agent**.

---

## ❓ Troubleshooting

| Masalah | Solusi |
|---------|--------|
| "Takeover" masih muncul | Pastiin pake `HOME=...` sebelum `freebuff` |
| Worker gak nemu task | Cek `queue/` ada file `.json` dengan `"status": "pending"` |
| Worker tanya balik | Task prompt kurang detail — tambahin instruksi spesifik |
| Merge conflict | Manual resolve pake `git mergetool` |
| Credentials gak kebaca | Copy ulang: `cp ~/.config/manicode/credentials.json ~/.config/manicode-w1/` |
