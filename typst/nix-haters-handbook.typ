#import "ugh-style.typ": *

#let title = "The NIX-HATERS Handbook"
#show: ugh-book.with(title: title, author: "jyn")

#title-page(
  [The NIX-#linebreak() HATERS Handbook],
  authors: ("jyn",),
  publisher: "jyn Really Likes Fruit LLC",
)

#copyright-page[
  Copyright © 2026 Jynn Nelson. Typeset with Typst.

  No Nix executor, `.nix` DSL, `nixpkgs`, or `NixOS` machine was used in the creation of this document.
]

#dedication[For Jade and edef. Love you lots.]

#contents()

#part(1, "Nix Is/Is Not")

#figure(
  image("assets/nix-is-not.jpg", width: 80%),
  caption: [what's up with your naming, folks],
) <fig-nix-is-not>

#chapter(1, "The Machine", deck: "A tool with opinions of its own")

#pullquote(attribution: "an operator")[Every interface is simple after one has mem
orized its accidents.]

This is a specimen paragraph. It exists to test the measure, leading, indentation,
running head, and the ordinary disposition of ink on the page. A second sentence
makes the line endings less obedient and therefore more useful.

== History of the Trouble

The system was built in layers. Each layer preserved the mistakes beneath it.

#transcript[
Date: Tue, 4 Aug 2026 08:00:00 +0200 \
From: operator\@example.test \
Subject: the machine has opinions

The command completed successfully. Nothing useful happened.
]

#hazard[Do not mistake a terse failure for a precise one.]

=== A smaller heading

The remaining text tests the lowest supported heading and ordinary body copy.

#correspondence(
  date: "Wed, 5 Aug 2026 01:14:03 +0200",
  from: "maintainer@example.test",
  to: "operator@example.test",
  subject: "Re: the machine has opinions",
)[I found the manual. It describes a different machine.]

#book-figure(
  align(center, box(
    width: 70%,
    inset: 12pt,
    stroke: 1pt,
  )[
    #set text(font: "Courier", size: 9pt)
    #align(center)[terminal → shell → utility → surprise]
  ]),
  caption: [A typical chain of custody],
  source: [the maintainers],
)

#notes-page[
  *1.* The specimen uses original text and geometry. It reproduces no artwork
  from the book that inspired its page design.
]

#references("nix-haters-handbook.bib")

#book-index((
  ("accidents", "6"),
  ("correspondence", "6"),
  ("documentation", "6"),
  ("machine", "6"),
))
