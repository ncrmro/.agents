# Claiming and setting up an account

**verified: 2026-08-04** — **not yet exercised.** Nothing below has been driven
against a live signup. It is the plan and the known structure of these flows;
stamp it verified per platform as each one is actually done, and correct
whatever turns out to be wrong. Treat every step here as a hypothesis until it
has a date on it.

Run this in **Claude in Chrome**, against the user's real session. An isolated
Playwright context creates the account against a throwaway profile and a
credential store the user does not have — which is worse than not creating it,
because the name is now gone.

**But a logged-in browser often cannot reach a signup form at all.** Instagram's
`/accounts/emailsignup/` redirects to the feed when a session exists, and its
account switcher offers a *login* modal, not a create option. So the two
contexts fail in opposite directions: the visible browser cannot reach the form,
and the isolated one can reach it but is invisible to the user and holds none of
their credentials.

Do not resolve this by filling the isolated form and telling the user it is
"open" — they cannot see a headless context, and the step that remains is
exactly the one only they can do. **Use isolation to check; hand the user a
visible browser to create.** Give them the field values and the route:

1. the platform's **mobile app**, which usually offers "add account → create
   new account" with the existing session intact;
2. a **private/incognito window**;
3. logging out, signing up, and logging back in.

## Before the first submit

Registration is outward-facing and effectively permanent. Most platforms will
not free a released handle, and several never allow a rename.

1. **Show the user the exact strings** and get a yes: handle, display name, bio,
   link, and which email the account is registered to. Approval for one platform
   is not approval for the set.
2. **Check the whole set first.** Claim the platforms in one pass after every
   candidate is verified everywhere, not one at a time as you check. Claiming X
   before discovering Instagram is taken leaves a split identity you cannot
   undo.
3. **Claim the domain-anchored one first** — Bluesky by DNS, or the Mastodon
   instance. It cannot be lost, it is the cheapest, and it validates the domain
   is really yours before you spend names elsewhere.
4. **Prefer an existing identity over a new credential.** A YouTube channel from
   the user's Google account, an Instagram from Meta Business, a LinkedIn page
   from their profile — each avoids inventing a password, a recovery path, and a
   2FA seed that then has to live somewhere.

## Credentials

- The **user** creates and stores the credential. Ask them to generate it in
  their password manager.
- Never type a password you invented, never read one back into the transcript,
  and never write one, a token, a recovery code or a TOTP seed into any file.
- Record only the **entry name** in `credentials:` — e.g.
  `credentials: "1Password: Artera / Bluesky"`.
- If a flow demands a password mid-run and none is available, stop and ask.
  Do not improvise one to "fix later"; a password that only exists in a
  transcript is lost the moment the session ends.

## Phone verification is the real bottleneck

Handle availability is rarely what stops a brand set. **Phone numbers are**, and
they are worth planning before the first claim rather than discovering at the
third:

- A number is **single-use per platform**. The user's personal number is usually
  already bound to their personal account, so a brand account needs a *second*
  number — and one number cannot cover the set on platforms that each demand
  their own.
- **VoIP and virtual numbers are frequently refused — but try anyway.** Google
  Voice, Twilio and the like are rejected by several platforms, and TikTok is
  commonly reported among them. On 2026-08-04 a Google Voice number was
  **accepted** by TikTok. Reputation about which platforms refuse VoIP is stale
  and contradictory; spend the five minutes testing rather than routing around
  a wall that may not be there.
- The number becomes a **permanent recovery factor**. A number that lapses, or
  belongs to someone who leaves, is how an account is lost years later. It
  belongs in the password-manager entry beside the credential.

Record the blockage in the registry as what it is — `unverified` with a note
that the handle is open and the *account* is gated. A platform blocked on
verification is not a platform whose name was taken, and conflating the two
sends someone back to re-check a handle that was never the problem.

Where a platform is gated behind a number the user does not want to spend, say
so plainly: leaving it unclaimed is a legitimate outcome, and there is no
workaround worth pursuing.

## The human-only steps

Stop and hand these over. They are not obstacles to route around:

| Step | Why it is theirs |
| --- | --- |
| CAPTCHA / "are you human" | Defeating it is out of bounds. Ask them to solve it in the visible window. |
| Email confirmation code | The inbox is theirs. |
| SMS / phone verification | The phone is theirs, and the number becomes a permanent recovery factor. |
| 2FA enrolment | The seed must land in their password manager, never in a transcript. |
| ID or business verification | Identity documents are never an agent's to handle. |
| Payment (LinkedIn ads, verification badges) | Always explicit, always theirs. |

**Never attempt to defeat an anti-automation check.** If a flow challenges the
session, stop and report it. A registration completed by evading a challenge is
one the platform may reverse anyway, and the handle is then burned.

## A derived surface is reserved, not claimed

Where one account issues another's handle, creating the first **reserves** the
second and no more. Verified 2026-08-04: an Instagram account at
`arteraspace.co` existed and rendered, while `threads.com/@arteraspace.co`
redirected to a login page — and a control, `@zuck`, rendered fine logged-out.
The Threads profile had to be opted into separately.

Record that state as `reserved`, not `owned`: the name is held for you and
nobody else can take it, but nothing exists on the surface and nothing can be
posted there. Telling the user a derived surface "follows automatically" is
wrong and leaves a channel they think they have.

