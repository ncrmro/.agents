---
name: slack-message
description: Format concise, copy-paste-ready Slack messages, especially clean parent/child lists combining a primary item with PR, issue, preview, or other supporting links. Use when the user asks for Slack formatting, a Slack-ready block, a copy-paste message, or iterative cleanup of list indentation, bolding, spacing, and link placement.
---

# Slack Message

Produce a message that can be pasted directly into Slack. Treat every explicit
formatting correction from the user as a constraint on the next output.

## Workflow

1. Preserve the requested content. Verify or refresh links and statuses when the
   request depends on current external state.
2. Make each primary subject a top-level list item. Keep its main links, such as
   the blog PR and preview, on that same top-level line.
3. Put supporting PRs, issues, and notes beneath their owning item as child
   bullets.
4. Return only one fenced `markdown` code block unless the user requests a
   different wrapper.
5. Check the output against the formatting contract before returning it.

## Formatting Contract

- Use one asterisk on each side for Slack bold: `*text*`. Never use `**text**`.
- Use standard Markdown links, `[label](url)`, when the user requests Markdown.
- Indent every child bullet with exactly four spaces.
- Do not insert blank lines between parents, children, or adjacent list items.
- Keep preview and primary artifact links on the parent line, not as children.
- Give each related child a short label, optional status, and concise relevance
  note.
- Omit unrelated or speculative links.
- Do not add commentary outside the copy-paste block.

## Example

```markdown
- *Post title* — [Blog PR #47](https://example.com/pull/47) · [Preview](https://example.com/preview)
    - [project PR #2](https://example.com/pull/2) (draft) — Direct implementation
    - [project issue #165](https://example.com/issues/165) (open) — Architecture
- *Second post* — [Blog PR #46](https://example.com/pull/46) · [Preview](https://example.com/preview-2)
    - [project PR #8](https://example.com/pull/8) (open) — Supporting capability
```
