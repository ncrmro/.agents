# Resume source convention

Use this layout below the personal repository root:

```text
docs/personal/resumes/
├── README.md
├── profile.md
├── work-history/
│   ├── README.md
│   └── YYYY-MM-organization-role.md
├── projects/
│   ├── README.md
│   └── project-slug.md
├── variants/
│   ├── README.md
│   └── variant-slug.md
├── targets/
│   ├── README.md
│   └── target-slug.md
└── exports/
    └── README.md
```

The Markdown files are canonical. `exports/` contains generated snapshots, not
hand-edited source.

## Visibility

Every profile field, role, project, and claim uses one of:

| value | meaning |
| --- | --- |
| `public` | may be published on the website and public resumes |
| `resume-only` | may appear in a directly shared resume, but not on the website |
| `private` | source context only; never render or publish |

The most restrictive applicable visibility wins. A public variant cannot make
a private canonical claim public.

## Profile

`profile.md` owns current identity and contact fields:

```yaml
---
name: Example Person
headline: Platform engineer
location: City, Region
email:
  value: person@example.com
  visibility: resume-only
links:
  - label: Website
    url: https://example.com
    visibility: public
summaries:
  general: >
    Evidence-backed general summary.
skills:
  - name: Kubernetes
    visibility: public
last_verified: YYYY-MM-DD
---
```

Do not put a street address, reference contact, or other unnecessary sensitive
data in the public profile.

## Work history

Use one file per materially distinct role. A promotion or changed employment
relationship gets a new record when it changes the dates, title, or claims.

```yaml
---
id: role-example-platform-engineer
organization: Example
title: Platform Engineer
employment_type: employee
location: Remote
start: YYYY-MM
end:
visibility: public
status: verified
last_verified: YYYY-MM-DD
sources:
  - label: Employment record
    ref: private record; do not publish
---

## Context

Private working context that helps interpret the role.

## Claims

### claim-example-platform-migration

- visibility: public
- status: verified
- tags: [platform, migration, kubernetes]
- evidence: public case study or a private provenance note

Led a supported, accurately scoped platform-migration outcome.
```

Stable IDs are lowercase kebab-case. Do not encode wording, dates, or ordering
in an ID. Once referenced by a variant, rename an ID only while updating all
references in the same change.

Allowed verification states:

- `verified` — supported by a source or explicitly confirmed by the user;
- `needs-verification` — plausible but not yet safe to present as fact;
- `retired` — preserved for history but no longer selected.

## Projects

Project records use the same claim structure as work history:

```yaml
---
id: project-example
name: Example project
url: https://example.com
start: YYYY-MM
end:
visibility: public
status: verified
last_verified: YYYY-MM-DD
---
```

Record the person's contribution, not merely what the project does.

## Variants

Each `variants/<slug>.md` is a composition manifest:

```yaml
---
id: platform-engineer
title: Platform Engineer
audience: General platform-engineering roles
visibility: resume-only
summary_key: general
roles:
  - id: role-example-platform-engineer
    claims:
      - claim-example-platform-migration
projects:
  - id: project-example
    claims:
      - claim-example-project-result
skills: [Kubernetes, Terraform]
last_reviewed: YYYY-MM-DD
---
```

Optional body text records target-specific notes and supported phrasing
decisions. It is not a second store for career facts.

Use one durable general variant and separate named variants for distinct role
families. For a one-off application, create a dated or employer-role variant
only when the selection or wording materially differs; link it to the owning
application record.

## Targets

Each `targets/<slug>.md` records a publication adapter:

```yaml
---
id: personal-website
kind: website
variant: public-web
repository: <path or repository identifier>
destination: <content or route location>
visibility: public
last_published:
source_revision:
---
```

The body documents the target's schema, validation command, deployment
boundary, and any field mapping that cannot be inferred.

## Exports

Store generated snapshots as:

```text
exports/<variant>/<YYYY-MM-DD>/<descriptive-name>.pdf
```

If generated artifacts are large, ignored, or managed by Git LFS, document that
policy in `exports/README.md`. Never edit an export to fix content; fix the
canonical record or variant and regenerate it.
