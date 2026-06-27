# Decisions

| Date | Owner | Decision | Reason | Status |
| --- | --- | --- | --- | --- |
| 2026-06-27 | Human / Owner | This repository is Markdown-only coordination for the TTS training project. | The user wants Codex, Claude Code, and Trae to collaborate through Git without uploading real project code or assets. | Accepted |
| 2026-06-27 | Codex | Real execution should be referenced by summary, safe path alias, command, and result only. | This keeps the collaboration repo lightweight and avoids leaking code, datasets, checkpoints, or logs. | Accepted |
| 2026-06-27 | Human / Owner | Claude Code owns cloud API implementation; Codex owns code review. | Claude Code is already on the cloud/server-side training project; Codex is coordinating and reviewing through this repository. | Accepted |
| 2026-06-27 | Human / Owner | v1 endpoint uses round-53 weight with `scale=1.5` and `seed=9999`. | These are the known desired model and inference parameters for the first exposed service. | Accepted |

