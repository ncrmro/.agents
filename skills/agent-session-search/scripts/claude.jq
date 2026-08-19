# Extract only user + assistant text turns from a Claude Code session .jsonl.
# Drops tool_use, tool_result, thinking, and every harness bookkeeping record.
def txt:
  if type == "string" then .
  elif type == "array" then (map(select(.type == "text").text) | join("\n"))
  else "" end;

select(.type == "user" or .type == "assistant")
| {role: .type, ts: .timestamp, text: (.message.content | txt)}
| select(.text | length > 0)
