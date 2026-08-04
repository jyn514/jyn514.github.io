// A black-and-white trade-book style inspired by the typographic grammar of
// The UNIX-HATERS Handbook (1994). No artwork or text from the book is copied.

#let ink = rgb("#111111")
#let paper = white
#let body-face = "Times New Roman"
#let title-face = "Times New Roman"
#let display-face = "Times New Roman"
#let cover-face = "Futura"
#let sans-face = "Arial"
#let mono-face = "Courier"
#let current-chapter = state("ugh-current-chapter", none)

#let ugh-book(
  title: none,
  author: none,
  paper-size: none,
  body,
) = {
  set document(title: title, author: author)
  let page-format = if paper-size == none {
    (width: 531pt, height: 666pt)
  } else {
    (paper: paper-size)
  }
  set page(
    ..page-format,
    fill: paper,
    margin: (top: 0.82in, bottom: 0.78in, x: 0.9in),
    header-ascent: 0.22in,
    footer-descent: 0.22in,
    header: context {
      if counter(page).get().first() > 1 {
        let chapter = current-chapter.get()
        set text(font: body-face, size: 8pt, fill: ink)
        let folio = counter(page).get().first()
        let book-name = if title == none { [Notes] } else { title }
        let chapter-name = if chapter == none { [Notes] } else { chapter }
        if calc.even(folio) {
          grid(
            columns: (auto, 1fr),
            align: (left, right),
            counter(page).display("1"),
            smallcaps(book-name),
          )
        } else {
          grid(
            columns: (1fr, auto),
            align: (left, right),
            smallcaps(chapter-name),
            counter(page).display("1"),
          )
        }
        v(-4pt)
        line(length: 100%, stroke: 0.55pt + ink)
      }
    },
  )
  set text(font: body-face, size: 10.5pt, fill: ink, lang: "en")
  set par(justify: true, leading: 0.58em, first-line-indent: 1.15em)
  set heading(numbering: none)
  set list(indent: 1.2em, body-indent: 0.55em, spacing: 0.35em)
  set enum(indent: 1.2em, body-indent: 0.55em, spacing: 0.35em)
  show link: set text(fill: ink)
  show emph: set text(style: "italic")
  show strong: set text(font: display-face, weight: "bold")
  show footnote.entry: set text(font: body-face, size: 8pt)
  show figure.caption: set text(font: body-face, size: 8.5pt, weight: "bold")
  show heading.where(level: 2): it => {
    v(1.1em)
    block(breakable: false)[
      #set text(font: display-face, size: 15pt, weight: "bold")
      #it.body
      #v(2pt)
      #line(length: 100%, stroke: 0.7pt + ink)
    ]
    v(0.35em)
  }
  show heading.where(level: 3): it => {
    v(0.8em)
    text(font: display-face, size: 11pt, weight: "bold", it.body)
    v(0.15em)
  }
  body
}

// Front matter -------------------------------------------------------------

#let title-page(title, subtitle: none, authors: (), publisher: none) = {
  current-chapter.update(none)
  align(center + horizon)[
    #set text(font: display-face, fill: ink)
    #line(length: 1.25in, stroke: 4pt + ink)
    #v(18pt)
    #text(font: title-face, size: 35pt, weight: "bold", title)
    #if subtitle != none [
      #v(10pt)
      #text(size: 15pt, weight: "medium", style: "italic", subtitle)
    ]
    #v(30pt)
    #for author in authors [
      #text(size: 12pt, weight: "bold", author)
      #linebreak()
    ]
    #if publisher != none [
      #v(1fr)
      #text(
        font: cover-face,
        size: 10pt,
        weight: 800,
        stretch: 75%,
        smallcaps(publisher),
      )
    ]
  ]
  pagebreak()
}

#let copyright-page(body) = {
  current-chapter.update(none)
  align(left + bottom, block(width: 70%)[
    #set text(size: 8.5pt)
    #set par(justify: false, leading: 0.5em, first-line-indent: 0pt)
    #body
  ])
  pagebreak()
}

#let dedication(body) = {
  current-chapter.update(none)
  align(center + horizon, block(width: 55%)[
    #set par(justify: false, first-line-indent: 0pt)
    #set text(style: "italic", size: 12pt)
    #align(center, body)
  ])
  pagebreak()
}

#let contents(title: [Table of Contents], depth: 3) = {
  current-chapter.update(title)
  set text(font: body-face, size: 10pt)
  show outline.entry.where(level: 1): set text(font: display-face, weight: "bold")
  outline(title: title, depth: depth, indent: auto)
  pagebreak()
}

