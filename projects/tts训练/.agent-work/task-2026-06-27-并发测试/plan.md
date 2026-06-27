# Plan

## Current Accepted Plan

1. Codex defines the task contract, acceptance criteria, and review checklist in this Markdown task package.
2. Claude Code implements the cloud inference API in the real cloud-server TTS project, not in this repository.
3. Claude Code records implementation details in `claude-review.md` or a new task note section: changed files, endpoint, port, command, request example, response format, safety setting, and test result summary.
4. Claude Code provides enough code context for review: sanitized diff, key functions, config snippets, and error-handling behavior. Do not paste secrets or large files.
5. Codex reviews the implementation from the provided diff/context and records findings in `codex-notes.md`.
6. Claude Code fixes review issues in the real project and records follow-up.
7. Final result, endpoint status, and remaining risks are recorded in `done.md`.

## Claude Code Assignment

Claude Code owns implementation on the cloud server.

Required implementation behavior:

- Load the round-53 TTS weight.
- Use inference parameters `scale=1.5` and `seed=9999`.
- Expose a text-to-audio endpoint reachable from local computers.
- Accept text input only for v1.
- Return generated audio as either a downloadable file response or a documented JSON response containing a safe audio URL/path.
- Include input validation: reject empty text and oversized text.
- Avoid logging full user text if it may contain private content.
- Bind service intentionally: document whether it binds `127.0.0.1`, `0.0.0.0`, or reverse proxy.
- Document cloud firewall/security-group changes needed for local access.
- Add a health check endpoint if feasible.

Claude Code must record:

- External project path or safe alias.
- Changed files.
- Startup command.
- Port.
- Request example.
- Response example.
- Weight path alias, not the actual weight file copied here.
- Test results for at least one successful local or remote call.
- Any unresolved blocker.

## Codex Assignment

Codex owns review and coordination in this repository.

Review focus:

- Does the service always use round-53 weight and `scale=1.5`, `seed=9999`?
- Can local machines reach the cloud endpoint without exposing unnecessary services?
- Are request and response formats stable and documented?
- Are empty, too-long, or malformed text inputs handled?
- Is generated audio written to a safe location with cleanup strategy?
- Are secrets, absolute sensitive paths, datasets, weights, and large logs kept out of this repository?
- Is there enough verification evidence to trust the endpoint works?

## Suggested API Contract

Claude Code may adjust this if the real project already has conventions, but must document the final contract.

```text
GET /health
Response: {"status":"ok"}

POST /tts
Request JSON: {"text":"要合成的文本"}
Response option A: audio/wav or audio/mpeg binary
Response option B: {"audio_url":"...", "duration_seconds": 0.0}
```

## Verification

- Cloud service starts without errors.
- `/health` returns success if implemented.
- `/tts` with a short Chinese text returns playable audio.
- At least one local computer outside the server successfully calls the cloud endpoint.
- Claude Code records command/output summary in Markdown.
- Codex review has no blocking findings, or accepted risks are recorded in `decisions.md`.

