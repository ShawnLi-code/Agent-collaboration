# Risks

## Open Risks

- The cloud port may be exposed too broadly if bound to `0.0.0.0` without firewall or security-group restrictions.
- The endpoint may accidentally use a different checkpoint, `scale`, or `seed` if defaults are scattered in the real TTS project.
- Long text inputs may exhaust GPU memory, block the queue, or create very large audio files.
- Generated audio files may accumulate on disk without cleanup.
- Review may be incomplete if Claude Code does not provide diff/context for the real implementation.
- Secrets, absolute sensitive paths, or model/data details may be pasted into Markdown by accident.

## Assumptions To Verify

- Round-53 weight exists on the cloud server and can be loaded by the inference code.
- The real TTS project already has a working single-text inference path.
- The server firewall/cloud security group can safely expose the selected port to local callers.
- Local caller machines can reach the cloud server network address.

## Failure Modes

- API starts but local machines cannot connect because firewall/security group is closed.
- API returns audio but uses wrong checkpoint or wrong parameters.
- API works for one request but fails under repeated or concurrent requests.
- API writes audio to a public directory with unsafe filenames.
- Logs expose full input text, private paths, tokens, or stack traces.
- This repository receives code, weights, data, generated audio, or large logs instead of Markdown summaries.

