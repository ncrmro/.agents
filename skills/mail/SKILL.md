---
name: mail
description: Process the agent's JMAP INBOX with xin, reply in-thread, and move completed messages to Processed.
allowed-tools: Bash(xin:*), Bash(jq:*)
---

# Agent mail

Use the `xin` JMAP CLI with credentials supplied through `XIN_BASE_URL`,
`XIN_BASIC_USER`, and `XIN_BASIC_PASS`. Parse its stable JSON output; do not use
plain output. `$LINK_MAIL_PROCESSED` names the completed-mail mailbox and
defaults to `Processed`.

There is no local reply state. A message is pending exactly while it remains in
INBOX, so always reply first and move it second.

The JMAP state-change event can arrive just before a newly delivered message is
visible to search. On every channel wake, retry an empty INBOX search for up to
30 seconds (15 attempts, two seconds apart) before concluding that there is no
work. Once any message is visible, repeat until INBOX is empty:

1. List pending messages:

   ```bash
   for attempt in {1..15}; do
     ids="$(xin messages search "in:inbox" --max 200 | jq -r '.data.items[].emailId')"
     [ -n "$ids" ] && break
     [ "$attempt" -eq 15 ] || sleep 2
   done
   printf '%s\n' "$ids"
   ```

2. Read one message:

   ```bash
   xin get <emailId> --format full
   ```

3. Compose a genuine, useful reply and preserve the thread:

   ```bash
   xin reply <emailId> --text "…reply…"
   ```

   Confirm the returned JSON has `"ok": true`. If it does not, leave the
   original in INBOX and report the failure.

4. Mark the original complete:

   ```bash
   xin batch modify <emailId> --remove inbox --add "$LINK_MAIL_PROCESSED"
   ```

Do not delete mail, move an unreplied message, expose credentials, or configure
accounts. Use `xin <command> --help` when command discovery is needed.
