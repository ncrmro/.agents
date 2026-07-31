# Source capture

Capture each web source in a citable package. Create one directory per source as
soon as you decide to cite it.

```text
~/notes/wiki/sources/YYYY-MM-DD-<slug>/
├── source.md          # the note — always present, even if capture failed
├── <original>.html    # immutable original bytes, descriptive name
├── content.md         # searchable extracted text
└── figures/
```

The directory date is the **artifact's own** publication or recording date, not
the day you fetched it. Undated web pages: use the date on the page (last
updated, release date, commit date); only fall back to the retrieval date when
the artifact genuinely has none, and say so in `source.md`.

## Toolchain

Available on this machine: `curl`, `docling`, `pandoc`, `jq`, `sha256sum`,
`rg`, `fd`, `git-lfs`. Not installed: `monolith`, `wget`, `trafilatura`,
`pdftotext`, `yt-dlp` — reach for `nix run nixpkgs#<pkg>` rather than installing
globally.

### HTML page

`SKILL.md` step 3 has the copy-paste recipe (`curl` → `sha256sum` → `docling`).
Three things it doesn't say:

- `docling convert` writes `<stem>.<ext>` into the `--output` **directory**,
  which is why the recipe renames to `content.md` afterwards.
- `pandoc -f html -t gfm -o content.md page.html` is the lighter fallback. It
  keeps more page chrome but never chokes on an odd document.
- Multiple pages of one document → one directory, one `content.md` assembled
  from them, and every original hashed in the Integrity table.

### PDF / paper

```sh
curl -sSL -o "$S/paper.pdf" 'https://…/paper.pdf'
sha256sum "$S/paper.pdf"
docling convert --to md --output "$S" "$S/paper.pdf"   # add --ocr for scans
mv "$S/paper.md" "$S/content.md"
```

`*.pdf` is already a Git LFS pattern in the vault's `.gitattributes`, as are all
image, audio, and video extensions. Confirm with `git check-attr filter -- <file>`
before committing anything large under a new extension.

### Repository as a source

Code is a primary source, and the citable unit is a **commit**, not a branch.

```sh
git -C ~/repos/<owner>/<repo> rev-parse HEAD
git -C ~/repos/<owner>/<repo> log -1 --format='%H %ad %s' --date=short
```

Record the remote URL, the commit SHA, and the paths you actually read in
`source.md` provenance; put quoted excerpts in `content.md`. Don't archive the
whole tree.

### API / JSON evidence

```sh
curl -sS 'https://git.ncrmro.com/api/v1/version' | jq . > "$S/instance-version.json"
sha256sum "$S/instance-version.json"
```

Version endpoints are the cheapest way to tie an analysis to a real deployment —
capture one whenever the claim is about a specific running instance.

### JS-rendered pages

Use the browser MCP (`browser-mcp` skill) to reach the content, then still
capture something durable — page HTML via the tooling, a screenshot into
`figures/`, or the relevant text quoted verbatim in `content.md` with a note in
provenance that it was captured through a browser session rather than a raw
fetch.

### Audio / video

The `media-editor` skill owns transcription and diarization. Bring back
`transcript.md` as the searchable representation, keep the original media file
(LFS) in the directory, and keep the raw extractor output (`.json`, `.srt`,
`.vtt`) beside it — the existing `wiki/sources/` packages in this vault do
exactly that.

## Integrity table

Hash every immutable original. It is what lets a future reader prove the file
beside the note is the one the note describes.

```sh
sha256sum "$S"/*.html "$S"/*.pdf "$S"/*.json 2>/dev/null
```

```md
## Integrity

| File | SHA-256 |
| --- | --- |
| `forgejo-v15-actions-reference.html` | `e357c0cf…` |
```

## When capture fails

Paywalls, login walls, live dashboards, and rate limits are normal. You are not
required to capture everything; you are required to **never cite as captured
what isn't**.

- **Paywalled or login-gated** — capture the abstract or landing page, cite the
  bibliographic record, and state in `## Evidence limits` that the full text was
  not read. Never restate a paywalled claim as if you verified it.
- **Live dashboard or query result** — capture the query and its output as JSON
  or a screenshot with the timestamp; the source is *"this query, at this time"*,
  and the evidence limits say it does not generalize.
- **Robots-blocked or 403** — record the attempt and the status code in
  provenance, and either find a mirror/primary equivalent or downgrade the claim.
- **Nothing retrievable at all** — you may still write `source.md` as a
  bibliographic record with `status: stub`, an empty Integrity table, and
  evidence limits saying the artifact was not obtained. What you may not do is
  cite it as if it had been.

## Checklist before committing a source

- [ ] `source.md` exists, with `type: source`, `source_kind`, and 2–5 material
      tags reused from `wiki/tags.md` (new tags added there in the same commit)
- [ ] Provenance names the URL, retrieval date, version, and retrieval method
- [ ] Integrity table hashes every immutable original present
- [ ] `content.md` / `transcript.md` present when the original isn't already text
- [ ] `## Evidence limits` states what the source does **not** establish
- [ ] `## Related notes` links back into concepts / research / projects
- [ ] Original artifact unmodified since capture
- [ ] Large binaries tracked by LFS (`git check-attr filter -- <file>`)
- [ ] `wiki/index.md` entry and `wiki/log.md` line added in the same run