Check the derived surface with its own control — a profile you know exists — so
an authwall is not mistaken for an absence.

## Setup is part of claiming

An account claimed and left blank is worse than no account: it reads as
abandoned, it gives a reader nowhere to go, and it is the state most of these
registries rot into. Finish the profile in the same session:

- **Display name** — the entity name as written everywhere else. **A new account
  never has the right one, and the handle does not set it.** Two defaults, both
  observed on 2026-08-04:

  | Platform | Defaulted to | Reads as |
  | --- | --- | --- |
  | YouTube | the Google account's name — "Nicholas Romero" | the founder's personal channel |
  | TikTok | the handle — "artera_space" | an unfinished bot account |

  Neither is what a brand wants and both are public from the moment of
  creation. Set the display name in the same session as the claim, and verify
  it by **reloading the live page**, not by trusting the settings form.
- **Bio** — trimmed from the one-line bio in the registry's Identity section, to
  the platform's limit. It is a trim, not a rewrite; the identity line is the
  source.
- **Link** — the canonical URL. Every profile points home; that is what makes
  the set an identity rather than a list.
- **Avatar and banner** — from the assets named in the registry. A default
  avatar is the single strongest "this is abandoned" signal.
- **Platform extras** — the pinned post, the category, the location, the channel
  description. Fill what is free to fill.

Then verify by **reloading the profile and reading the live page**, not by
trusting the form's success state. A settings form will report saved over a
value the platform normalized, truncated, or rejected.

### A cleared Save button is not evidence

**verified: 2026-08-07, LinkedIn company page.** A settings form can fail with
no error at all. Observed end to end: the field accepted 1,354 characters, the
counter updated, the Save button and its Discard sibling both disappeared as
they do on success — and the value never persisted. Two full rounds of logo and
description were lost this way, each looking successful in the form.

The cause was a **server-side concurrency lock**: another admin session held the
page. Its only tell was a toast that auto-dismisses —

> Another admin is trying to make changes to this page at the same time as you.

Image uploads failed differently under the same lock (`Cover image upload
failed. Please refresh the page and try again`) and repeated indefinitely.

Two rules follow, and they generalize past LinkedIn:

- **Read the value back off the public page after every save**, not off the
  form. Where the platform redirects admins to a dashboard, force the member
  view (LinkedIn: `?viewAsMember=true`).
- **A save that silently no-ops is a signal, not a flake.** Stop and find the
  other session. Retrying under a lock cost far more time here than waiting
  would have, and each retry looked like it had worked.

Learn what the platform's *real* success signal is. On LinkedIn it is the
"Share your page edits" prompt offering to announce the change — decline it
unless a post is intended, but its absence means the save did not land. That
signal earned its keep on 2026-08-07: a save produced no prompt and no error,
and the live page still held the old text.

**Clicking Save by element reference is not reliable.** In that same failure the
button was scrolled out of the viewport; a ref-targeted click reported success
and did nothing. Scrolling the form to the top and clicking the button's
on-screen position worked immediately. Put the control in view before clicking
it, and treat "the click was reported" as weaker evidence than "the page
changed".

### Uploading an avatar or banner

- **Never click a file input.** It opens a native OS picker that no automation
  can see or dismiss, and it blocks every subsequent browser event. Put the file
  on the input element directly.
- **The input may not exist yet.** LinkedIn keeps the logo input in the DOM
  permanently but creates the cover input only when the *Add/Edit cover image*
  menu item is clicked — and only by a **real mouse click**; a scripted
  `.click()` on that item does nothing at all. If a menu item must be clicked
  and you fear it triggers a picker, patch `HTMLInputElement.prototype.click` to
  a no-op for `type=file` first, then restore it.
- **Expect a crop step, and expect it to need an explicit *Apply*.** Which
  uploads crop is per-platform and worth checking rather than assuming:
  **verified 2026-08-07, X** — the *Edit profile* modal cropped **both** the
  header and the avatar, each with its own *Apply*.
- **Element refs go stale between two uploads in one dialog.** X re-renders the
  modal after the first *Apply*, so a ref captured for the avatar input before
  the header was applied no longer resolves. Re-run `find` for the second input
  instead of reusing a ref from the same call.
- **Platforms overlay the avatar tile on the banner.** LinkedIn covers roughly
  the first 23% of the banner's width with the square logo. A banner whose
  content is centred normally loses its opening characters behind it — pad the
  render clear of the tile, and check the composed result on the live page
  rather than admiring the source image.

## Immediately after

1. Write the row back: `status: owned`, `verified:` today, `method: login`,
   `credentials:` the entry name, and the real URL read off the live profile.
2. Record the display casing if it differs from the handle (YouTube shows
   `@ArteraSpace` for a handle registered in any case).
3. Tell the user what remains human-only — 2FA not yet enrolled, avatar not yet
   uploaded, recovery email unset. These are the things that get forgotten and
   they are exactly the things that lose an account.

## Do not

- Register handles the user has no claim to, in bulk, to hold or resell.
- Register a name that impersonates another person or company.
- Create additional accounts so one person appears to be several.
- Delete or rename a live account. Renaming frees the old handle instantly and
  someone else may take it within minutes; it is not reversible.
- Change a bio a human wrote without showing the new text and getting a yes.
