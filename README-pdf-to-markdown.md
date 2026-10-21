# PDF → Markdown for AI agents

Which converter to install with `mise` when an agent needs to read PDFs.
Measured 2026-08-13 on `batman` (16 cores, 42 GB RAM, **no GPU**) against a
real ~10-page born-digital German document, not a synthetic benchmark.

## tl;dr

```toml
# tag-user-sl0p/config/mise/conf.d/user.toml (→ ~/.config/mise/conf.d/user.toml)
[tools]
"pipx:markitdown"  = { version = "latest", extras = "pdf,docx,pptx,xlsx,xls,outlook" }
"pipx:pymupdf4llm" = "1"   # 2.0 is an empty shim with no CLI — see below
```

`pymupdf4llm` for PDFs, `markitdown` for everything else. Add `pipx:docling`
only when a document defeats both — see [When to reach for docling](#when-to-reach-for-docling).

### Why `pymupdf4llm` is pinned to 1.x

`pymupdf4llm` 2.0 (2026-10-19) is a 904-byte placeholder package with no code
and no entry points. The 4llm code now lives inside `pymupdf` 2.x, which only
ships the `pymupdf` and `pymupdf-config` commands. On `"latest"`, mise's pipx
backend fails with `Failed to install entrypoints for pymupdf4llm`. Keep the
pin at `"1"` until we drop the CLI and call `pymupdf4llm.to_markdown()` from
`pymupdf` 2.x instead.

## Why the pipx backend

None of these tools are in the mise registry (`mise registry | grep pdf` is
empty), so they come in through mise's `pipx:` backend — the same mechanism
`tag-node/config/mise/conf.d/h0.toml` already uses for `graphifyy`. Because
`uv` is on `PATH`, that backend shells out to `uv tool install` rather than
`pipx`, which makes installs fast and keeps each tool in its own venv.

## The candidates

| Tool | mise entry | Installed | Speed here | Verdict |
| --- | --- | --- | --- | --- |
| **pymupdf4llm** | `pipx:pymupdf4llm` | ~80 MB | 2 s | best output, **AGPL-3.0** |
| **markitdown** (Microsoft) | `pipx:markitdown` | 279 MB | 7 s | weak on PDF, great on Office formats |
| **docling** (IBM) | `pipx:docling` | 1.5 GB + ~500 MB models | 126 s | layout-aware, handles scans |
| **marker-pdf** (Datalab) | `pipx:marker-pdf` | ~2 GB + torch | GPU-bound | best accuracy, needs a GPU |
| **mineru** | `pipx:mineru[pipeline]` | ~2 GB + torch | 0.54 pg/s | slow even on a GPU |

marker and MinerU are out on a headless node: marker v2 scores 76.0 on
olmOCR-bench but only at 2.9 pages/s on a B200, and its CPU-only
`--disable_ocr` mode falls to 43.6. Neither is worth several GB here.

## What the output actually looked like

Same PDF through each tool:

- **pymupdf4llm** — correct heading hierarchy (`#`, `##`, `###`), `**bold**`,
  backticked code spans, and a correct GFM table. 3 seconds.
- **docling** — correct GFM table, correct reading order and list structure,
  but flattens *every* heading to `##`, drops inline code formatting, and
  mangles German quotation marks (`„October 2023"` → `'October 2023"`).
- **markitdown** — no `#` headings at all, and the table collapsed into a
  column-by-column word soup (`Blatt / Kalk / Daten / Funktion …`). Its PDF
  path is a thin `pdfminer.six` wrapper; the value is in the other 20-odd
  formats it reads.

For born-digital PDFs the smallest tool won on quality *and* was 40× faster
than the 1.5 GB one. Reach for the heavy machinery only when the document
needs it.

## Gotchas

Both cost a failed install to find:

- **`extras = "all"` on markitdown does not resolve.** The `all` extra pulls
  `azure-ai-contentunderstanding>=1.2.0b1`, which is prerelease-only, and
  `uv tool install` refuses prereleases by default. Name the extras you want
  instead — the list in the tl;dr is everything except the Azure connectors
  and the YouTube/audio transcription paths.
- **docling drags in CUDA unless told not to.** A plain `pipx:docling` resolves
  122 dependencies including the full nvidia wheel set (cublas, cudnn, nccl,
  cusparse …) — several GB of GPU libraries that will never run on a headless
  node. Pass the CPU torch index through:

  ```toml
  "pipx:docling" = { version = "latest", uvx_args = "--torch-backend cpu" }
  ```

  That brings it down to 1.5 GB. docling then downloads ~500 MB of layout and
  TableFormer models from HuggingFace into `~/.cache/huggingface` on first run,
  so the first conversion is much slower than the rest.

## Licensing

PyMuPDF (and therefore `pymupdf4llm`) is **AGPL-3.0-or-commercial** from
Artifex. Fine for local tooling on your own machines; think twice before it
becomes a dependency of anything distributed or network-served. markitdown
(MIT) and docling (MIT) have no such string attached — that is the reason to
keep markitdown installed alongside rather than standardizing on one tool.

## Usage

```sh
markitdown report.docx > report.md          # any format → stdout
markitdown report.docx -o report.md

# pymupdf4llm is a batch converter: --out is a directory, not a file, and
# each input lands in <out>/<stem>/<stem>.md next to a run-log.txt.
pymupdf4llm --out ./md doc.pdf
pymupdf4llm --out ./md ./papers --pattern '*.pdf' --workers 8 --show-progress
```

Flags worth knowing: `--backend {md,json,txt}`, `--write-images` /
`--embed-images`, `--no-layout` to fall back to plain reading order, and
`--ocr-mode {never,select-drop,select-keep,force-drop,force-keep}` with
`--ocr-lang` — OCR goes through the system Tesseract (`/usr/bin/tesseract`,
already present on batman), so scanned pages are not automatically a reason
to reach for docling.

From Python, `pymupdf4llm.to_markdown(path)` returns the string directly, and
`to_markdown(path, page_chunks=True)` returns per-page dicts — useful when
feeding an agent a document too large for one context window.

## When to reach for docling

Install it ad hoc rather than permanently — `uvx --torch-backend cpu --from
docling docling --to md --output ./out file.pdf` runs it without committing
1.5 GB to `~/.local/share/mise`. It earns its keep on:

- **complex tables** — merged and nested cells, where its TableFormer model is
  the reason to use it at all
- **scans that Tesseract mangles** — docling brings its own layout model
  instead of leaning on pymupdf4llm's Tesseract path
- **anything where reading order is genuinely ambiguous** — heavy multi-column
  layouts, sidebars, footnote-dense academic PDFs
- **structured output for chunking** — `--to json` emits a `DoclingDocument`
  with semantic hierarchy intact, and `--to doctags` a tag form aimed at LLMs

Both markitdown and docling also ship MCP servers (`markitdown-mcp`,
`docling-mcp`) if agents should call the converter directly instead of
shelling out.

## Sources

- [Datalab Marker v2 vs MinerU, Docling, Liteparse benchmark](https://www.marktechpost.com/2026/07/24/datalab-marker-v2-vs-mineru-docling-and-liteparse-benchmark-breakdown/)
- [MarkItDown vs Docling vs Marker](https://www.danilchenko.dev/posts/markitdown-vs-docling-vs-marker/)
- [Docling installation docs](https://docling-project.github.io/docling/getting_started/installation/)
- [mise pipx backend](https://mise.jdx.dev/dev-tools/backends/pipx.html)
