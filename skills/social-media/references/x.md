# X — composer mechanics

Per-platform detail for actually getting a draft into X. `platforms.md` has the
cross-platform numbers; this file has the mechanics. Read it before publishing
to X, not while.

**verified: 2026-07-29** — exercised against the live Articles composer while
loading a longform draft. Everything below was observed, not recalled. The
post/thread composer was **not** exercised; see "Not yet verified".

## The rule that matters

**The markdown file is canonical. The composer is a render target.**

Never patch a live draft to match an edited file. To update a draft: delete it,
create a new one, paste once. In the verified session, a full re-render took
about 90 seconds, and delete-and-recreate was more reliable than in-place
patching. Re-check this workaround after X editor changes.

## Rendering capabilities

| Capability | X articles |
| --- | --- |
| Headings | Heading / Subheading / Body only (one dropdown, three options) |
| Bold, italic, strikethrough | yes |
| Quote, bullet list, numbered list, link | yes |
| Images | yes, via Insert |
| Cover image | yes, 5:2 recommended |
| **Monospace / code block** | **no** — body is forced to `TwitterChirp`, proportional |
| Newlines in a block | preserved (`white-space: pre-wrap`); box-drawing characters survive |

**Consequence:** any ASCII diagram, aligned table, or code listing where column
alignment carries meaning **must be an image**. Line breaks survive, so pasted
ASCII looks nearly right and is actually broken — the failure is quiet. Decide
this at outline time, and plan alt text with it.

## Loading an article

1. Articles → Write. Confirm the draft is virgin (title empty, body empty)
   before touching it. A clean paste into a fresh editor is the only reliably
   correct operation.
2. Set the title through the React textarea, not by clicking:

   ```js
   const ta = [...document.querySelectorAll('textarea')]
     .find(t => t.placeholder === 'Add a title');
   Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value')
     .set.call(ta, 'The title');
   ta.dispatchEvent(new Event('input', { bubbles: true }));
   ```

3. Paste the body as HTML in one shot, via a synthetic clipboard event:

   ```js
   const ed = [...document.querySelectorAll('[contenteditable="true"]')].pop();
   ed.focus();
   const dt = new DataTransfer();
   dt.setData('text/html', html);
   dt.setData('text/plain', html.replace(/<[^>]+>/g, ''));
   ed.dispatchEvent(new ClipboardEvent('paste',
     { clipboardData: dt, bubbles: true, cancelable: true }));
   ```

   `<p> <h2> <strong> <br>` survive. `<pre> <code> <em>` are stripped or
   normalized. Convert leading spaces to `&nbsp;` if indentation must survive.
4. If the body had an empty leading block, the **first pasted block is
   swallowed** — prepend a throwaway `<p>LEADBLOCK</p>` and delete that line
   afterwards.
5. Insert images for any diagram, with alt text.
6. **Reload the page and verify the saved copy** with the protocol in
   "Verification protocol."

## Traps

| Trap | What actually happens |
| --- | --- |
| Pasting again to "replace" content | It **appends**. Two pastes = the whole article twice. `ctrl+A` + Delete does not reliably clear the document |
| Trusting the editor DOM | `innerText` reads clean while the **saved** document is corrupt. Every failure this session was invisible to an in-page read |
| Typing markdown | `## ` becomes a heading **only from Body style**. After a heading, Enter inherits heading style and `##` stays literal. `**bold**`, backticks and `*italic*` never convert |
| `ctrl+A` intending the title | Scopes to whichever field has focus — commonly the body. Typing then destroys the article |
| Clicking by coordinate | Page zoom changes between screenshots, so coordinates drift. Use element refs for anything destructive |
| Mutating editor DOM directly | Removing a node breaks the editor's internal state; subsequent pastes become silent no-ops |
| Assuming a slow load failed | Hydration after reload takes 20–40s. Poll for the title textarea and the contenteditable |

## Verification protocol

Reload the draft URL, wait for hydration, then assert against the **saved**
copy:

```js
const ta = [...document.querySelectorAll('textarea')]
  .find(t => t.placeholder === 'Add a title');
const ed = [...document.querySelectorAll('[contenteditable="true"]')].pop();
const t = ed.innerText;
({ title: ta.value,
   words: t.split(/\s+/).filter(Boolean).length,
   headings: [...ed.querySelectorAll('h1,h2,h3')].map(h => h.innerText),
   dupCheck: (t.match(/<a distinctive sentence>/g) || []).length,  // must be 1
   scaffolding: /LEADBLOCK/.test(t) })                             // must be false
```

Duplication is the failure mode to test for: compare the word count against the
source and confirm each heading appears exactly once.

## Deleting a draft

Editor header → **More** → **Delete Article** → confirm "Yes, delete". It is
*not* in the draft row's menu in the sidebar, which only offers focus mode and
preview. Drive both clicks by element ref. Deletion is irreversible, so confirm
with the user first.

## Not yet verified

- The **post/thread composer** — only the Articles composer was exercised. Do
  not assume the traps above transfer.
- **Image insertion** through the Insert menu, and whether alt text is offered
  at insert time.
- Whether scheduling exists for articles.
