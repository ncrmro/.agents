# Production manifest

`production.yml` is the production contract. It records the story, capture
boundaries, actions, expected states, artifacts, and output requirements.

The initial manifest is descriptive. It is not an executable automation
format. Do not run manifest text as shell input.

## Required top-level fields

| Field | Purpose |
| --- | --- |
| `version` | Manifest format version. |
| `title` | Human-readable video title. |
| `claim` | Product fact that the demo must prove. |
| `audience` | Intended viewer. |
| `output` | Frame, duration, and file requirements. |
| `safety` | Capture boundaries and known side effects. |
| `scenes` | Ordered scene list. |
| `deliverables` | Required files. |

## Narration fields

Add `narration` when the video uses spoken narration.

The section MUST contain:

- `provider` — `piper` or `elevenlabs`.
- `script` — the narration source under `raw/`.
- `voice_id` — the selected voice name or ID.
- `model_id` — the selected model name or ID.
- `native_artifact` — the provider response before normalization.
- `output` — the normalized WAV under `derived/`.
- `external_request` — `true` for ElevenLabs and `false` for Piper.
- `approval` — the user approval state for an external request.

Do not record an API key in the manifest.

## Scene fields

Each scene MUST contain:

- `id` — stable scene identifier.
- `purpose` — one statement about why the scene exists.
- `layout` — source placement in the frame.
- `sources` — one or more terminal, browser, or desktop sources.
- `actions` — ordered action and expected-result pairs.
- `sync` — synchronization method for concurrent sources.
- `artifacts` — expected raw files.

Use one scene for one recoverable take. Split a scene when an action has a
different initial state or needs a separate retry boundary.

## Source fields

Each source MUST contain:

- `id` — stable source identifier within the scene.
- `type` — `terminal`, `browser`, or `desktop`.
- `driver` — tool or operator that performs actions.
- `recorder` — tool that records the source.
- `artifact` — planned raw artifact path.
- `start_state` — state that must exist before capture.
- `end_state` — state that proves source completion.

## Action fields

Each action MUST contain:

- `id` — stable action identifier.
- `source` — source that performs the action.
- `do` — one approved action.
- `expect` — one observable result.

Add `side_effect` when an action changes an external system. Add `reset` when
the scene needs a specific recovery action before a retry.

## Synchronization

A single-source scene MAY use `sync.method: none`.

A concurrent scene MUST use one of these methods:

- `controller-event-log` — all actions use one timestamped event log.
- `visible-marker` — each source shows the same unique marker.
- `audible-marker` — each pixel recorder captures the same sound.
- `shared-timecode` — verified recording tools provide a common timecode.

State the expected synchronization tolerance in milliseconds when timing is
important.

## Change control

Update the manifest before capture when the story, actions, side effects, or
source boundary changes. After capture, replace planned artifact paths with the
actual returned paths.

Do not rewrite the raw artifacts to match the manifest.
