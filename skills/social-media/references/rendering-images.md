# Rendering images for a post

Platform-agnostic. Use when a draft calls for an image the user has not supplied
— a code or diagram card, or a typographic cover. Produce the file yourself
rather than leaving a `<!-- IMAGE -->` note that blocks publication later.

**First ask whether it should be an image at all.** If the target surface has a
native block that holds the content — a code block, a table — use that instead.
An image nobody can select is a downgrade whenever the content is text someone
would paste. See the target's file in `references/` for what it supports; the
answer changes, so check rather than recall.

Images are right for: ASCII diagrams and git graphs, alignment-bearing art,
covers and thumbnails, anything the surface has no block for.

## Toolchain

Headless Chromium renders the HTML, ImageMagick trims it. Both are typically
available; get ImageMagick through Nix when it isn't:

```sh
nix shell nixpkgs#imagemagick --command magick in.png -trim +repage out.png
```

Do not add a screenshot library or a diagram service for this.

## Method

Write an HTML file, screenshot it at `--force-device-scale-factor=2` for a
retina-sharp result, then trim.

```sh
chromium --headless --disable-gpu --hide-scrollbars \
  --default-background-color=00000000 --force-device-scale-factor=2 \
  --window-size=1500,1400 --screenshot=out.png file:///abs/path/card.html
```

Two shapes, and they differ:

- **A content card** (code, diagram) has no fixed size — you don't know how tall
  the content is. Render it as an `inline-block` on a transparent page in an
  oversized window, then trim the transparent margin and add a uniform border
  back:

  ```sh
  magick out.png -trim +repage -bordercolor none -border 40 out.png
  ```

  `--default-background-color=00000000` is what makes the page transparent so
  `-trim` has something to cut. Without it you trim nothing.

- **A cover** has a fixed aspect ratio the platform dictates (5:2 on X). Set
  `--window-size` to exactly that ratio, make the card fill it, and do not trim.

Verify by reading the PNG back before using it. Rendering is the step that
silently produces a blank or clipped image.

## Making it look deliberate

- One dark surface (`#0d1117`), one hairline border (`#21262d`), one radius.
  Reuse the same values across every image in a piece so they read as a set.
- Check `fc-list : family` for what is actually installed before naming a font;
  a missing font falls back silently and ruins the alignment you rendered the
  image to preserve.
- Generous padding — 40–56px inside the card. Cramped code reads as a screenshot
  of a mistake.
- Size type for the feed, not the desktop: ~26px in a card that will be viewed
  at a third of its rendered width.
- A small uppercase header naming the file or command orients the reader. If the
  code's first line is already a `# path/to/file` comment, drop one of the two —
  don't print the same thing twice.
- Syntax highlighting: a few regex passes over escaped HTML is enough. Comments
  muted, keywords one accent, strings another. Do not pull in a highlighter
  library for one card.

## Alt text is not optional

Every image gets alt text before the draft is scheduled — see the skill's
boundaries. Write it against the rendered image, describing what it says, not
that it is a screenshot. Record it in the draft file next to the filename so it
survives to whoever loads the composer.

## Record it in the draft

Replace the planning comment with the real filename, pixel dimensions, render
date, and the alt text. A draft that still says "screenshot this from an editor"
after the file exists will get re-rendered by the next agent.
