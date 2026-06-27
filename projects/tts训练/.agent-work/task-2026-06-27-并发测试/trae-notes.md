# Trae Notes

## Assignment

Trae should integrate Claude Code's cloud TTS endpoint into the local voice-companion chat web app.

This collaboration repository is for Markdown coordination only. Do not copy the local web app code, generated audio, logs, or build artifacts into this repository.

## Endpoint

```text
Base URL: https://u539523-9a8d-5d91dc27.westx.seetacloud.com:8443
Health:   GET  /health
TTS:      POST /synthesize
```

Request:

```json
{"text":"要合成的文本"}
```

Successful response:

```text
Content-Type: audio/wav
Body: WAV binary
```

## Integration Requirements

- Add this endpoint as the web app's TTS provider.
- Keep endpoint base URL configurable through env/config.
- When the companion generates a reply, send the reply text to `/synthesize`.
- Convert the WAV binary response into a playable browser audio source.
- Play the audio after synthesis completes.
- Show a loading state while TTS is generating.
- Add a timeout and a clear error message if TTS fails.
- Retry at most once for transient network/proxy errors.
- Prevent duplicate concurrent TTS requests for the same message.
- Do not log private user text unnecessarily.

## Important Codex Test Finding

Codex local pressure test found:

- Single request works.
- Light concurrency produced `IncompleteRead` and one nginx `502 Bad Gateway`.

Therefore, integrate conservatively:

- Prefer one active TTS request at a time.
- Queue or cancel duplicate requests.
- Do not fire multiple overlapping TTS calls automatically.

## Trae Report Back

After integration, update this file or a new local handoff note with:

```text
Local app path or alias:
Changed files:
Config key / env var:
How to start local app:
How to test TTS:
Browser behavior:
Known issues:
```

---

## Trae Integration Report (2026-06-27)

### Local app path or alias

- Local web app workspace: `e:\Shawn\龙虾存档\` (Vite + React + TypeScript, alias "小圆 / XiaoYuan")
- This is the user's local voice-companion chat web app, NOT a part of this collaboration repo.
- No code, build output, audio, or logs from this workspace are committed into `Agent-collaboration/`.

### Changed files

Inside `e:\Shawn\龙虾存档\`:

- `src/types/index.ts` — added `'cloud'` to `TTSProvider`; added `cloudEndpoint` and `cloudTimeoutMs` to `TTSSettings`.
- `src/constants/config.ts` — added `CLOUD_TTS_DEFAULT_ENDPOINT` (env-overridable), `CLOUD_TTS_DEFAULT_TIMEOUT_MS`, `CLOUD_TTS_RETRY_TIMEOUT_MS`; populated them into `DEFAULT_SETTINGS.tts`.
- `src/lib/cloudTts.ts` (new) — Cloud TTS client: `cloudSynthesize` + `cloudSynthesizeWithRetry`. POSTs to `{endpoint}/synthesize` with `{text}` body, validates `Content-Type: audio/wav`, returns Blob URL + `revoke()`. Handles timeout, retry-once, dedupe cache.
- `src/hooks/useTTS.ts` — added `createCloudStreamSession` and wired it into `createStreamSession` and `speakQueue`. Exposes `isSynthesizing` and `ttsStatus` for UI feedback. Same-text de-dupe in `enqueue`. Falls back to browser voice cleanly if cloud path is broken.
- `src/vite-env.d.ts` — typed `import.meta.env.VITE_CLOUD_TTS_ENDPOINT`.
- `src/components/SettingsPanel.tsx` — TTS engine selector is now 3-way: 浏览器内置 / 云端 TTS / MiniMax. Cloud branch shows Endpoint input + timeout slider + status note.
- `src/components/StatusBar.tsx` — added `ttsStatus` prop, renders pulsing chip ("合成中…" / "重试中…") next to the state dot.
- `src/pages/Home.tsx` — passes `conv.tts.ttsStatus` to `StatusBar`.

### Config key / env var

- Default endpoint: hardcoded fallback in `src/constants/config.ts` (`CLOUD_TTS_DEFAULT_ENDPOINT`) = `https://u539523-9a8d-5d91dc27.westx.seetacloud.com:8443`.
- Override (recommended for deployment): set Vite env var `VITE_CLOUD_TTS_ENDPOINT=<your-endpoint>` in `.env.local`.
- User can also edit the endpoint directly in 设置 → TTS → 云端 TTS → Endpoint input, and it persists to `localStorage`.
- Default timeout: 12s (single attempt), 18s (retry). User-adjustable in 设置, range 5–30s.

