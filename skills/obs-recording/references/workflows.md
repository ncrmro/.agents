# Agent-operated OBS workflows

The OBS projects surveyed for this skill implement these recurring workflows.
Prefer a small, verifiable path for each one instead of exposing the entire
obs-websocket protocol as ordinary tools.

| Workflow | Sequence | Local surface |
| --- | --- | --- |
| Readiness | connection/version → recording state → scene/sources → audio config → disk/logs | `doctor`, then `meters` when audio matters |
| Fast transport | explicit start/stop/pause/resume → observe resulting state | `start`, `stop`, `pause`, `resume` |
| Visual verification | capture program/source → inspect for black/frozen/wrong layout | `screenshot`; treat the image as sensitive |
| Audio verification | inspect mute/fader → sample live pre/post-fader signal → validate recorded tracks | `audio`, `meters`, then `ffprobe`/signal analysis |
| Portable setup | discover live names/kinds → compare an operator manifest → let the human grant portal/device access | `sources`, manifest templates, `doctor --manifest` |
| Recording fixture | preflight → screenshot → start → observe bytes/time → stop → inspect returned file | Run only after telling the user media will be captured |
| Recovery | rediscover live capabilities/state → retry an explicit idempotent operation → preserve output/log evidence | `status`, `doctor`, dedicated verbs |
| Show orchestration | named scene/loadout → preview intended changes → apply → verify the result in the preview and reported state | Keep as a later high-level layer, not raw protocol calls |

## Useful ecosystem patterns

- Use reusable prompts or skills for readiness, recording lifecycle, audio
  checks, visual checks, and teardown.
- Expose status as passive context when an MCP client benefits from resources;
  keep recording and scene changes as tools.
- Prefer composite tools such as health diagnosis or manifest preflight when
  they add interpretation and guardrails.
- Use events for high-volume or long-lived observations such as volume meters
  and output-state changes. Polling remains a simple recovery path.
- Preview scene/preset changes and verify the result. Persist only portable
  operator intent; avoid copying device IDs or portal tokens.
- Keep screenshots opt-in, short-lived, and private. They can reveal anything
  visible in the captured scene.
- Invalidate cached scene/source state after scene switches, collection changes,
  source mutation, or a user report that nothing visible changed.

Operational constraints live in [operations.md](operations.md). MCP-specific
acceptance and confirmation rules live in [mcp.md](mcp.md).

## MCP shape if needed

A useful local MCP would keep the script as the implementation and expose:

- resources: current status, doctor report, scene/source manifest diff;
- prompts: readiness check, disposable recording fixture, failure triage;
- tools: `obs_doctor`, `obs_meters`, `obs_record_start`,
  `obs_record_stop`, `obs_record_pause`, `obs_record_resume`,
  `obs_screenshot`.

Give every tool accurate advisory annotations, then enforce the same policy in
the handler. A failed confirmation path must block the operation.

## Survey sources

- [OBS remote control guide](https://obsproject.com/kb/remote-control-guide)
- [obs-websocket protocol](https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md)
- [agentic-obs](https://github.com/ironystock/agentic-obs)
- [obs_mcp code-mode server and skills](https://github.com/cdavis-code/obs_websocket_workspace/tree/main/packages/obs_mcp)
- [OBS-MCP full-protocol server](https://github.com/xDarkzx/OBS_MCP)
- [obs-stream-mcp](https://github.com/sid-fou/obs-stream-mcp)
- [OBS ShowRunner MCP](https://github.com/takurot/obs-showrunner-mcp)
- [MCP server primitives](https://modelcontextprotocol.io/specification/2025-06-18/server/index)
