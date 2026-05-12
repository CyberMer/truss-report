// =============================================================================
// truss-report — a structured technical report template
// https://github.com/CyberMer/truss-report
// =============================================================================
//
// Designed for engineering and technical reports that need to combine:
//   - Long-form prose with running headers / footers
//   - Structured requirement blocks (any taxonomy)
//   - Architecture Decision Records (ADRs)
//   - Trade-off matrices on landscape pages
//   - Callouts for notes, warnings, risks, decisions
//   - A clean cover page with metadata
//
// All visual styling is exposed at the top of this file. Override by passing
// your own `theme` dictionary to `truss-report.with(...)`.

// -----------------------------------------------------------------------------
// Default theme — override with `theme: (...)` argument to truss-report
// -----------------------------------------------------------------------------

#let default-theme = (
  // Primary brand colors
  primary:    rgb("#1F4E5F"),  // deep teal
  accent:     rgb("#3A9188"),  // brighter teal
  muted:      rgb("#5A5A5A"),

  // Surfaces
  rule:       rgb("#C8C8C8"),
  code-bg:    rgb("#F4F4F6"),
  block-bg:   rgb("#FAFAFC"),

  // Semantic colors (used by callout & score helpers)
  semantic: (
    info:    rgb("#0073CF"),
    success: rgb("#2E7D32"),
    warn:    rgb("#E65100"),
    danger:  rgb("#C62828"),
    purple:  rgb("#7B1FA2"),
    cyan:    rgb("#00838F"),
  ),

  // Fonts — falls back through the list until one is found
  font-body: ("Libertinus Serif", "Linux Libertine", "Times New Roman", "serif"),
  font-sans: ("Libertinus Sans",  "Inter", "Helvetica", "Arial", "sans-serif"),
  font-mono: ("DejaVu Sans Mono", "JetBrains Mono", "Consolas", "monospace"),

  font-size:    10.5pt,
  line-height:  0.65em,
)

// -----------------------------------------------------------------------------
// Default confidentiality labels — pass `confidentiality: "your-key"` and add
// your own entries via `confidentiality-levels` if you need a custom scheme.
// -----------------------------------------------------------------------------

#let default-confidentiality-levels = (
  "draft":        (label: "DRAFT",        color: rgb("#5A5A5A")),
  "public":       (label: "PUBLIC",       color: rgb("#2E7D32")),
  "internal":     (label: "INTERNAL",     color: rgb("#0073CF")),
  "restricted":   (label: "RESTRICTED",   color: rgb("#E65100")),
  "confidential": (label: "CONFIDENTIAL", color: rgb("#C62828")),
)

// =============================================================================
// Main document function
// =============================================================================

