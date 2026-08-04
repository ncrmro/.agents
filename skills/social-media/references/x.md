# X — composer mechanics

Per-platform detail for actually getting a draft into X. `platforms.md` has the
cross-platform numbers; this file has the mechanics. Read it before publishing
to X, not while.

**verified: 2026-08-03** — exercised against the live Articles composer, first
loading a longform draft (2026-07-29), then applying a cover image and two code
blocks (2026-08-03). Everything below was observed, not recalled. The post/thread
composer was **not** exercised; see "Not yet verified".

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
| Images | yes, via Insert → Media |
| Cover image | yes, 5:2 recommended |
| **Code block** | **yes** — Insert → Code. Language picker, syntax highlighting, indentation preserved, reader gets a copy button. 10,000 chars per block |
| Table, LaTeX, divider, embedded posts, GIF | yes, all under Insert |
| **Monospace in body text** | **no** — running body is forced to `TwitterChirp`, proportional |
| Newlines in a block | preserved (`white-space: pre-wrap`); box-drawing characters survive |

**Corrected 2026-08-03.** This file previously said X articles have no code
block and no tables. Both are wrong — the Insert menu offers Media, GIF, Posts,
Divider, **Code**, **LaTeX** and **Table**. Drafts written against the old
assumption specify screenshots for things that should be native blocks.

**Consequence:** the choice is now per-artifact, not automatic.

| Artifact | Render as |
| --- | --- |
| Source code, config files, shell sessions | **native code block** — copyable, highlighted, indentation-safe |
| ASCII diagrams, git graphs, box-drawing art | **image** — no language fits, and a code block gives no benefit over a picture |
| Aligned data | table, or an image if the alignment is decorative |
| Single-line commands | bold text on their own line — stays copyable, no block needed |

The rule underneath all four rows: **copyable beats pretty.** An image nobody
can select is a downgrade whenever the content is text someone would paste.
Reach for an image only when the alignment is the meaning and no block type
holds it.

Body text still has no monospace, so an inline `like this` span is impossible —
bold it instead.

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
5. Add the cover, then the code blocks and images (below).
6. **Reload the page and verify the saved copy** with the protocol in
   "Verification protocol."

## Adding the cover image

There is exactly one `input[type=file]` on the page — `data-testid="fileInput"`,
accepting `image/jpeg,image/png,image/webp`, single file — and it belongs to the
cover slot. Get its ref with `find`, then upload straight to it; never click a
file button, which opens a native picker you cannot see.

Uploading opens an **Edit media** crop dialog with the image already framed. If
the source is already 5:2 the default framing is correct — click **Apply**. No
alt-text field is offered for the cover.

## Inserting a code block

1. Put the caret where the block goes: click the last line of the preceding
   paragraph, press `End`, then `Return` to open a fresh block. Verify with
   `getSelection().anchorNode` before continuing — a misplaced caret puts the
   block in the wrong section.
2. Toolbar **Insert** → **Code**. A dialog opens with a language search, a code
   textarea, Preview and Insert.
3. Type into the language search and click the suggestion. Match on the language
   name, not the filetype: `ssh` finds nothing, `bash` finds Bash. `nix` finds
   Nix.
4. Fill the code textarea with the React value setter, the same trick as the
   title — typing multi-line code by keystroke is slow and mangles indentation:

   ```js
   const ta = [...document.querySelectorAll('textarea')]
     .filter(t => t.placeholder !== 'Add a title' && t.offsetParent !== null)[0];
   ta.focus();
   Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value')
     .set.call(ta, code);
   ta.dispatchEvent(new Event('input', { bubbles: true }));
   ```

5. Click **Insert**. Confirm placement by reading the text right after the
   preceding paragraph's last words.

Blocks are `div.longform-unstyled` (Draft.js) inside the contenteditable, and
`ed.children` is a single wrapper — query `div.longform-unstyled`, not the
editor's direct children, when locating a paragraph.

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

## Publishing an article

Only with the user's explicit go-ahead in this session — see the skill's
boundaries. Verify the saved copy first; publishing is the point of no return
for delete-and-reload.

Editor header → **Publish** opens a *Publish Article* dialog:

| Field | Default | Notes |
| --- | --- | --- |
| Choose your audience | Everyone | |
| Who can reply | Everyone | |
| Caption | empty | Optional. The article link attaches automatically |
| Post preview | — | Shows the card as followers will see it — check the cover here |

The caption is post copy going out under the user's name. Don't invent one: the
article card already carries the title and lead. Either use a caption the draft
file specifies, ask, or publish without one.

Confirm with the dialog's own **Publish**. On success the tab navigates to the
live status URL (`x.com/<handle>/status/<id>`) and a "Your Article has been
published" toast appears.

**Then a "Try Boosting this post!" dialog opens — this is paid promotion.**
Dismiss it with **Maybe Later**. Never click "Boost visibility now": it spends
the user's money and no publishing request implies buying reach.

Read the real posted URL and timestamp off the live page — never construct
either:

```js
({ url: location.href,
   posted_at: document.querySelector('time')?.getAttribute('datetime') })  // UTC ISO
```

Convert that UTC value to the user's local offset before writing `posted_at`.

## Deleting a draft

Editor header → **More** → **Delete Article** → confirm "Yes, delete". It is
*not* in the draft row's menu in the sidebar, which only offers focus mode and
preview. Drive both clicks by element ref. Deletion is irreversible, so confirm
with the user first.

## Not yet verified

- The **post/thread composer** — only the Articles composer was exercised. Do
  not assume the traps above transfer.
- **Insert → Media** for in-body images, and whether alt text is offered at
  insert time. Only the cover upload was exercised.
- **Insert → Table** and **Insert → LaTeX** — present in the menu, never opened.
- Whether scheduling exists for articles.
