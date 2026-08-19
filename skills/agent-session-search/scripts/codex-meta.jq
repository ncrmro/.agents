# One-line provenance header for a Codex rollout file.
select(.type == "session_meta")
| .payload
| {id, cwd, originator, thread_source, ts: .timestamp}