#let truss-report(
  // Identity
  title: "Document title",
  subtitle: none,
  doc-id: none,
  version: "0.1",
  date: datetime.today(),

  // People
  authors: (),     // array of (name:, role:, email:) dictionaries
  reviewers: (),   // same shape as authors

  // Classification & branding
  confidentiality: "draft",
  confidentiality-levels: default-confidentiality-levels,
  organisation: none,    // e.g. "Acme Corp · Research Division"
  project: none,         // e.g. "Project Phoenix"

  // Front matter
  abstract: none,
  history: (),      // array of (version:, date:, changes:, author:)

  // Visuals
  theme: (:),       // partial dictionary to override default-theme

  // Page setup
  paper: "a4",
  margin: (top: 3.2cm, bottom: 2.5cm, left: 2.2cm, right: 2.2cm),

  body,
) = {
  // Merge theme overrides on top of defaults
  let t = default-theme
  for (k, v) in theme { t.insert(k, v) }

  let cf = confidentiality-levels.at(confidentiality)

  set document(title: title, author: authors.map(a => a.name))

  // ------------------- Page setup -------------------
  set page(
    paper: paper,
    margin: margin,
    header-ascent: 1.2cm,
    footer-descent: 0.8cm,
    header: context {
      let page-num = here().page()
      if page-num > 1 [
        #grid(
          columns: (1fr, auto),
          align: (left + horizon, right + horizon),
          text(size: 8pt, fill: t.muted)[
            #if doc-id != none [#doc-id · ]v#version · #title
          ],
          box(
            fill: cf.color,
            inset: (x: 6pt, y: 2pt),
            radius: 2pt,
            text(size: 7pt, fill: white, weight: "bold")[#cf.label],
          ),
        )
        #v(2pt)
        #line(length: 100%, stroke: 0.5pt + t.rule)
      ]
    },
    footer: context {
      let page-num = here().page()
      if page-num > 1 [
        #line(length: 100%, stroke: 0.5pt + t.rule)
        #v(2pt)
        #grid(
          columns: (1fr, auto, 1fr),
          align: (left + horizon, center + horizon, right + horizon),
          text(size: 8pt, fill: t.muted)[#if organisation != none {organisation}],
          text(size: 8pt, fill: t.muted)[#page-num],
          text(size: 8pt, fill: t.muted)[#if project != none {project}],
        )
      ]
    },
  )

  set text(font: t.font-body, size: t.font-size, lang: "en")
  show heading: set text(font: t.font-sans)
  set par(justify: true, leading: t.line-height, first-line-indent: 0pt, spacing: 0.9em)

  // ------------------- Heading styles -------------------
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(0.5em)
    block[
      #if it.numbering != none [
        #text(size: 8pt, fill: t.accent, weight: "bold", tracking: 1.5pt)[
          SECTION #counter(heading).display()
        ]
        #v(-0.3em)
      ]
      #text(size: 20pt, fill: t.primary, weight: "bold")[#it.body]
      #v(-0.2em)
      #line(length: 100%, stroke: 1.5pt + t.primary)
    ]
    v(0.8em)
  }

  show heading.where(level: 2): it => {
    v(0.8em)
    block(text(size: 13pt, fill: t.primary, weight: "bold")[
      #counter(heading).display() #h(0.5em) #it.body
    ])
    v(0.2em)
  }

  show heading.where(level: 3): it => {
    v(0.5em)
    block(text(size: 11pt, fill: t.primary, weight: "semibold")[
      #counter(heading).display() #h(0.4em) #it.body
    ])
    v(0.1em)
  }

  show heading.where(level: 4): it => {
    block(text(size: 10pt, weight: "bold", fill: t.primary.darken(20%))[#it.body])
  }

  show link: it => text(fill: t.accent, underline(it))

  // Inline & block code
  show raw.where(block: false): it => box(
    fill: t.code-bg,
    inset: (x: 3pt, y: 1pt),
    outset: (y: 2pt),
    radius: 2pt,
    text(font: t.font-mono, size: 8.5pt, it),
  )
  show raw.where(block: true): it => block(
    fill: t.code-bg,
    inset: 10pt,
    radius: 3pt,
    width: 100%,
    stroke: (left: 2pt + t.accent),
    text(font: t.font-mono, size: 8.5pt, it),
  )

  // Tables
  set table(
    stroke: 0.5pt + t.rule,
    inset: 6pt,
    fill: (_, y) => if y == 0 { t.primary.lighten(85%) } else { none },
  )
  show table.cell.where(y: 0): set text(weight: "bold", fill: t.primary)

  // ========================================================================
  // COVER PAGE
  // ========================================================================
  page(
    header: none,
    footer: none,
    margin: (top: 2.5cm, bottom: 2cm, x: 2.5cm),
  )[
    #if organisation != none [
      #block(
        fill: t.primary,
        width: 100%,
        inset: 12pt,
      )[
        #text(size: 14pt, fill: white, weight: "bold", tracking: 1.5pt)[
          #upper(organisation)
        ]
      ]
    ]

    #v(4em)

    #align(right)[
      #box(
        fill: cf.color,
        inset: (x: 14pt, y: 6pt),
        radius: 3pt,
        text(size: 11pt, fill: white, weight: "bold", tracking: 1.5pt)[#cf.label],
      )
    ]

    #v(3em)

    #if project != none [
      #text(size: 10pt, fill: t.accent, weight: "bold", tracking: 2pt)[#upper(project)]
      #v(0.3em)
      #line(length: 4cm, stroke: 2pt + t.accent)
      #v(1.5em)
    ]

    #par(justify: false)[
      #text(size: 32pt, fill: t.primary, weight: "bold")[#title]
    ]

    #if subtitle != none {
      v(0.5em)
      text(size: 16pt, fill: t.muted, style: "italic")[#subtitle]
    }

    #v(6em)

    #let meta-rows = ()
    #if doc-id != none {
      meta-rows.push((
        text(size: 9pt, fill: t.muted, weight: "bold")[DOCUMENT ID],
        text(size: 10pt)[#doc-id],
      ))
    }
    #meta-rows.push((
      text(size: 9pt, fill: t.muted, weight: "bold")[VERSION],
      text(size: 10pt)[#version],
    ))
    #meta-rows.push((
      text(size: 9pt, fill: t.muted, weight: "bold")[DATE],
      text(size: 10pt)[#date.display("[day] [month repr:long] [year]")],
    ))
    #if authors.len() > 0 {
      meta-rows.push((
        text(size: 9pt, fill: t.muted, weight: "bold")[AUTHOR#if authors.len() > 1 {"S"}],
        stack(spacing: 0.4em, ..authors.map(a => text(size: 10pt)[
          #a.name #if "role" in a [— #text(fill: t.muted)[#a.role]]
        ])),
      ))
    }
    #if reviewers.len() > 0 {
      meta-rows.push((
        text(size: 9pt, fill: t.muted, weight: "bold")[REVIEWER#if reviewers.len() > 1 {"S"}],
        stack(spacing: 0.4em, ..reviewers.map(r => text(size: 10pt)[
          #r.name #if "role" in r [— #text(fill: t.muted)[#r.role]]
        ])),
      ))
    }

    #grid(
      columns: (auto, 1fr),
      column-gutter: 1.5em,
      row-gutter: 0.8em,
      ..meta-rows.flatten(),
    )

    #v(1fr)

    #line(length: 100%, stroke: 0.5pt + t.rule)
    #v(0.5em)
    #grid(
      columns: (1fr, auto),
      align: (left, right),
      text(size: 8pt, fill: t.muted)[#if organisation != none {organisation}],
      text(size: 8pt, fill: t.muted)[#date.display("[year]")],
    )
  ]

  // ------------------- Revision history -------------------
  if history.len() > 0 {
    heading(level: 1, numbering: none, "Revision History")
    table(
      columns: (auto, auto, 1fr, auto),
      align: (left, left, left, left),
      table.header[Version][Date][Changes][Author],
      ..history.map(h => (h.version, h.date, h.changes, h.author)).flatten(),
    )
  }

  // ------------------- Abstract -------------------
  if abstract != none {
    heading(level: 1, numbering: none, "Executive Summary")
    block(
      fill: t.block-bg,
      stroke: (left: 3pt + t.accent),
      inset: 14pt,
      width: 100%,
      abstract,
    )
  }

  // ------------------- Table of contents -------------------
  heading(level: 1, numbering: none, "Contents")
  show outline.entry.where(level: 1): it => {
    v(0.6em, weak: true)
    text(weight: "bold", fill: t.primary, it)
  }
  outline(title: none, indent: auto, depth: 3)

  // ------------------- Body -------------------
  set heading(numbering: "1.1.1")
  body
}

