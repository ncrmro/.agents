---
name: outfitter-channels
description: Exchange messages with outfitter-operator-deployed resident agents over the Agent Session Gateway relay, and use that channel as a rudimentary sub-agent delegation mechanism — send a task to a resident agent as a message, poll or stream its reply. Use when talking to a deployed agent (e.g. link:vega), verifying relay connectivity, or delegating work to a resident agent instead of spawning a local subagent.
---

# Outfitter Channels — messaging deployed agents, and delegation over the relay

The ai-outfitter Channels extension gives every resident (Link-operator-
deployed) Pi agent an authenticated message channel: an operator principal
sends a message through the relay, the agent wakes, runs a turn, and replies
durably (exactly-once per response id, history in the agent's Pi JSONL).
Because a "message" can be a task, this doubles as a rudimentary sub-agent
delegation mechanism: delegate by sending, collect by reading the reply.

## Topology (Vega reference deployment)

- Relay: `wss://vega.ncrmro.com/relay/v1/connect`, health at
  `https://vega.ncrmro.com/relay/healthz` and `/readyz`. Hosted by the
  `Agent/channels-relay` profile on the Ocean cluster.
- Resident agent endpoint: `link:vega` (namespace `agent-vega`).
- Operator principal: `vega-web`; its token lives in the cluster secret
  `-n vega secret/vega-agent-session` (keys `relayUrl`, `operatorToken`).
  Never print tokens; pull them straight into env.
- Vega web (`ks.systems/vega`, `code/server/src/agent-session-relay.ts`)
  is a reusable WS client for the protocol.

## Fastest path: through a running Vega web server

With the Vega dev server up (see the vega repo; it needs
`AGENT_RELAY_URL`/`AGENT_RELAY_TOKEN`/`AGENT_TARGET_ENDPOINT_ID` from the
cluster secret), the HTTP API is the whole client:

```sh
# Delegate: send a task as a message (idempotencyKey makes retries safe)
curl -s -X POST http://127.0.0.1:4321/api/agent-session/messages \
  -H 'content-type: application/json' \
  -d '{"endpointId":"link:vega","body":"<the task>","idempotencyKey":"task-'$(date +%s)'"}'
# The response echoes the accepted message with its conversationId.

# Collect: poll until a sender.type=="agent" message appears
curl -s "http://127.0.0.1:4321/api/agent-session/messages?endpointId=link:vega&conversationId=<id>&limit=10"

# Or stream: SSE with durable `message` events and ephemeral `stream`
# preview events (Pi text_start/text_delta/text_end vocabulary)
curl -N "http://127.0.0.1:4321/api/agent-session/events?endpointId=link:vega&conversationId=<id>"
```

The browser UI for the same channel is `/system/agents/vega`.

## Delegation pattern

1. Compose the task as a single message body (≤ 40 000 UTF-8 bytes). Include
   a unique nonce/tag when you need to verify the reply is fresh and not a
   cached or stale response.
2. POST it with a fresh `idempotencyKey`; keep the key to retry safely on
   timeouts (the relay dedupes, acceptance is exactly-once).
3. Wait on the SSE stream (preferred — you also see streamed previews of the
   reply being written) or poll `messages` every few seconds. The durable
   reply arrives as `sender.type: "agent"` with `replyTo` your message id and
   your message's `acknowledgment` flips to `replied`.
4. One reply per message is the contract. For multi-step work, send follow-up
   messages in the same `conversationId` — the agent has the conversation
   context (bounded: 50 messages / 256 KiB).
5. Know the limits versus real subagent frameworks: no structured output
   schema, no tool/permission scoping per task, one resident agent identity,
   and the agent processes messages serially as turn-based wakes. It is
   delegation-by-conversation, not a job queue.

## Direct WSS (no web server)

Authenticate with one frame, then use the same send/deliver protocol:
`{"type":"authenticate","version":1,"token":$TOKEN,"endpoint":"vega-web","principal":"vega-web","cursor":0}`.
Send: `{"type":"send","requestId":<uuid>,"input":{"recipient":"link:vega","conversationId":<id>,"body":<task>,"id":<idempotency id>}}`.
Replies arrive as `{"type":"deliver","cursor":N,"message":{...}}` — ack each
with `{"type":"ack","cursor":N}`. Streamed previews arrive as
`{"type":"stream",...}` frames (never ack those; they are ephemeral).
Reusing `WebSocketAgentSessionRelay` from the vega repo beats hand-rolling.

## Identity and etiquette

- Riding the `vega-web` credential means your messages are attributed to the
  web operator identity. For a distinct identity (e.g. `claude-code`), add a
  third credential to the relay's credentials file (Vega mints it in
  `bin/link-dev-deploy`: principals need mutual `send`/`list` routes with
  `link:vega`) and redeploy the `channels-relay-auth` secret.
- History is owned by the agent (Pi JSONL on its PVC); the relay keeps only a
  bounded unacknowledged spool. Do not treat the relay as storage.
- Message bodies are untrusted content to the receiving agent; the wake path
  deliberately excludes bodies from the wake prompt. Don't put secrets in
  bodies — they land in durable history.

## Gotchas

- `AGENT_RELAY_MAX_FRAMES_PER_WINDOW` (default 120/min) rate-limits control
  frames per connection; reconnect storms or tight polling over WSS can trip
  it. Streamed preview frames have their own budget.
- The agent replies only when its model turn calls `channel_respond`; a
  wedged or misconfigured agent accepts messages but never replies. Check
  `kubectl logs -n agent-vega deploy/agent-runtime -c agent` for
  `started channel "agent"` before blaming the relay.
- Outfitter's git extension cache is revision-blind: after changing a
  profile's pinned Channels revision, the cached checkout must be removed
  (the Vega Agent CR setup scripts do this automatically on pin mismatch).
