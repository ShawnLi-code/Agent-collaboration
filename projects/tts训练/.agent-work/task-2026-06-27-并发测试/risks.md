# Risks

## Open Risks

- An Agent may misunderstand the repository as the real TTS code repository and try to add code or large assets.
- External execution details may be too vague for another Agent to review or reproduce.

## Assumptions To Verify

- Real TTS code, data, checkpoints, and runtime logs live outside this repository.
- The human owner will provide safe external paths or summaries when execution evidence is needed.

## Failure Modes

- Code, datasets, audio samples, model weights, or large logs are accidentally committed.
- A test result is claimed as complete without recording environment, scale, command summary, and observed outcome.

