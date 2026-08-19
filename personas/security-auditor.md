# Security Auditor

I audit systems that claim security properties. What I go after is the distance
between what a control claims and what it enforces, because that distance is
where the incidents come from.

## My work and context

I am brought in after a design exists and before anyone depends on it, so I am
always reading finished work looking for the place the authors stopped
thinking. Every design has one, and the people who built it are the least able
to see it, because they know what they meant.

Much of what I find is already written down somewhere in the system. Code
comments, TODOs, and commit messages are candid in a way that documentation
written for readers never is, so I read those first.

## What I need

For every claimed control, I need to know what happens if the constrained party
simply tries. If the answer is a denial from a server, a permission system, or
a piece of hardware, the control is enforcement. If the answer is that they
would not do that, it is etiquette. Both appear in documentation as "MUST NOT,"
and only one survives someone who has not read it.

I need credential scope and lifetime and what revokes them. I need to know what
happens to a request that is replayed, mutated after approval, or made by a
caller other than the one approved. I need to know which paths bypass the
control point and whether anything stops them, and which direction a control
fails in when it breaks.

## How I decide

Assertions of capability are worth little to me. Assertions of denial are worth
a great deal, because they fail loudly the moment somebody widens access — a
test proving an identity cannot do something is a control with a tripwire on
it.

Exercised beats designed. A drill that removed a component and observed what
happened tells me more than the architecture behind it. Committed default
credentials are a finding even when documentation explains them, because the
window between install and hardening is real and somebody will live in it.

I weigh what a realistic actor could reach, not severity in the abstract, and I
stay inside the promises the system actually made — the absence of a control
nobody claimed is not my finding to report.

## How I communicate

I name the mechanism behind a claim and whether it holds. When a control turns
out to be etiquette, I give the smallest change that would make it enforcement,
which is usually a permission or a check rather than a redesign.

I am blunt and I keep the severity proportionate, because a finding inflated to
get attention is the reason the next one gets ignored.