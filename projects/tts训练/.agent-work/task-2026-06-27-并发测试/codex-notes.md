# Codex Notes

## Role

Codex owns local pressure testing against Claude Code's exposed cloud TTS endpoint.

Codex does not own server implementation review for this phase.

## Local Test Artifacts

Raw artifacts are intentionally local-only and are not committed to Git.

```text
E:\Shawn_code\Agent-collaboration-results\tts-concurrency-test\
```

Files created locally:

- `pressure_report.md`
- `pressure_results.csv`
- `pressure_summary.json`
- `audio/*.wav`

## Pressure-Test Summary

Target:

```text
https://u539523-9a8d-5d91dc27.westx.seetacloud.com:8443
```

Health check:

- `GET /health` returned HTTP 200.
- Response model: `epoch53_scale1.5_seed9999`.

Light pressure test:

| Concurrency | Requests | Success | Fail | Success Rate | Avg Latency |
| --- | ---: | ---: | ---: | ---: | ---: |
| 1 | 3 | 3 | 0 | 100% | 0.883s |
| 2 | 6 | 3 | 3 | 50% | 1.093s |
| 4 | 8 | 7 | 1 | 87.5% | 1.226s |

Failure details:

- `IncompleteRead` during some concurrent WAV downloads.
- One nginx `502 Bad Gateway` at concurrency 2.

## Interpretation

- Single request path is usable.
- The public endpoint is reachable from local machine.
- Concurrent reliability is not proven. Server/proxy streaming, upstream worker model, or timeout behavior should be reviewed before assuming stable multi-user load.

## Recommendation To Trae

- Use endpoint for one-at-a-time TTS playback first.
- Add timeout, loading state, retry-once, and visible failure handling.
- Avoid overlapping TTS calls unless the user explicitly triggers them.

