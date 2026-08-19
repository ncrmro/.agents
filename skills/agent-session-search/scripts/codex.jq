# Extract only user + assistant turns from a Codex rollout-*.jsonl.
# Handles both rollout variants: response_item/message and event_msg/{user,agent}_message.
def txt:
  if type == "string" then .
  elif type == "array" then (map(.text // .input_text // empty) | join("\n"))
  else tostring end;

select(.type == "response_item"
       and .payload.type == "message"
       and (.payload.role == "user" or .payload.role == "assistant"))
| {role: .payload.role, ts: .timestamp, text: (.payload.content | txt)}

, (select(.type == "event_msg"
          and (.payload.type == "user_message" or .payload.type == "agent_message"))
   | {role: (if .payload.type == "user_message" then "user" else "assistant" end),
      ts: .timestamp,
      text: (.payload.message // .payload.text // "" | txt)})
