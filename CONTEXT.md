# 🔁 Freebuff Looping System

Sistem buat nge-loop / self-delegate task di Freebuff (Codebuff free tier) pake Git Worktrees.

## Masalah
- Freebuff cuma bisa **1 sesi per folder path**
- Buka terminal kedua di folder yang sama → **"takeover"** (ngambil alih sesi existing)
- Gak bisa split kerjaan paralel

## Solusi: Git Worktrees
Bikin "clone" project di folder berbeda pake `git worktree`. Codebuff ngeliat path berbeda → session terpisah → gak takeover.

## Struktur Folder

```
dan lain lain/
├── freebuffdual/           ← ORCHESTRATOR (terminal 1)
│   ├── queue/              ← Task queue (pending jobs)
│   ├── in-progress/        ← Tasks yang lagi dikerjain
│   ├── results/            ← Hasil dari worker
│   ├── task-template.json  ← Template buat task baru
│   ├── result-template.json← Template buat result
│   ├── orchestrator-prompt.md ← Prompt orchestrator
│   ├── worker-prompt.md    ← Prompt worker
│   └── CONTEXT.md          ← File ini
│
├── freebuffdual-w1/        ← WORKER 1 (terminal 2)
│   └── (git worktree dari freebuffdual)
│
└── freebuffdual-w2/        ← WORKER 2 (terminal 3)
    └── (git worktree dari freebuffdual)
```

## Cara Setup (sekali aja)

```bash
# 1. Masuk ke project
cd "C:/Users/KandarLubis/Desktop/Project/dan lain lain/freebuffdual"

# 2. Bikin worktrees
git worktree add ../freebuffdual-w1 main
git worktree add ../freebuffdual-w2 main
```

## Cara Pakai (setiap kali)

### Step 1 — Orchestrator Planning
Di **Terminal 1** (folder `freebuffdual/`):
```bash
freebuff
```
Copy-paste isi `orchestrator-prompt.md`. Kasih task besar ke orchestrator.

### Step 2 — Worker Execution
Di **Terminal 2** (folder `freebuffdual-w1/`):
```bash
cd ../freebuffdual-w1
freebuff
```
Copy-paste isi `worker-prompt.md`. Worker bakal scan `queue/` dan eksekusi 1 task.

Di **Terminal 3** (folder `freebuffdual-w2/`):
```bash
cd ../freebuffdual-w2
freebuff
```
Copy-paste isi `worker-prompt.md`. Worker bakal ambil task lain.

### Step 3 — Merge & Review
Balik ke **Terminal 1** (orchestrator), kasih tau:
> "Cek results/ dan merge hasil worker"

Atau manual:
```bash
git merge freebuffdual-w1/main
git merge freebuffdual-w2/main
```

## Flow Looping

```
User kasih task besar
        │
        ▼
┌─ Orchestrator ──────────────┐
│ Pecah task → tulis queue/   │
└─────────────────────────────┘
        │
        ├──────────────────────┐
        ▼                      ▼
┌─ Worker 1 ───┐     ┌─ Worker 2 ───┐
│ Ambil task-1 │     │ Ambil task-2 │
│ Eksekusi     │     │ Eksekusi     │
│ Tulis result │     │ Tulis result │
│ Commit       │     │ Commit       │
└──────────────┘     └──────────────┘
        │                      │
        └──────────────────────┘
                   │
                   ▼
        ┌─ Orchestrator ──────┐
        │ Baca results/       │
        │ Merge               │
        │ Kalau ada task lagi │
        │ → tulis queue/ (LOOP)
        └─────────────────────┘
                   │
                   ▼
             Selesai 🎉
```

## Catatan

- Worker **commit** hasil ke branch worktree masing-masing
- Orchestrator **merge** branch worktree ke main
- Kalau ada dependency antar task, orchestrator yang atur (task B ditulis setelah task A selesai)
- Worker gak boleh tanya balik — decide sendiri, catat di notes
- 1 worker cuma kerjain 1 task per sesi
