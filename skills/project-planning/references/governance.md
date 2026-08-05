# Governance stages and milestone iteration

Use this reference when a workstream extends beyond the current session or next
day, affects a user-facing production surface, has competing backlog items, or
needs a milestone scope decision.

## 1. Select the operating stage

The project records a default stage. Each workstream inherits it unless its own
evidence requires a different stage. Select the highest stage whose trigger
applies:

| Stage | Minimum trigger | Required state |
| --- | --- | --- |
| **Explore** | No higher trigger applies; one active path fits inside the current session or next day | A concrete next action and local evidence |
| **Ship** | The work changes or releases a user-facing production surface | Local pre-release evidence and post-release evidence from the deployed surface |
| **Manage** | The plan extends beyond the next day; two or more items compete for the same capacity; or the work needs an explicit milestone | An ordered backlog, one active milestone, current/next/later horizons, and core/stretch/candidate commitments |
| **Program** | Two or more milestones, owners, workstreams, repos, or releases must coordinate | Period outcomes, a milestone sequence, dependency ownership, and a multi-release or per-repo graph |

An owner MAY raise or lower the declared stage when a trigger does not fit the
work. Record the reason beside the stage. A user-facing production release MUST
still meet the Ship verification rules.

## 2. Run the loop for the stage

### Explore

1. State the immediate intent.
2. Make the smallest reversible change.
3. Verify it locally in proportion to risk.
4. Record the result and the next question to answer.
5. Graduate when a higher-stage trigger appears.

### Ship

1. State the user-visible outcome and the release boundary.
2. Verify the change locally before release.
3. Release through the project's normal path.
4. Verify the deployed user surface. A successful build or deployment status
   is insufficient.
5. Record what shipped, the evidence, and any follow-up.

### Manage

1. Gather the forge, plan, and current project state.
2. Define one milestone outcome or primary uncertainty.
3. Classify work by horizon and commitment.
4. Order core work by dependencies, production risk, and whether its result can
   change later work.
5. Execute the lowest core item on the projected graph.
6. Use spare capacity for non-interfering stretch work.
7. Review after the events in section 6 and at least weekly.
8. Close on the core demo; migrate unfinished stretch.

### Program

1. State the period outcomes.
2. Sequence milestones by dependency.
3. Run a milestone earlier when its result can change a later milestone.
4. Keep one graph per repository and share milestone names across them.
5. Assign dependency and release ownership.
6. Review milestone and release state after the events in section 6 and at least
   weekly.

## 3. Classify horizon and commitment

These dimensions are independent:

| Horizon | Meaning |
| --- | --- |
| `current` | Eligible in the active milestone or release |
| `next` | Intended for the next milestone after the current result |
| `later` | Preserved but not scheduled |

| Commitment | Meaning |
| --- | --- |
| `core` | The milestone cannot meet its success criterion without it |
| `stretch` | Non-gating work that uses spare capacity |
| `candidate` | An idea or lead that lacks a committed milestone boundary |

Typical combinations:

- `current/core` — active milestone gate;
- `current/stretch` — assigned to the active forge milestone, but non-gating;
- `next/core` — part of the drafted next milestone;
- `next/stretch` — optional capacity work for the drafted next milestone;
- `later/candidate` — unscheduled backlog.

Do not use commitment as urgency. Within each combination:

1. address safety, security, data-loss, and production-restoration work first;
2. unblock the core critical path;
3. resolve first the uncertainty whose answer can change scope, priority, or
   the next action;
4. order the remaining work by dependency and its expected contribution to the
   milestone outcome.

## 4. Cut a milestone without losing ideas

Write the success criterion and demo first. Then test each item:

1. **Would the milestone fail its success criterion without it?** Keep it as
   `current/core`.
2. **Does it preserve the same outcome or primary uncertainty, interface,
   apparatus, dependency set, and variable axis?**
3. **Can it use spare capacity without delaying core or consuming a constrained
   core dependency?** If both 2 and 3 are true, assign it as
   `current/stretch`.
4. **Does it change the outcome, uncertainty, interface, apparatus, dependency
   set, or variable axis?** Put it in `next`; make it core only when the next
   milestone is drafted.
5. **Does it lack a falsifiable result or enough evidence to schedule?** Keep
   it as `later/candidate`.

Spare capacity is resource-specific: unused human time and attention, an
available agent slot, idle equipment or compute, or calendar time. It is not
spare if it can advance core work now or if its use can delay a later core
dependency.

Assign stretch work to the active forge milestone immediately and mark its
commitment explicitly. Do not treat the forge completion percentage as the
close criterion when core and stretch share a milestone.

Use the forge's scope field when it has one. Otherwise, use `scope/core` and
`scope/stretch` labels. Map horizon from milestone assignment: active means
`current`, next means `next`, and none means `later`. At close, assign
unfinished stretch to the next milestone or remove its assignment for later
review.

At close:

1. verify every core issue is complete;
2. run the declared demo and record its evidence;
3. close the milestone even when stretch remains;
4. move unfinished stretch to `next` or `later`;
5. use the result to rescope the next milestone.

## 5. Control experimental scope

An experimental milestone answers one primary question by varying one
independent variable axis.

Before assigning treatments, record:

- the independent variable and its planned treatments;
- the fixed apparatus and materials;
- the fixed operating protocol and environment;
- the control and replication strategy;
- the measurements and analysis method;
- the allowed deviations and how they will be reported.

Several treatments can share one milestone when only the selected variable
changes. A treatment that changes the apparatus, substrate, control method,
environment, measurement method, or another independent variable belongs in a
different milestone.

If a core run fails, treat the failure as evidence. Do not spend stretch
capacity expanding the experiment until the review decides whether the failure
changes the current success criterion or the next milestone.

## 6. Review on evidence and time

Review immediately after:

- a release or deployed verification;
- an experiment or user-test result;
- a blocker or incident;
- new evidence that changes scope, priority, or the next action;
- a scope, priority, dependency, or capacity change.

At Manage and Program, review at least weekly even when none of those events
occurs.

During the review:

1. recompute the required stage;
2. confirm the core still defines the smallest honest demo;
3. check whether stretch uses spare capacity;
4. promote, demote, or migrate work;
5. redraw the projected graph;
6. synchronize the forge milestone and canonical planning documents.
