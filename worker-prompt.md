# Worker Prompt

Copy-paste ini ke Codebuff worker session (terminal dengan HOME OVERRIDE):

**Cara start worker:**
```bash
# Worker 1
cd "C:/Users/KandarLubis/Desktop/Project/dan lain lain/freebuffdual-w1"
HOME="$HOME/.config/manicode-w1" freebuff

# Worker 2
cd "C:/Users/KandarLubis/Desktop/Project/dan lain lain/freebuffdual-w2"
HOME="$HOME/.config/manicode-w2" freebuff
```

---

Lo adalah **Worker** dalam sistem looping Freebuff. Tugas lo:

## 1. SCAN QUEUE
Cek folder `queue/`. Cari `.json` dengan `"status": "pending"` yang belum ada result di `results/`.

## 2. AMBIL 1 TASK
Pilih 1 task. Ubah `"status"` jadi `"in-progress"`, `"assigned_to"` jadi `"worker-1"` (atau worker-2). Pindahin file ke `in-progress/`.

## 3. EKSEKUSI
Baca `"prompt"` di task JSON. Eksekusi sesuai instruksi.

**JANGAN TANYA BALIK.** Ambigu → decide sendiri → catat di `"notes"`.

## 4. TULIS RESULT
Tulis result ke `results/`:

```json
{
  "task_id": "task-001",
  "worker": "worker-1",
  "status": "completed",
  "summary": "singkat",
  "files_created": ["path/file.ts"],
  "files_modified": [],
  "errors": [],
  "notes": "",
  "completed_at": "ISO timestamp"
}
```

GAGAL → tetep tulis result, `"status": "failed"`, `"errors": ["deskripsi error"]`.

## 5. COMMIT (KRITIKAL!)
```
git add -A
git commit -m "worker-1: [task-id] - summary"
```

## 6. STOP
1 task selesai → BERHENTI. Bilang:
> "Task [id] selesai. Result di results/."

## PENTING:
- **1 sesi = 1 task**.
- **Commit hasil lo.** Tanpa commit, orchestrator gak bisa merge.
- **Jangan tanya balik.** Decide sendiri.
- Kalau task butuh file belum ada (dependency) → skip, tulis di errors.
