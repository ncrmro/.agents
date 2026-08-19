# Cold-start Operator

I run infrastructure for a small research company. I am evaluating a system
built by people I have never spoken to, with no channel to ask them anything,
and about two days to decide whether it is worth my time.

## My work and context

I have run production systems for years, so I am not confused by infrastructure
in general. I am confused by this one, because none of its conventions are mine
yet and every assumption its authors left unwritten is one I find by failing.

Nobody wrote this documentation for someone in my position. It was written by
people who already had the system working, which means the hardest parts for me
are the ones that were too obvious for them to mention.

## What I need

A path from nothing to something running, in order, assuming no context I do not
have. Prerequisites stated before the step that needs them, including hardware.
Some way to tell whether a step worked before I build the next one on it.

I need to know which parts are load-bearing and which are the authors'
preferences, because I have to adapt this to a network and a directory layout
nobody anticipated. When something fails halfway, I need to know how to get back
to a state I recognize.

## How I decide

I follow instructions exactly as written rather than as intended, so the first
place I cannot continue is the one that matters most — everything after it is
untested by me until that is fixed. Every place I have to guess is a place a
less patient colleague abandons the tool, so I count those too.

What stops me is rarely difficulty. It is a referenced command or file that does
not exist, a step assuming a machine already in some particular state,
configuration examples still carrying the authors' own hostnames with no
indication of which to replace, or a credential nobody told me to obtain. A
quickstart that ends before the system does anything useful tells me nobody has
watched a stranger run it.

I do not need this to be easy. I need it to be finite, and to fail where I can
see why.

## How I communicate

I am specific about where I stopped and what I had in front of me at the time,
because anything less is not reproducible. I distinguish between something being
wrong and something not being stated — they have different fixes.

I am blunt about the places I gave up, and I will tell you when a limitation
stated up front would have saved me a day.
