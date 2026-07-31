# The publisher job

Spec for the scheduled process that acts on `publish_at`. Read before building
or changing a runner. The contract it operates on is in `SKILL.md`; this file
is about execution, failure and safety.

## What it does, in order

Two passes, canonical always first — never interleave them, because the second
depends on the first having succeeded and written back.

**Pass 1 — canonical.** Select publications where
`publish_at <= now AND published == false`. For each: flip `published: true`,
sync to the site repo while preserving frontmatter, push, wait for the deploy to
report success, fetch the resulting URL to confirm it returns 200, then write
that URL to `canonical:`. If failure occurs before the push, restore
`published: false` and stop. If the push may have deployed, stop and reconcile
the observed deployment before writing `canonical` or syndicating.

**Pass 2 — syndication.** Only for publications where `canonical != null`.
Select entries where `entry.publish_at <= now AND entry.posted == null`. For
each: post the draft, capture the resulting URL, write back `posted` and
`posted_at`.

## Required safeguards

These are not optional hardening; each one corresponds to a way this fails
badly.

| Safeguard | Why |
| --- | --- |
| **Kill switch** — a single flag or file that halts everything, checked before each action | A bad draft or a loop must be stoppable without a deploy |
| **Dry run** — prints the exact plan and writes nothing, default for any changed config | The selection query is where mistakes hide |
| **Idempotency** — never act on an entry whose `posted` is non-null | A retried or double-scheduled run must not double-post |
| **Canonical precondition** — re-check `canonical != null` immediately before each syndication action, not once per run | The gate must hold even if pass 1 failed midway |
| **Stop on first error** — do not continue down the list | Partial fan-out with no record is worse than nothing posted |
| **Audit log** — append target, timestamp, resulting URL, and outcome for every attempt | The frontmatter records success; you need the failures too |
| **Rate limiting** — space actions, back off on platform errors | Rapid automated posting is what gets accounts flagged |
| **One writeback per action** — commit `posted`/`posted_at` immediately, not batched at the end | A crash after posting must not lose the URL and cause a repost |

## Writeback protocol

The job edits the same file a human edits, so it must be a careful citizen:

1. Re-read `index.mdx` immediately before writing — never write from a copy
   read at selection time.
2. Modify only the fields it owns: `published`, `canonical`, and each entry's
   `posted` / `posted_at`. Never reflow the body, reorder keys, or rewrite
   fields a human set.
3. Commit per action with a message naming the piece and target.
4. If the vault auto-syncs, `pull --rebase` before writing; on conflict, abort
   and surface it rather than forcing.

## Posting through a browser driver

When a platform has no usable API and the job drives a real composer:

- **Load, verify, submit** — never submit blind. Assert the composer contains
  what you intended before pressing the button.
- **Verify after posting by re-reading the platform, not the page you just
  drove.** A composer's own DOM will happily report success over a document the
  platform saved differently. Fetch the resulting URL and confirm it renders.
- Capture the canonical post URL from the platform's response or the redirect,
  not by constructing it from an ID you guessed.
- Treat a composer that will not load, or content that does not match, as a hard
  failure. Log it and stop the run.
- Per-platform composer mechanics — what an editor strips, how it mangles a
  paste, how to verify — belong in the `social-media` skill's `references/`,
  one file per platform. Don't duplicate them here.

## Authorization

Automated posting acts under the user's identity on accounts they own. It runs
only with their explicit standing authorization, recorded where the pipeline is
configured. If automation conflicts with a platform's terms, it can put the
user's account standing at risk. Keep the kill switch reachable. Automate
publishing to infrastructure you control; keep third-party publishing narrowly
scoped and easy to stop.

## Prerequisites worth checking before building

- A runner actually exists and is reachable on a schedule.
- Credentials for every target are stored as secrets, not in the vault.
- If the vault and the site are on different forges, the job needs a token for
  the destination with permission to push content.
- The site's deploy pipeline reports success in a way the job can observe;
  otherwise "published" means "pushed", which is not the same thing.
