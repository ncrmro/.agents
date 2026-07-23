#!/usr/bin/env python3
"""Split the vendored signs-of-ai-writing.md into cleaned per-topic files.

Strips wiki chrome: links (kept as plain text), images, footnote markers,
shortcut boxes, and banner tables.
"""
import re
from pathlib import Path

SRC = Path(__file__).resolve().parent.parent / "references/signs-of-ai-writing.md"
OUT_DIR = SRC.parent

text = SRC.read_text()

# Work only on the article body (skip our local attribution header).
body_start = text.index("## Caveats")
body = text[body_start:]

# --- line-level removals (before unlinking, patterns are recognizable) ---
lines = body.splitlines()
kept = []
skip_table = False
for ln in lines:
    stripped = ln.strip()
    # shortcut boxes: a "[Shortcut](...)" line and its "* [WP:XXX..." bullets
    if re.fullmatch(r"\[Shortcuts?\]\([^)]*\)", stripped):
        continue
    if stripped.startswith("* [WP:") or stripped.startswith("* [MOS:"):
        continue
    # images / image-wrapped links
    if stripped.startswith("[![") or stripped.startswith("!["):
        continue
    # banner/nav tables: any table row containing wiki-namespace furniture
    if stripped.startswith("|") and re.search(
        r"WikiProject|Template%3A|Special%3A|AI or not quiz|advice page", stripped
    ):
        continue
    # table separator rows orphaned by the above are cleaned later
    kept.append(ln)
body = "\n".join(kept)

# --- inline cleanups ---
# footnote refs: [[1]](...), [[a]](...), possibly escaped \[
body = re.sub(r"\[\\?\[[^\]\\]+\\?\]\]\([^)]*\)", "", body)
# markdown links -> plain text; URL has no spaces/parens, optional quoted title
for _ in range(3):  # a few passes for nested link-ish structures
    body = re.sub(r"\[([^\][]*)\]\([^\s)]*(?:\s+\"[^\"]*\")?\)", r"\1", body)
# "Words to watch" notice boxes: 2-col table with an empty first cell
body = re.sub(
    r"\|\s*\|\s*\|\n\|\s*---\s*\|\s*---\s*\|\n\|\s*\|\s*(.*?)\s*\|",
    r"> \1",
    body,
)

# hatnotes pointing at other wiki pages (links already stripped to plain text)
body = re.sub(
    r"^(See also:|Further information:|For non.AI.specific guidance|"
    r"For a non.AI.specific style essay|Main pages?:).*\n?",
    "",
    body,
    flags=re.M,
)

# embedded reference lists ("References" + "1. ↑ ..." lines)
body = re.sub(r"^References\n+(?:\d+\.\s*↑.*\n?)+", "", body, flags=re.M)

# wiki search-link blocks ("Links to searches" + insource bullets)
body = re.sub(
    r"^\*{0,2}Links to searches\*{0,2}\n+(?:\*\s+.*(?:insource|Special%3ASearch).*\n?)+",
    "",
    body,
    flags=re.M,
)

# single-cell example tables -> blockquotes; "| From this ... |" caption rows
# -> attribution lines; drop "| --- |" separators. Multi-column tables (real
# table examples, diff tables) are left alone.
out_lines = []
for ln in body.splitlines():
    s = ln.strip()
    m = re.fullmatch(r"\|\s*(.*?)\s*\|", s)
    if m and s.count("|") == 2:
        cell = m.group(1)
        if re.fullmatch(r"-+", cell):
            continue
        if not cell:
            continue
        if re.match(r"From (this|Draft|the )", cell):
            out_lines.append(f"— {cell}:")
        else:
            out_lines.append(f"> {cell}")
        continue
    out_lines.append(ln)
body = "\n".join(out_lines)

# stray wikitext template closers (after table unwrapping so $ matches)
body = re.sub(r"\s*\}\}\s*$", "", body, flags=re.M)

# orphaned color-legend labels from the lexical-diversity example
for orphan in ("Soviet artistic constraints", "Non-conformist artists", "Their creativity"):
    body = re.sub(rf"^{re.escape(orphan)}\n?", "", body, flags=re.M)

# collapse 3+ blank lines
body = re.sub(r"\n{3,}", "\n\n", body)

# --- split on top-level "## " sections ---
sections = {}
cur = None
buf = []
for ln in body.splitlines():
    if ln.startswith("## "):
        if cur:
            sections[cur] = "\n".join(buf).strip()
        cur = ln[3:].strip()
        buf = []
    else:
        buf.append(ln)
if cur:
    sections[cur] = "\n".join(buf).strip()

ATTR = (
    "> Derived from [Wikipedia:Signs of AI writing]"
    "(https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) "
    "(CC BY-SA 4.0), retrieved 2026-07-23; wiki links, citations, and page "
    "furniture stripped for reviewer-agent use. The full vendored copy with "
    "provenance is `signs-of-ai-writing.md`.\n"
)

OUT = {
    "content-tells.md": (
        "AI-writing tells: content and substance",
        "Patterns in *what the text says* — inflated significance, promotional "
        "framing, vague sourcing, hollow analysis. These are the highest-value "
        "tells because fixing them requires real rewriting, not word swaps.",
        ["Content"],
    ),
    "language-tells.md": (
        "AI-writing tells: language and grammar",
        "Patterns in *word choice and sentence structure* — AI vocabulary, "
        "negative parallelisms, rule-of-three padding, elegant variation.",
        ["Language and grammar"],
    ),
    "style-tells.md": (
        "AI-writing tells: style and formatting",
        "Patterns in *presentation* — title case, boldface and em-dash overuse, "
        "emoji headers, list and table misuse, curly quotes.",
        ["Style"],
    ),
    "communication-tells.md": (
        "AI-writing tells: chatbot remnants",
        "Text that leaked from the chat session into the deliverable — "
        "collaborative filler, knowledge-cutoff disclaimers, placeholders, and "
        "model-specific citation artifacts.",
        ["Communication intended for the user"],
    ),
}

ARTIFACTS_APPENDIX = """
### Leftover machine artifacts (grep for these)

Distilled from the guide's Markup section: literal strings that chatbots emit
as citation/formatting internals. Any hit is near-certain evidence of pasted,
unreviewed AI output.

- ChatGPT: `contentReference`, `oaicite`, `oai_citation`, `turn0search`,
  `turn0news`, `attributableIndex`, stray `+1` after source names
- Gemini: `[cite: 1]`, `span_1`, `start_span`, `end_span`
- Grok: `grok_card`, `grok_render_citation_card_json`
- DeepSeek: lenticular-bracket citations `【 】`, dagger symbols `†` as refs
- Perplexity: `attached_file`, `ppl-ai-file-upload`
- Various: `:::writing` fences, raw `**bold**`/`##` Markdown in a non-Markdown
  medium, `[Insert X here]`-style placeholders
"""

for fname, (title, blurb, wanted) in OUT.items():
    parts = [f"# {title}\n", ATTR, f"\n{blurb}\n"]
    for sec in wanted:
        if sec not in sections:
            raise SystemExit(f"missing section: {sec}")
        parts.append("\n" + sections[sec] + "\n")
    if fname == "communication-tells.md":
        parts.append(ARTIFACTS_APPENDIX)
    (OUT_DIR / fname).write_text("".join(parts))
    print(f"{fname}: {len((OUT_DIR / fname).read_text().splitlines())} lines")