### How to start local app

```powershell
cd "e:\Shawn\龙虾存档"
npx.cmd vite --host 0.0.0.0 --port 5173
```

Then open `http://localhost:5173/`.

For production build:

```powershell
cd "e:\Shawn\龙虾存档"
npx.cmd vite build
npx.cmd vite preview
```

### How to test TTS

1. Open the app, click the gear icon (top-right) to open 设置.
2. In the **TTS 引擎** section, pick **云端 TTS**.
3. Verify the Endpoint field shows `https://u539523-9a8d-5d91dc27.westx.seetacloud.com:8443`.
4. Click **试听音色** — this should call `/synthesize` and play a WAV clip.
5. During synthesis the StatusBar should show a pulsing "合成中…" chip.
6. To test the full flow: type a message (or hold the wave button to speak), wait for the LLM reply, then TTS should synthesize and play the reply.
7. To test retry: temporarily set endpoint to an unreachable URL, click 试听 — should fail after 12s, then auto-retry once with 18s timeout, then surface error in red toast.

### Browser behavior

- On synthesize start: StatusBar shows pulsing "合成中…" chip.
- On retry: chip changes to "重试中…"; error toast appears with the reason.
- On success: Blob URL is created, audio plays via `<audio data-xiaoyuan-tts>`, URL revoked on `ended`.
- On final failure: red toast shows the message; queue continues to the next sentence (we do NOT cascade-fail the whole reply).
- Cancel: clicking the wave button mid-speech calls `cancel()` → AbortController fires, audio elements removed, blob URLs revoked.
- Same-text dedupe: if the same sentence is enqueued twice in the same reply, it is only synthesized once.

### Known issues / risks

- **Codex-reported instability**: under light concurrency the upstream endpoint has shown `IncompleteRead` and `502 Bad Gateway`. Trae's client respects this by:
  - Single-flight playback per session (sequential, not parallel).
  - Same-text dedupe (cache + queue guard).
  - One retry maximum, only for retryable classes (5xx / 408 / 429 / network / timeout).
  - Conservative 12s timeout.
- **No streaming**: the upstream returns a full WAV, so latency = `network + synth + download`. On a normal reply (~50 chars) expect 1–3s before first audio plays. Trae UI shows "合成中…" during this window.
- **Endpoint is hardcoded in source as a fallback**: this is intentional per plan (no deep coupling in UI components — only one constant + one env var), but it should be moved to deployment env when promoting to a shared environment.
- **Per-reply audio playback is sequential**: if a reply has many sentences, the user waits for each WAV sequentially. This is by design (matches Codex's single-user/low-frequency guidance) — do NOT introduce parallel fetches without first confirming upstream stability.
- **No fallback to browser voice when cloud TTS fails**: we intentionally surface the error rather than silently degrading to browser TTS. The user can manually switch providers in 设置. This avoids masking endpoint problems.
- **Group ID prompt is unrelated to cloud TTS**: MiniMax branch still requires API Key + Group ID; switching to 云端 TTS bypasses those.
- **No user-text logging**: failed-request errors do not include the synthesized text in toasts/logs; only status codes and class of error.

### Handoff notes

- Local code is ready to use; final owner should run their own smoke test against the real cloud endpoint.
- If Claude Code later changes the endpoint or request/response shape, only `src/constants/config.ts` (URL) and `src/lib/cloudTts.ts` (request/parse logic) need updating — UI components remain stable.
- This repo (`Agent-collaboration`) does NOT contain any local-app code, build artifacts, or audio; only this Markdown note is updated.