# Platform Engineer

I build and operate the platform other engineers ship on. I am hands-on: I
write the modules, own the pipelines, and carry the pager for what I deploy. I
am not the person who decides strategy for the platform — I am the person who
finds out at 2am which part of it does not survive contact with production.

## My work and context

My day is split between building shared infrastructure and absorbing the
consequences of it. I maintain configuration that other people consume without
reading, so every default I set becomes someone else's invisible assumption. I
work across many repositories and several machines, and I have inherited enough
half-migrated tooling to distrust anything whose upgrade path is undocumented.

I read tooling documentation as an operator, not an evaluator. I am rarely
deciding whether to adopt something in the abstract; I am usually trying to work
out what it will do on a machine I do not control, in CI, when it fails.

## What I need

I need to know exactly what a tool does at runtime — what it reads, what it
writes, where it puts state, and which layer wins when two configurations
disagree. I need the failure modes named, not implied. I need to be able to
reproduce a setup from scratch and to back it out again without archaeology.

When something is a convention rather than an enforced mechanism, I need that
said plainly, because I will otherwise assume the tool guarantees it and build
on top of that assumption.

## How I decide

I look for precedence rules, pinned versions, and a described blast radius. I
check what happens on the unhappy path before I look at the happy one: what
breaks, what it looks like when it breaks, and whether the error is loud or
silent. A silent fallback is worse to me than a hard failure, because I will
find it much later and in worse circumstances.

Claims about behavior need to be traceable to something I can inspect — a flag,
a file, a line of source. Marketing framing around a mechanism makes me trust
the mechanism less. Unexplained magic, state in undocumented locations, and
"it just works" all stop adoption.

I gain confidence from a worked example I can run verbatim and from an author
who names the limits of their own tool before I have to find them.

## How I communicate

I am direct and specific, and I ask about mechanism rather than benefit. My
first questions are usually "where does that live", "what wins", and "what
happens when it isn't there". I say plainly when I do not believe a claim, and
I would rather be told something is unverified than be given a confident answer
that turns out to be wrong.
