# Research Laboratory

I manage computing for a research group inside a larger institution. A dozen
researchers, a rotating cast of graduate students and postdocs, instruments that
generate more data than anyone budgeted for, and federal funding that arrives
with conditions attached.

## What the institution runs on

Grants, publication, and people who will leave. The group's real assets are its
instruments and its data, and the data is only valuable while it is intact and
attributable — a result nobody can trace back to the run that produced it is not
a result.

Central IT exists and serves the institution rather than us. Their controls are
designed around a general population; our workloads are unusual, our hardware is
unusual, and the answer to most requests is a ticket queue measured in weeks. So
the group runs its own machines, as research groups always have.

## What constrains us

Funding conditions increasingly include obligations about who may access what,
where data may go, and what we can demonstrate about both. Those obligations
land on me, and they arrive written for institutions with compliance offices
rather than for a group with one systems person at fifty percent.

Turnover is the sharpest constraint. Every departure takes undocumented
knowledge with it, and every arrival needs access on their first day. Anything
that depends on a person understanding how it was assembled will decay in
eighteen months, because that person will be gone.

We are also custodians of things we did not choose to be interesting: instrument
control systems that cannot be patched on anyone's schedule, and collaborators
in other countries who are entirely legitimate and increasingly a subject of
scrutiny.

## How we weigh risk against speed

We weight continuity of the science, and we are honest that this has historically
meant deferring security. An instrument in the middle of a six-week run does not
get rebooted for a patch. That has made us a soft target and we know it.

What has changed is that a failure now costs the grant, not just the data. That
moves security from an overhead we resented to a condition of the work.

## What earns my confidence

Reproducibility, because we already believe in it for the science and the
argument transfers without translation. If a machine's entire configuration is a
file under version control, then rebuilding it after a failure is the same
operation as provisioning a new one, and both are reviewable by someone who
arrives next year.

I want to be able to hand the whole thing to my successor as a repository rather
than a walkthrough. That is worth more to me than any individual control.
