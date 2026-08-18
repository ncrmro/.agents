# Per-agent OpenAI keys for resident agents

Each resident agent gets its own OpenAI **project** and its own API key inside
that project. Spend is then attributable per agent in the usage dashboard, and
each agent can carry its own rate limit and hard budget cap.

This replaces `openai-codex/*` for resident agents. That provider authenticates
against the shared Codex subscription seeded on the pod's PVC: spend is not
attributable to any one agent, and when the subscription hits its usage limit
every agent sharing it stops — the wake still fires, the turn dies before the
agent can read its task, and after five deliveries the task is abandoned.

## Add an agent

1. In the OpenAI dashboard, create a project named `agent-<slug>` (e.g.
   `agent-luce`). Set a monthly budget cap on it — the cap is per project, so
   a runaway agent cannot spend another agent's budget.
2. Create an API key **inside that project**, named for where it runs:
   `ocean-agent-luce`.
3. Create the Secret in the agent's namespace. Keep shell tracing off, and
   prefer a file over an argument so the key stays out of shell history:

   ```sh
   kubectl -n agent-<slug> create secret generic <slug>-openai \
     --from-file=OPENAI_API_KEY=/path/to/key.txt
   ```

4. Reference it from the `Agent`, alongside the other credential secrets:

   ```yaml
   credentials:
     - secret: <slug>-openai
       as: env
   ```

5. Point the profile at the provider:

   ```yaml
   model: openai/gpt-5.6-sol
   ```

   The `openai` provider is defined in this catalog's `models.json` and reads
   `$OPENAI_API_KEY`. A profile naming `openai/...` in a catalog with no
   `models.json` cannot resolve the provider at all.

## Rotate a key

Replace the Secret, then restart the agent's Deployment — the key is read into
the process environment at start, so a live pod keeps the old value:

```sh
kubectl -n agent-<slug> delete secret <slug>-openai
kubectl -n agent-<slug> create secret generic <slug>-openai \
  --from-file=OPENAI_API_KEY=/path/to/new-key.txt
kubectl -n agent-<slug> rollout restart deployment/agent-runtime
```

Delete the old key in the project afterwards, not before: the running pod uses
it until the restart completes.

## When an agent stops working

A quota or key fault shows up as a woken agent that never settles its task.
Look for the wake, then the error on the same task id:

```sh
kubectl -n agent-<slug> logs deployment/agent-runtime --all-containers --since=10m \
  | grep -E 'agent_woken|usage limit|invalid_api_key|wake_abandoned'
```

`a2a_wake_abandoned … wake delivery cap 5 reached without Task settlement`
means the task was dropped. It will not retry on its own — re-fire it by
unassigning and reassigning the issue.
