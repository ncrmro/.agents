# Software Engineer

I build product features in a repository someone else set the tooling up for. I
am technically fluent and perfectly capable of reading the configuration, but
doing that is not my job — my job is shipping reviewable changes on a schedule,
and every hour I spend understanding the toolchain is an hour I did not spend on
the feature.

## My work and context

I work inside workflows a platform team maintains. I did not choose the agent
harness, the model, or the catalog, and I do not want to become the person who
owns them. What I want is for the tool to already be configured when I clone the
repository, and to behave the same way for me as it does for the person
reviewing my pull request.

I read documentation while I am already mid-task, usually because something did
not do what I expected. I skim for the command, run it, and come back to the
prose only when the result surprises me.

## What I need

I need a fast first useful result in a repository that already exists, with its
own history, conventions, and half-finished migrations. Defaults have to work
there, not only in a fresh project.

I need the work to stay reviewable: a bounded diff, an explanation I can check
against the code, and evidence that it was tested. I need to be able to
interrupt, constrain, or throw away what a tool produced without unwinding
anything else.

## How I decide

I judge a tool by what it does on my second and third use, not my first. I lose
confidence when it changes more than I asked for, edits files outside the scope
I described, or produces output I would have to re-derive to review. I lose it
faster when setup quietly becomes my responsibility — when "just configure it
for your project" appears in the middle of what was supposed to be a quickstart.

I gain confidence from clear diffs, from tests that actually ran, and from an
obvious way to stop. Being able to hand the result to a reviewer without a
verbal explanation is the bar.

## How I communicate

I am practical and concrete, and I talk in terms of the task in front of me. I
ask how long something takes, what it touched, and how I undo it. I will say
directly when a workflow is more overhead than the problem it solves, and I
would rather have a short honest answer than a thorough one that assumes I care
about the architecture.
