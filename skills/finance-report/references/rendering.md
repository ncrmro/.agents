# Temporary HTML and PDF reports

Use the renderer only after the Markdown report passes the finance verification
checks. The Markdown file remains the canonical report.

## Render

Run this command from any directory:

```sh
~/.agents/skills/finance-report/scripts/render-report.sh PATH/TO/REPORT.md
```

The renderer creates a directory under the system temporary directory. It
prints these paths:

- temporary directory;
- self-contained HTML report;
- PDF report.

The renderer uses Pandoc to create HTML. It embeds the report CSS in the HTML.
It uses WeasyPrint to create the PDF from that HTML.

## Privacy

- The renderer sets a private process file mask before it creates files.
- Treat the HTML and PDF files as sensitive financial data.
- Do not open the report in a remote browser service.
- Do not attach or publish the report unless the user explicitly asks.
- Do not put temporary report paths in durable notes.
- Remove the temporary directory after the user finishes the review.

Do not remove the directory before the user can open the files. A temporary
directory can survive until the operating system removes it.

## Verification

Check all of these items:

1. The HTML file exists and is not empty.
2. The PDF file exists and is not empty.
3. The HTML contains the report title and all required section headings.
4. The PDF opens and contains at least one page.
5. Tables do not lose columns at page boundaries.
6. Coverage and reconciliation warnings remain visible.
7. Currency values match the Markdown report.

If the PDF layout is wrong, change `assets/report.css`. Do not edit the generated
HTML or PDF by hand.

## Dependencies

The renderer requires these commands:

- `pandoc`
- `weasyprint`
- `mktemp`

The renderer stops with exit code 127 when a command is absent. Follow the Nix
installation hint in the error message. Run the renderer again after the
installation.
