# AgentLoop

Menjalankan **beberapa sesi Freebuff/Codebuff sekaligus** pada project yang sama:
satu orchestrator yang memecah pekerjaan, beberapa worker yang mengerjakan tugas
secara paralel, tanpa saling takeover.

## Masalah

Freebuff hanya mengizinkan satu sesi dalam satu waktu. Membuka terminal kedua
memicu *takeover* — sesi lama diambil alih, apa pun folder kerjanya.

Penyebabnya satu file global:

```
~/.config/manicode/freebuff-instance-owner.json
```

File itu menyimpan PID sesi yang sedang aktif. Saat start, Freebuff membacanya dan
menganggap sesi masih hidup, sehingga sesi baru mengambil alih alih-alih berjalan
berdampingan.

## Solusi

Dua mekanisme yang dipakai bersamaan:

**1. HOME override.** Tiap worker dijalankan dengan `HOME` (dan `USERPROFILE` di
Windows, karena `os.homedir()` di Node.js membacanya) yang berbeda. Hasilnya tiap
worker punya `instance-owner.json` sendiri:

```
~/.config/manicode/                  → orchestrator   (PID: 1234)
~/.config/manicode-w1/.config/manicode/  → worker 1   (PID: 5678)
~/.config/manicode-w2/.config/manicode/  → worker 2   (PID: 9012)
```

**2. Git worktree.** Tiap worker mendapat working directory sendiri. Worker
commit ke branch `worker-N`, orchestrator yang melakukan merge ke `main`.

## Alur kerja

```
Orchestrator → queue/task-001.json  (status: pending)
        │
        ├── Worker 1: rename queue/ → in-progress/ → eksekusi → results/
        └── Worker 2: rename queue/ → in-progress/ → eksekusi → results/
        │
Orchestrator → baca results/ → merge worker-1, worker-2 → lanjut task berikutnya
```

**Pengambilan task bersifat atomic.** Worker tidak membaca daftar lalu memilih —
worker langsung me-*rename* file dari `queue/` ke `in-progress/`. Kalau dua worker
menyasar file yang sama, hanya satu rename yang berhasil (dijamin filesystem), dan
yang kalah mengambil task lain. Tidak ada dua worker yang mengerjakan task sama.

## Struktur

```
queue/                 task menunggu (status: pending)
in-progress/           task yang sedang dikerjakan worker
results/               hasil dari worker
orchestrator-prompt.md prompt untuk sesi orchestrator
worker-prompt.md       prompt untuk sesi worker
task-template.json     skema task
result-template.json   skema hasil
setup.sh / .bat        siapkan HOME terpisah + worktree + salin credentials
run-all.sh / .bat      buka 3 sesi sekaligus (orchestrator + 2 worker)
start-*.sh / .bat      buka satu sesi tertentu saja
test-takeover.sh / .bat  verifikasi bahwa takeover memang tidak terjadi
cleanup.sh / .bat       hapus worktree dan config sementara
DEMO.md                panduan visual langkah demi langkah
```

## Menjalankan

```bash
./setup.sh          # sekali saja: siapkan worktree + HOME per worker
./run-all.sh        # Linux/macOS — buka 3 pane tmux
run-all.bat         # Windows — buka 3 jendela CMD
```

Setelah jendela terbuka, prompt di-copy-paste secara manual:

| Sesi | File yang di-paste |
| :--- | :--- |
| Orchestrator | `orchestrator-prompt.md` |
| Worker 1 & 2 | `worker-prompt.md` |

Worker langsung memindai `queue/` dan mulai mengeksekusi task yang tersedia.

Untuk membuka sesi satu per satu:

```bash
./start-orchestrator.sh
./start-worker1.sh
./start-worker2.sh
```

## Verifikasi

```bash
./test-takeover.sh     # atau test-takeover.bat di Windows
```

Skrip ini memastikan sesi kedua benar-benar berjalan berdampingan, bukan mengambil
alih sesi pertama.

## Membersihkan

```bash
./cleanup.sh           # hapus worktree dan folder config worker
```

## Kebutuhan

- Git (untuk worktree dan merge)
- tmux di Linux/macOS; CMD atau PowerShell di Windows
- Freebuff atau Codebuff CLI yang sudah terpasang dan login

## Catatan

- Judul README ini dulu `freebuffdual` sementara nama repository-nya `agentloop`.
  Dokumentasi internal (`DEMO.md`) memakai nama **AgentLoop**.
- Prompt orchestrator dan worker sengaja tidak dijalankan otomatis: keduanya harus
  ditempel manual ke sesi masing-masing.

## Lisensi

Lihat [LICENSE](LICENSE).