// =============================================================================
// Helpers — call these from the body of a truss-report document
// =============================================================================

// -----------------------------------------------------------------------------
// callout(kind, title, body) — accent-bar information block
//   kinds: "note", "decision", "warning", "risk", "todo", "insight"
// -----------------------------------------------------------------------------
#let callout(kind: "note", title: none, theme: default-theme, body) = {
  let t = default-theme
  for (k, v) in theme { t.insert(k, v) }

  let styles = (
    note:     (color: t.semantic.info,    label: "NOTE"),
    decision: (color: t.semantic.success, label: "DECISION"),
    warning:  (color: t.semantic.warn,    label: "WARNING"),
    risk:     (color: t.semantic.danger,  label: "RISK"),
    todo:     (color: t.semantic.purple,  label: "TODO"),
    insight:  (color: t.semantic.cyan,    label: "INSIGHT"),
  )
  let s = styles.at(kind)
  block(
    fill: s.color.lighten(92%),
    stroke: (left: 3pt + s.color),
    inset: 10pt,
    radius: (right: 3pt),
    width: 100%,
    spacing: 1em,
  )[
    #text(size: 8pt, fill: s.color, weight: "bold", tracking: 1pt)[
      #s.label#if title != none [ — #title]
    ]
    #v(-0.4em)
    #body
  ]
}

