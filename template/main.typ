// =============================================================================
// truss-report — starter document
//
// This is a minimal example showing every feature. Replace the content with
// your own. The full reference is in the package README on Typst Universe.
// =============================================================================

#import "@preview/truss-report:0.1.0": *

#show: truss-report.with(
  title: "Project Phoenix Architecture Review",
  subtitle: "Evaluation, decisions, and reference design",
  doc-id: "PHX-ARC-001",
  version: "0.1",
  date: datetime(year: 2026, month: 5, day: 12),

  authors: (
    (name: "Alex Rivera",   role: "Lead Architect"),
    (name: "Sam Chen",      role: "Engineer"),
  ),
  reviewers: (
    (name: "Dana Park",     role: "Engineering Director"),
  ),

  organisation: "Acme Corp · Research Division",
  project: "Project Phoenix",
  confidentiality: "internal",  // draft | public | internal | restricted | confidential

  abstract: [
    This document summarises the architecture review for Project Phoenix,
    covering the requirements catalogue, candidate solutions, the weighted
    trade-off matrix, and the resulting design decisions. The reference
    architecture is validated against the in-house staging environment.
  ],

  history: (
    (version: "0.1", date: "2026-05-12",
     changes: "Initial draft.",
     author: "A. Rivera"),
  ),
)

// =============================================================================
= Context

== Problem statement

Project Phoenix needs a structured way to evaluate competing implementation
approaches against documented requirements before committing to a design.

#callout(kind: "insight", title: "Core problem")[
  Decisions have been made informally so far. We need a repeatable framework
  that produces an auditable record of why a given approach was chosen.
]

== Environment

#kv-block(
  title: "Target environment",
  ("Platform",       "Linux containers on a managed Kubernetes cluster"),
  ("Storage",        "Object store + relational database"),
  ("Network",        "Internal VPC with controlled egress"),
  ("Compliance",     "Internal audit baseline"),
)

== Scope

The deliverables are:

+ A consolidated requirements catalogue.
+ A weighted trade-off matrix evaluating candidate solutions.
+ Architecture decisions captured as ADRs.
+ A validated reference design.

#callout(kind: "warning", title: "Out of scope")[
  This document does not cover roll-out planning or operational hand-over.
]

// =============================================================================
= Requirements

The requirements use category prefixes to group concerns. Colors are passed
explicitly per requirement — there's no hard-coded taxonomy, so use whatever
naming convention fits your project.

#req(
  id: "FUN-001",
  title: "Standards compliance",
  priority: "MUST",
  category-color: rgb("#0073CF"),  // functional → blue
  rationale: [Interoperability with all current consumers requires conformance
              to the relevant industry standard.],
  verification: "Inspection of artefacts against the published specification.",
  source: "Consumer projects; industry baseline.",
)[
  The system #strong[shall] produce outputs compliant with the relevant
  industry standard, as profiled in the project specification.
]

#req(
  id: "SEC-006",
  title: "Cryptographic baseline",
  priority: "MUST",
  category-color: rgb("#C62828"),  // security → red
  rationale: [Mandated by the corporate security policy.],
  verification: "Cryptographic configuration review.",
  source: "Corporate security policy.",
)[
  All cryptographic operations #strong[shall] use parameters meeting
  the minimum strength defined by the corporate security policy.
]

#req(
  id: "OPS-008",
  title: "Daily throughput capacity",
  priority: "SHOULD",
  category-color: rgb("#2E7D32"),  // operations → green
  rationale: [Sized from projected workload plus 50% headroom.],
  verification: "Sustained 24-hour load test at target throughput.",
  source: "Aggregated demand estimate.",
)[
  The system #strong[should] handle at least 1000 requests per day.
]

#req(
  id: "GOV-011",
  title: "Audit evidence trail",
  priority: "MUST",
  category-color: rgb("#7B1FA2"),  // governance → purple
  rationale: [Audit-readiness requires immutable, attributable records.],
  verification: "Review audit data for completeness and traceability.",
  source: "Corporate audit baseline.",
)[
  The system #strong[shall] provide an evidence trail capturing all
  lifecycle, administrative, and configuration-change events.
]

// =============================================================================
= Trade-off matrix

The matrix scores each candidate from 1 to 5 per criterion, then computes
a weighted total. The full scoring rationale is in the annexes.

#landscape[
  #text(size: 18pt, fill: rgb("#1F4E5F"), weight: "bold")[Candidate scoring summary]
  #v(0.5em)
  #line(length: 100%, stroke: 1pt + rgb("#1F4E5F"))
  #v(1em)

  #table(
    columns: (1.5fr, 0.8fr, 0.8fr, 0.8fr, 0.8fr, 0.8fr, 1fr),
    align: (left, center, center, center, center, center, center),
    table.header[Candidate][Functional][Security][Operations][Governance][Cost][Weighted],
    [Option A], score(5), score(4), score(3), score(4), score(4), [#strong[4.00]],
    [Option B], score(4), score(4), score(5), score(3), score(5), [#strong[4.15]],
    [Option C], score(3), score(5), score(4), score(4), score(3), [#strong[3.80]],
    [Option D], score(2), score(3), score(3), score(2), score(5), [#strong[2.90]],
  )

  #v(1em)
  #text(size: 8pt)[
    Scoring: 1 = inadequate, 3 = adequate with caveats, 5 = strong native
    support. Weighted total uses the criterion weights defined in §2.
  ]
]

// =============================================================================
= Architecture decisions

#adr(
  id: "ADR-001",
  title: "Adopt Option B as the reference design",
  status: "Proposed",
  date: datetime(year: 2026, month: 5, day: 12),
  ctx: [
    Option B scored highest on the weighted matrix, driven primarily by its
    operations and cost profile. It trades some governance maturity for
    significant operational savings.
  ],
  decision: [
    Option B becomes the reference design for Project Phoenix. The governance
    gap is addressed by adding a complementary tooling layer (see ADR-002).
  ],
  consequences: [
    Team must invest in operator training for Option B. Two extra weeks of
    schedule needed to integrate the governance tooling. Existing prototypes
    based on Option A are deprecated.
  ],
)

// =============================================================================
= Validation

The reference design is validated against the in-house staging environment.

#callout(kind: "todo", title: "Outstanding items")[
  - Stress-test sustained throughput against the SHOULD target.
  - Schedule architect review of ADR-001.
  - Document the governance tooling integration (ADR-002 pending).
]

#callout(kind: "risk", title: "Open risk")[
  No production-equivalent dataset is available for the validation run.
  Synthetic data may not exercise corner cases that real traffic would.
]