// Begin a chapter on a fresh recto-like page. `deck` is the short subtitle.
#let chapter(number, title, deck: none) = {
  current-chapter.update(title)
  pagebreak(weak: true)
  block(height: 2.18in, width: 100%, breakable: false)[
    #grid(
      columns: (1fr, auto),
      align: (left + bottom, right + top),
      [
        #set text(font: display-face, weight: "bold", fill: ink)
        #text(font: title-face, size: 29pt, title)
        #if deck != none [
          #v(8pt)
          #text(size: 13pt, weight: "medium", style: "italic", deck)
        ]
      ],
      [
        #box(
          width: 0.84in,
          height: 0.84in,
          fill: ink,
          inset: 0pt,
          align(center + horizon, text(
            font: display-face,
            size: 36pt,
            weight: "bold",
            fill: paper,
            str(number),
          )),
        )
      ],
    )
    #v(11pt)
    #line(length: 100%, stroke: 2pt + ink)
  ]
  par(first-line-indent: 0pt)[]
}

// A section label used for large divisions before a chapter run.
#let part(number, title) = {
  current-chapter.update(none)
  pagebreak(weak: true)
  align(center + horizon)[
    #set text(font: display-face, fill: ink)
    #text(size: 12pt, weight: "bold", tracking: 0.12em, smallcaps[Part #number])
    #v(12pt)
    #line(length: 1.1in, stroke: 2pt + ink)
    #v(14pt)
    #text(font: title-face, size: 30pt, title)
  ]
  pagebreak()
}

// Compact correspondence or terminal material, common in the source book.
#let transcript(body) = block(
  width: 100%,
  breakable: true,
  inset: (left: 0.24in, right: 0.14in, y: 7pt),
  stroke: (left: 1.2pt + ink),
)[
  #set text(font: mono-face, size: 8.3pt)
  #set par(justify: false, leading: 0.45em, first-line-indent: 0pt)
  #body
]

// Mail-like source material with aligned, visually distinct headers.
#let correspondence(
  date: none,
  from: none,
  to: none,
  subject: none,
  body,
) = block(
  width: 100%,
  breakable: true,
  inset: (left: 0.24in, right: 0.14in, y: 7pt),
  stroke: (left: 1.2pt + ink),
)[
  #set text(font: mono-face, size: 8.3pt)
  #set par(justify: false, leading: 0.45em, first-line-indent: 0pt)
  #for field in (
    ("Date", date),
    ("From", from),
    ("To", to),
    ("Subject", subject),
  ) {
    if field.at(1) != none [
      #grid(
        columns: (4.6em, 1fr),
        gutter: 0.5em,
        text(weight: "bold", field.at(0) + ":"),
        field.at(1),
      )
    ]
  }
  #v(0.55em)
  #body
]

#let pullquote(attribution: none, body) = block(
  width: 88%,
  breakable: false,
  inset: (y: 8pt),
)[
  #set par(justify: false, leading: 0.48em, first-line-indent: 0pt)
  #set text(font: body-face, size: 12pt, style: "italic")
  “#body”
  #if attribution != none [
    #v(4pt)
    #align(right)[— #attribution]
  ]
]

// An original substitute for the source book's cartoons and marginal warnings.
#let hazard(label: "CAUTION", body) = block(
  width: 100%,
  breakable: false,
  inset: 9pt,
  stroke: 1pt + ink,
)[
  #grid(
    columns: (auto, 1fr),
    gutter: 10pt,
    align: (center + horizon, left + horizon),
    box(fill: ink, inset: (x: 6pt, y: 4pt))[
      #text(font: sans-face, size: 8pt, weight: "bold", fill: paper, label)
    ],
    [#set par(first-line-indent: 0pt); #body],
  )
]

// Figures use original or separately licensed art supplied by the caller.
#let book-figure(image, caption: none, source: none) = figure(
  image,
  caption: if caption == none { none } else [
    #caption
    #if source != none [ #text(weight: "regular", style: "italic")[— #source]]
  ],
)

#let notes-page(title: [Notes], body) = {
  current-chapter.update(title)
  pagebreak(weak: true)
  heading(level: 1, outlined: true, title)
  set text(size: 9pt)
  set par(leading: 0.5em)
  body
}

#let references(source, title: [Bibliography], style: "chicago-author-date") = {
  current-chapter.update(title)
  pagebreak(weak: true)
  heading(level: 1, outlined: true, title)
  bibliography(source, title: none, style: style)
}

// `entries` is an array of (term, page-or-pages) pairs. Explicit input keeps
// the index stable and permits ranges and cross-references such as "see Mail".
#let book-index(entries, title: [Index], column-count: 2) = {
  current-chapter.update(title)
  pagebreak(weak: true)
  heading(level: 1, outlined: true, title)
  columns(column-count, gutter: 0.25in)[
    #set text(size: 8.5pt)
    #set par(justify: false, leading: 0.42em, first-line-indent: -0.8em, hanging-indent: 0.8em)
    #for entry in entries.sorted(key: item => lower(item.at(0))) [
      #entry.at(0)#h(0.5em)#box(width: 1fr, repeat[.])#h(0.35em)#entry.at(1)#linebreak()
    ]
  ]
}