// -----------------------------------------------------------------------------
// req(id, title, priority, ...) — structured requirement block
//
// Pass `category-color: rgb("#...")` to color-code by your own taxonomy.
// The default color is the theme primary. The id is shown verbatim, with no
// parsing — works with any naming convention: REQ-001, FN-12, CISC-7.1, etc.
// -----------------------------------------------------------------------------
#let req(
  id: "REQ-000",
  title: "",
  priority: "SHOULD",
  category-color: none,
  rationale: none,
  verification: none,
  source: none,
  theme: default-theme,
  body,
) = {
  let t = default-theme
  for (k, v) in theme { t.insert(k, v) }
  let cat-color = if category-color == none { t.primary } else { category-color }

  let prio-colors = (
    "MUST":   t.semantic.danger,
    "SHOULD": t.semantic.warn,
    "MAY":    t.muted,
  )
  let prio-color = prio-colors.at(priority, default: t.muted)

  let extra-rows = ()
  if rationale != none {
    extra-rows.push((
      text(size: 8pt, fill: t.muted, weight: "bold")[RATIONALE],
      text(size: 9pt)[#rationale],
    ))
  }
  if verification != none {
    extra-rows.push((
      text(size: 8pt, fill: t.muted, weight: "bold")[VERIFICATION],
      text(size: 9pt)[#verification],
    ))
  }
  if source != none {
    extra-rows.push((
      text(size: 8pt, fill: t.muted, weight: "bold")[SOURCE],
      text(size: 9pt)[#source],
    ))
  }

  block(
    fill: t.block-bg,
    stroke: (left: 3pt + cat-color, rest: 0.5pt + t.rule),
    inset: 10pt,
    radius: (right: 3pt),
    width: 100%,
    spacing: 1.2em,
    breakable: true,
  )[
    #grid(
      columns: (auto, 1fr, auto),
      column-gutter: 0.8em,
      align: (left + horizon, left + horizon, right + horizon),
      box(
        fill: cat-color,
        inset: (x: 6pt, y: 2pt),
        radius: 2pt,
        text(size: 8pt, fill: white, weight: "bold", font: t.font-mono)[#id],
      ),
      text(size: 10pt, weight: "bold", fill: t.primary)[#title],
      box(
        stroke: 1pt + prio-color,
        inset: (x: 5pt, y: 1pt),
        radius: 2pt,
        text(size: 7pt, fill: prio-color, weight: "bold", tracking: 0.5pt)[#priority],
      ),
    )

    #v(0.4em)
    #line(length: 100%, stroke: 0.3pt + t.rule)
    #v(0.4em)

    #body

    #if extra-rows.len() > 0 {
      v(0.5em)
      grid(
        columns: (auto, 1fr),
        column-gutter: 0.8em,
        row-gutter: 0.4em,
        ..extra-rows.flatten()
      )
    }
  ]
}

// -----------------------------------------------------------------------------
// adr(id, title, status, date, ctx, decision, consequences)
// Lightweight Architecture Decision Record.
// Note: parameter is `ctx:` (Typst reserves the `context` keyword)
// -----------------------------------------------------------------------------
#let adr(
  id: "ADR-000",
  title: "",
  status: "Proposed",
  date: datetime.today(),
  ctx: [],
  decision: [],
  consequences: [],
  theme: default-theme,
) = {
  let t = default-theme
  for (k, v) in theme { t.insert(k, v) }

  let status-colors = (
    "Proposed":   t.muted,
    "Accepted":   t.semantic.success,
    "Deprecated": t.semantic.warn,
    "Superseded": t.semantic.danger,
  )
  let sc = status-colors.at(status, default: t.muted)

  block(
    stroke: 0.5pt + t.rule,
    inset: 12pt,
    radius: 3pt,
    width: 100%,
    breakable: true,
    spacing: 1.2em,
  )[
    #grid(
      columns: (1fr, auto),
      align: (left + horizon, right + horizon),
      [
        #text(size: 9pt, fill: t.muted, font: t.font-mono)[#id]
        #h(0.5em)
        #text(size: 11pt, weight: "bold", fill: t.primary)[#title]
      ],
      box(
        fill: sc,
        inset: (x: 6pt, y: 2pt),
        radius: 2pt,
        text(size: 8pt, fill: white, weight: "bold")[#upper(status)],
      ),
    )
    #v(0.2em)
    #text(size: 8pt, fill: t.muted)[#date.display("[year]-[month]-[day]")]
    #v(0.6em)

    #text(size: 9pt, fill: t.muted, weight: "bold")[CONTEXT]
    #v(-0.3em)
    #ctx

    #v(0.5em)
    #text(size: 9pt, fill: t.muted, weight: "bold")[DECISION]
    #v(-0.3em)
    #decision

    #v(0.5em)
    #text(size: 9pt, fill: t.muted, weight: "bold")[CONSEQUENCES]
    #v(-0.3em)
    #consequences
  ]
}

// -----------------------------------------------------------------------------
// landscape(body) — wraps content in a flipped-orientation page
// Useful for wide trade-off matrices, Gantt charts, large diagrams
// -----------------------------------------------------------------------------
#let landscape(body) = {
  page(
    flipped: true,
    margin: (top: 2.5cm, bottom: 2cm, x: 2cm),
    body,
  )
}

// -----------------------------------------------------------------------------
// score(value, max: 5) — color-coded score cell for matrices
// Green for high, yellow for mid, red for low
// -----------------------------------------------------------------------------
#let score(value, max: 5) = {
  let ratio = value / max
  let color = if ratio >= 0.8 { rgb("#2E7D32") }
              else if ratio >= 0.6 { rgb("#7CB342") }
              else if ratio >= 0.4 { rgb("#FBC02D") }
              else if ratio >= 0.2 { rgb("#E65100") }
              else { rgb("#C62828") }
  box(
    fill: color.lighten(70%),
    stroke: 0.5pt + color,
    inset: (x: 6pt, y: 2pt),
    radius: 2pt,
    text(size: 9pt, fill: color.darken(20%), weight: "bold")[#value],
  )
}

// -----------------------------------------------------------------------------
// kv-block(title, (key, value), ...) — compact specification table
// -----------------------------------------------------------------------------
#let kv-block(title: none, theme: default-theme, ..pairs) = {
  let t = default-theme
  for (k, v) in theme { t.insert(k, v) }
  let entries = pairs.pos()

  block(
    fill: t.block-bg,
    stroke: (left: 2pt + t.primary),
    inset: 10pt,
    width: 100%,
  )[
    #if title != none {
      text(size: 9pt, fill: t.primary, weight: "bold", tracking: 1pt)[#upper(title)]
      v(0.5em)
    }
    #grid(
      columns: (auto, 1fr),
      column-gutter: 1em,
      row-gutter: 0.4em,
      ..entries.map(p => (
        text(size: 9pt, fill: t.muted, weight: "bold")[#p.at(0)],
        text(size: 9pt)[#p.at(1)],
      )).flatten()
    )
  ]
}
