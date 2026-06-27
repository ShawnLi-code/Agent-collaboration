# Plan

## Current Accepted Plan

1. Claude Code owns the cloud TTS API implementation in the real cloud-server TTS project.
2. Codex owns local pressure testing against the exposed cloud endpoint and saves raw result files locally only.
3. Trae owns integrating the exposed cloud TTS endpoint into the local voice-companion chat web app.
4. This Git repository stores coordination Markdown only. It must not store real code, weights, datasets, generated audio, large logs, or raw pressure-test artifacts.
5. Final status and cross-agent handoff notes are recorded in this task package.

## Claude Code Assignment

Claude Code owns the cloud endpoint.

Known endpoint from Claude Code:

```text
Base URL: https://u539523-9a8d-5d91dc27.westx.seetacloud.com:8443
Health:   GET  /health
TTS:      POST /synthesize
Docs:     GET  /docs
```

Known model settings:

- Weight: round 53.
- Model preset reported by health check: `epoch53_scale1.5_seed9999`.
- Default inference parameters: `scale=1.5`, `seed=9999`.
- Successful synthesis response: `audio/wav`.

Claude Code should continue to own server-side fixes if pressure tests expose proxy, concurrency, timeout, cleanup, or stability problems.

## Codex Assignment

Codex owns local pressure testing.

Required behavior:

- Call the cloud endpoint from the local machine.
- Save raw test artifacts locally outside this Git repository.
- Do not commit generated WAV files, CSVs, JSON summaries, or raw logs.
- Record only short coordination summaries in Git if needed.

Local result location used by Codex:

```text
E:\Shawn_code\Agent-collaboration-results\tts-concurrency-test\
```

Required local artifacts:

- `pressure_report.md`
- `pressure_results.csv`
- `pressure_summary.json`
- `audio/*.wav`

## Trae Assignment

Trae owns client integration into the local voice-companion chat web app.

Trae should:

- Read this task package before editing its local web app.
- Add the cloud TTS endpoint as the app's TTS provider.
- Send chat reply text to `POST /synthesize`.
- Play the returned `audio/wav` in the browser.
- Add loading, timeout, retry-once, and error UI for TTS generation.
- Avoid concurrent duplicate TTS calls for the same message.
- Keep the endpoint configurable through environment/config rather than hardcoding it deeply in UI components.
- Do not upload the local web app code into this collaboration repository unless the human owner explicitly asks.

Suggested request:

```http
POST https://u539523-9a8d-5d91dc27.westx.seetacloud.com:8443/synthesize
Content-Type: application/json

{"text":"要合成的文本"}
```

Expected successful response:

```text
Content-Type: audio/wav
Body: WAV binary
```

## Current Codex Pressure-Test Finding

Codex confirmed:

- `/health` is reachable from local machine.
- `/health` reports `epoch53_scale1.5_seed9999`.
- Single synthesis request succeeds and returns WAV.
- Light concurrency shows instability: some `IncompleteRead` failures and one nginx `502 Bad Gateway`.

Recommendation for Trae:

- Integrate as a single-user / low-frequency TTS provider first.
- Add visible error handling and retry-once behavior.
- Do not assume the endpoint is stable for overlapping multi-message playback yet.

## Verification

- Claude Code: server endpoint remains reachable.
- Codex: local pressure-test files exist outside Git.
- Trae: local web app can request TTS and play returned WAV.
- Git status remains free of raw audio, logs, pressure-test CSV/JSON, model files, or app source code unless explicitly requested.

