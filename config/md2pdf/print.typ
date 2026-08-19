// Default typst style for `md2pdf -e typst` — the counterpart to print.css,
// used when the project being rendered brings no docs/print.typ of its own.
// Set for A4 and for German prose, the same decisions print.css makes.
//
// md2pdf drives this through its own minimal pandoc template, which has no
// `conf` wrapper — so unlike stock pandoc, what is set here is what the
// document gets, page and paragraph typography included.

#set page(
  paper: "a4",
  margin: (x: 18mm, top: 20mm, bottom: 18mm),
  numbering: "1",
)
#set text(
  font: ("Noto Serif", "Liberation Serif"),
  size: 10.5pt,
  hyphenate: true,
)
// German compounds are long; hyphenate rather than justify, which would
// otherwise open rivers of whitespace between them.
#set par(justify: false, leading: 0.65em)

#show heading: set text(font: ("Noto Sans", "Liberation Sans"))
// A heading alone at the foot of a page reads as a mistake.
#show heading: set block(breakable: false)

// The measure is what kills these tables: nine columns of German at body
// size cannot fit A4 portrait. print.css drops tables to 8pt; same here.
#show table: set text(font: ("Noto Sans", "Liberation Sans"), size: 8pt)

// pandoc wraps every table in align(center)[...], and its cells carry
// align: auto, which inherits that context — so cells come out centered.
// Re-establishing a left context inside the show rule is what overrides it.
// #set table(align: left) does NOT, because the writer's explicit align:
// argument beats a set rule.
#show table: it => block(width: 100%, align(left, it))

#set table(
  stroke: 0.5pt + rgb("#cccccc"),
  inset: (x: 5pt, y: 3.5pt),
  fill: (_, y) => if y == 0 { rgb("#ececec") } else if calc.odd(y) {
    rgb("#f7f7f7")
  },
)

#show raw: set text(font: ("Liberation Mono",), size: 8.5pt)
