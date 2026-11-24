// Source: content/rising-tide-raises-rents.md, “Possible worlds”.
// Render from the repository root:
// typst compile static/assets/possible-worlds.typ static/assets/possible-worlds.svg
// Reinstatement failure is intermediate; the five green cards are endpoints.
// The no-action branch combines revolution's outcomes; see the prose for that distinction.
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#set page(width: auto, height: auto, margin: 12pt, fill: white)
#set text(font: "Libertinus Serif", size: 12pt, fill: rgb("#172c38"))
#set par(leading: 0.55em)

#let ink = rgb("#415c6b")
#let process = rgb("#edf3f6")
#let outcome = rgb("#d9eee9")
#let danger = rgb("#fae4cd")

#diagram(
  spacing: (24pt, 34pt),
  node-stroke: 0.9pt + ink,
  node-fill: process,
  node-inset: 10pt,
  node-corner-radius: 6pt,
  edge-stroke: 1.2pt + ink,
  label-size: 11pt,
  mark-scale: 80%,

  node((1, 0), [Does AI revolutionize\ the economy?], width: 150pt),
  node((2, 0), [*Status quo*], width: 136pt, fill: outcome),
  edge((1, 0), (2, 0), "-|>", [No], label-side: left),

  node((1, 1), [Do new jobs replace\ lost jobs?], width: 150pt),
  edge((1, 0), (1, 1), "-|>", [Yes], label-side: left),
  node((2, 1), [*Messy transition*], width: 136pt, fill: outcome),
  edge((1, 1), (2, 1), "-|>", [Yes], label-side: left),

  node((1, 2), [*Reinstatement failure*], width: 150pt, fill: danger),
  edge((1, 1), (1, 2), "-|>", [No], label-side: left),

  node((0, 3), [*Butlerian Jihad*], width: 136pt, fill: outcome),
  node((1, 3), [*Bread and circuses*\ Rentier world], width: 150pt, fill: outcome),
  node((2, 3), [*Distributed ownership*\ Post-scarcity world], width: 136pt, fill: outcome),
  edge((1, 2), (0, 3), "-|>", [No action], corner: left, label-pos: 0.25, label-side: right),
  edge((1, 2), (1, 3), "-|>", [Welfare / UBI], label-side: left),
  edge((1, 2), (2, 3), "-|>", [Share gains], corner: right, label-pos: 0.25, label-side: left),
)
