# 🔁 AgentLoop — Internals

Dokumentasi teknis internal sistem. Untuk cara pakai, lihat **README.md**.

## Masalah
- Freebuff cuma bisa **1 sesi** dalam satu waktu
- Buka terminal kedua → **"takeover"** (ngambil alih sesi existing)
- Penyebab: `~/.config/manicode/freebuff-instance-owner.json` itu **GLOBAL** — simpen PID sesi aktif. Freebuff cek file ini saat start, kalau PID masih idup → takeover, **gak peduli folder mana**.

## Solusi: Git Worktrees + HOME Override

1. **Git Worktrees** — biar worker punya working directory sendiri buat commit & merge
2. **HOME override** — biar tiap worker punya `instance-owner.json` SENDIRI di folder config terpisah

## Kenapa HOME Override Bypass Takeover?

```
~/.config/manicode/              → Orchestrator instance-owner (PID: 1234)
~/.config/manicode-w1/           → Worker 1 instance-owner (PID: 5678)
     └── .config/manicode/             (freebuff baca $HOME/.config/manicode/)
~/.config/manicode-w2/           → Worker 2 instance-owner (PID: 9012)
     └── .config/manicode/

3 instance-owner.json = 3 independent sessions ✅
```

Pada Windows CMD, `USERPROFILE` juga di-override karena Node.js `os.homedir()` membaca `USERPROFILE` (bukan `HOME`).

## Struktur Folder

```
project/
├── queue/              ← Task queue (pending jobs)
├── in-progress/        ← Tasks yang lagi dikerjain
├── results/            ← Hasil dari worker
├── README.md           ← User-facing docs
├── CONTEXT.md          ← File ini (internal)
├── orchestrator-prompt.md
├── worker-prompt.md
├── task-template.json / result-template.json
├── setup.sh / setup.bat
├── cleanup.sh / cleanup.bat
├── start-orchestrator.* / start-worker1.* / start-worker2.*
├── test-takeover.sh / test-takeover.bat
├── .gitignore / .gitattributes
└── LICENSE
```

## Task Flow

```
Orchestrator → write queue/task-XXX.json (status: pending)
     │
     ├── Worker 1: atomic rename queue/ → in-progress/ → execute → results/
     └── Worker 2: atomic rename queue/ → in-progress/ → execute → results/
     │
Orchestrator → read results/ → git merge worker-1, worker-2 → repeat
```

## Atomic Task Claiming
Worker gak baca dulu baru klaim — itu rawan tabrakan. Worker langsung **rename** file dari `queue/` ke `in-progress/`. Kalau 2 worker coba rename file yang sama, cuma 1 yang berhasil (filesystem garansi atomic rename). Yang gagal ambil task lain.

## Catatan Teknis
- Config nested: `$HOME/.config/manicode/` → worker punya `$OVERRIDE_HOME/.config/manicode/`
- Credentials dicopy ke masing-masing config worker lewat setup script
- Worker commit ke branch `worker-N`, orchestrator merge ke `main`
- Test takeover: jalankan `test-takeover.sh` atau `test-takeover.bat`
