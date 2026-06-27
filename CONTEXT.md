# 🔁 Freebuff Looping System

Sistem buat nge-loop / self-delegate task di Freebuff (Codebuff free tier) pake Git Worktrees + HOME override.

## Masalah
- Freebuff cuma bisa **1 sesi** dalam satu waktu
- Buka terminal kedua → **"takeover"** (ngambil alih sesi existing)
- Penyebab: `~/.config/manicode/freebuff-instance-owner.json` itu **GLOBAL** — simpen PID sesi aktif. Freebuff cek file ini saat start, kalau PID masih idup → takeover, **gak peduli folder mana**.

## Solusi: Git Worktrees + HOME Override

1. **Git Worktrees** — biar worker punya working directory sendiri buat commit & merge
2. **HOME override** — biar tiap worker punya `instance-owner.json` SENDIRI → gak detect sesi lain → gak takeover!

## Struktur Folder

```
dan lain lain/
├── freebuffdual/           ← ORCHESTRATOR (terminal 1)
│   ├── queue/              ← Task queue (pending jobs)
│   ├── in-progress/        ← Tasks yang lagi dikerjain
│   ├── results/            ← Hasil dari worker
│   ├── task-template.json
│   ├── result-template.json
│   ├── orchestrator-prompt.md
│   ├── worker-prompt.md
│   ├── .env.worker1        ← Config HOME alternatif worker 1
│   ├── .env.worker2        ← Config HOME alternatif worker 1
│   └── CONTEXT.md          ← File ini
│
├── freebuffdual-w1/        ← WORKER 1 (terminal 2, HOME override)
└── freebuffdual-w2/        ← WORKER 2 (terminal 3, HOME override)
```

## Cara Setup (sekali aja)

```bash
# 1. Masuk ke project
cd "C:/Users/KandarLubis/Desktop/Project/dan lain lain/freebuffdual"

# 2. Bikin worktrees
git worktree add -b worker-1 ../freebuffdual-w1 main
git worktree add -b worker-2 ../freebuffdual-w2 main

# 3. Bikin config directory buat masing-masing worker
mkdir -p "$HOME/.config/manicode-w1"
mkdir -p "$HOME/.config/manicode-w2"

# 4. Copy credentials ke config worker (PAKE AKUN SAMA — gapapa!)
cp "$HOME/.config/manicode/credentials.json" "$HOME/.config/manicode-w1/"
cp "$HOME/.config/manicode/credentials.json" "$HOME/.config/manicode-w2/"
# Atau kalau mau beda akun, taruh credentials akun lain di folder worker
```

## Cara Pakai (setiap kali)

### ⚡ PERBEDAAN KRITIKAL: HOME override!
**Worker harus start dengan HOME override**, bukan langsung `freebuff` doang.

### Step 1 — Orchestrator Planning
Di **Terminal 1** (folder `freebuffdual/`, HOME normal):
```bash
cd "C:/Users/KandarLubis/Desktop/Project/dan lain lain/freebuffdual"
freebuff
```
Copy-paste isi `orchestrator-prompt.md`.

### Step 2 — Worker 1 Execution
Di **Terminal 2** (folder `freebuffdual-w1/`, HOME override):
```bash
cd "C:/Users/KandarLubis/Desktop/Project/dan lain lain/freebuffdual-w1"
HOME="$HOME/.config/manicode-w1" freebuff
```
Copy-paste isi `worker-prompt.md`.

### Step 3 — Worker 2 Execution  
Di **Terminal 3** (folder `freebuffdual-w2/`, HOME override):
```bash
cd "C:/Users/KandarLubis/Desktop/Project/dan lain lain/freebuffdual-w2"
HOME="$HOME/.config/manicode-w2" freebuff
```
Copy-paste isi `worker-prompt.md`.

### Step 4 — Merge & Review
Balik ke **Terminal 1** (orchestrator):
```bash
git merge worker-1
git merge worker-2
```

## Flow Looping

```
User kasih task besar
        │
        ▼
┌─ Orchestrator ──────────────┐    HOME: normal
│ Pecah task → tulis queue/   │
└─────────────────────────────┘
        │
        ├──────────────────────┐
        ▼                      ▼
┌─ Worker 1 ───┐     ┌─ Worker 2 ───┐   HOME: manicode-w1
│ Ambil task-1 │     │ Ambil task-2 │   HOME: manicode-w2
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

## Kenapa HOME Override Bypass Takeover?

```
Normal:                         Dengan HOME override:
┌─────────────────────┐         ┌─────────────────────┐
│ ~/.config/manicode/ │         │ ~/.config/manicode/ │
│ instance-owner.json │         │ instance-owner.json │  ← Orchestrator
│ pid: 1234           │         │ pid: 1234           │
└─────────────────────┘         └─────────────────────┘
        ▲                       ┌───────────────────────┐
        │  cek PID              │ ~/.config/manicode-w1 │
┌───────┴──────────┐            │ instance-owner.json   │  ← Worker 1
│ freebuff (lagi)  │            │ pid: 5678             │
│ → PID 1234 idup! │            └───────────────────────┘
│ → TAKEOVER! ❌   │            ┌───────────────────────┐
└──────────────────┘            │ ~/.config/manicode-w2 │
                                │ instance-owner.json   │  ← Worker 2
                                │ pid: 9012             │
                                └───────────────────────┘
                                3 instance-owner = 3 sesi paralel ✅
```

## Catatan

- **Akun**: Bisa akun SAMA atau BEDA — gak ngaruh. Yang penting HOME berbeda.
- **Credentials**: Worker butuh credentials di folder config masing-masing. Copy dari config utama atau pake akun beda.
- **Commit**: Worker commit ke branch worktree-nya sendiri. Orchestrator merge.
- **1 worker = 1 task per sesi**. Jangan kerjain lebih.
- Kalau ada dependency, orchestrator yang atur urutannya.
