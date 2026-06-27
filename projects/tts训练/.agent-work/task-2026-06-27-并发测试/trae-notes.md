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

