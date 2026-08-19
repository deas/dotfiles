// Minimal pandoc typst template for md2pdf -e typst.
//
// Derived from `pandoc -D typst` with the `conf` wrapper removed. That
// wrapper is why the stock engine could not be styled: it runs
// `set document(title: title)` and its own page/par set rules AFTER
// header-includes, so it clobbered both the PDF title and any typography
// set in print.typ. Without it, print.typ has the last word — which is the
// arrangement print.css already has on the Chromium path.
//
// What is kept is everything pandoc's typst *writer* emits references:
// the terms indent, the bare table defaults it expects to override, the
// `divider`/`horizontalRule` polyfill used for thematic breaks, the figure
// caption positions and the syntax-highlighting definitions. Dropping any
// of those makes real documents fail to compile.
//
// Override with the MD2PDF_TYPST_TEMPLATE environment variable if a
// document needs more. Note: a literal dollar sign is template syntax to
// pandoc, so it must be doubled ($$) even inside a comment.
$if(highlighting-definitions)$
$highlighting-definitions$

$endif$
#set terms(hanging-indent: 1.5em)

#set table(
  inset: 6pt,
  stroke: none
)

#let horizontalRule = line(start: (25%,0%), end: (75%,0%))
// Polyfill divider to allow compiling with typst < 0.15:
#let divider = if "divider" in std { divider } else { horizontalRule }

#show figure.where(
  kind: table
): set figure.caption(position: $if(table-caption-position)$$table-caption-position$$else$top$endif$)

#show figure.where(
  kind: image
): set figure.caption(position: $if(figure-caption-position)$$figure-caption-position$$else$bottom$endif$)

$if(smart)$
$else$
#set smartquote(enabled: false)

$endif$
$if(title)$
#set document(title: [$title$])
$endif$
$if(lang)$
#set text(lang: "$lang$")
$endif$

$for(header-includes)$
$header-includes$

$endfor$
$for(include-before)$
$include-before$

$endfor$
$if(toc)$
#outline(
  title: auto,
  depth: $toc-depth$
)

$endif$
$body$
$for(include-after)$

$include-after$
$endfor$
