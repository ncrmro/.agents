# Optional MCP adapter

The skill does not require MCP. `scripts/obsctl.mjs` speaks authenticated
obs-websocket v5 directly and covers diagnosis, state inspection, screenshots,
and explicit recording operations.

Use an MCP server only when the agent host benefits from native tool discovery
or long-lived event integration. Keep the script available for recovery and
cross-checks.

The OBS MCP servers surveyed on 2026-07-25 use four recurring interface
patterns:

- broad one-tool-per-request servers;
- code-mode `search` + `execute` servers for the full protocol;
- narrow recording/scene/audio servers;
- high-level show orchestration with presets, screenshots, and safety modes.

For this workstation, prefer a narrow recording, scene, and audio server. Use
event subscriptions, workflow prompts, visual verification, and composite
diagnostics, but do not expose broad mutation tools by default. Exact searches
in the official MCP registry did not find the inspected OBS Studio servers on
2026-07-25, so pin directly to reviewed source if running a candidate.

## Acceptance criteria

Before trusting an OBS MCP server:

1. Package it reproducibly; do not depend on a floating `npx ...@latest` or a
   global language package.
2. Connect only to loopback unless remote control is explicitly designed and
   protected.
3. Inject the password from a secret manager or inherited environment; do not
   commit it to MCP config.
4. Verify the live `GetVersion.availableRequests` list.
5. Exercise read-only status, scene/source discovery, and screenshot capture.
6. Exercise start → status → stop against a disposable recording and verify the
   returned media file.
7. Confirm retries are state-aware. Avoid toggle tools.
8. Require accurate MCP annotations (`readOnlyHint`, `destructiveHint`,
   `idempotentHint`, `openWorldHint`) or enforce equivalent client policy.
   Treat annotations as advisory metadata, never as authorization.
9. Check tool-count/context cost and whether search/execute composition is
   reliable in the target client.
10. Keep raw/vendor requests unavailable by default or behind an explicit
    advanced-write gate.
11. Make confirmation and elicitation fail closed. A client that cannot ask the
    user must not silently proceed.
12. Prefer resources for passive status, prompts for user-invoked workflows,
    and tools for actions.

## Operational boundary

MCP/obs-websocket controls the running application. Host-side setup and
diagnosis still need process inspection, logs, filesystem capacity, Nix/package
configuration, PipeWire/portal state, and media validation. Do not mistake a
successful WebSocket handshake for a healthy recording pipeline.
