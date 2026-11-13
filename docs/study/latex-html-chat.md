# Offline HTML + LaTeX study chat viewer

Verified workflow from 2026-11-13 on Arch Linux (`stasbebra2006`) for producing
readable, step-by-step math answers with rendered LaTeX, diagrams, and a
Gemini-style appending chat thread when no local TeX compiler (`pdflatex`,
`xelatex`, `lualatex`, `tectonic`) is installed.

These notes are repository-only under `docs/`; chezmoi does not deploy them,
and the generated study files under `~/FIT/BI-MA/` are unmanaged.

## When to use this setup

- No local TeX engine is installed to compile `.tex` to `.pdf`.
- You want each question and answer appended chronologically to one persistent
  `.html` chat thread (plus a matching `.tex` file) and opened immediately in a
  browser.
- You want formulas, SVG plots, source citations, and separate personal notes
  to render offline without CDN dependencies.

## Source inspection tools

Before answering a coursework question from PDF textbooks (for example
`~/Downloads/bi-ma1-textbook.pdf` and `~/Downloads/bi-ma2-textbook.pdf`):

- Search across PDFs with `rga` (`ripgrep-all`) and extract context with
  `pdftotext -f <start> -l <end> <file.pdf> -` (`poppler`).
- Cite both the printed page number and the PDF page number when title/TOC pages
  shift numbering (for example, printed page 3 of `bi-ma2-textbook.pdf` is PDF
  page 7).
- Check the textbook's notation appendix/FAQ (e.g., $0^0 := 1$,
  $\mathbb{N} = \{1, 2, 3, \dots\}$, closed intervals $\langle a, b \rangle$) so
  generated answers match course conventions.

## Recreating offline MathJax on another machine

The FIT HTML textbook archive (`~/Downloads/bi-ma1-html-textbook.tar.gz`)
contains a self-contained MathJax v4 `mathjax-tex-font` bundle. Extract it into
an `assets/` directory beside the generated HTML files:

```sh
mkdir -p ~/FIT/BI-MA/assets
tar -xzf ~/Downloads/bi-ma1-html-textbook.tar.gz \
  -C ~/FIT/BI-MA/assets --strip-components=3 build/fit-html/js/mathjax-tex-font
```

Use `tex-mml-svg-mathjax-tex.js` (SVG output) rather than CHTML over `file://`:
SVG avoids browser `file://` cross-directory `.woff2` font-loading restrictions
in Firefox (`security.fileuri.strict_origin_policy`).

If `bi-ma1-html-textbook.tar.gz` is unavailable on another machine, obtain the
equivalent `mathjax-tex-font` SVG bundle locally under `assets/mathjax-tex-font/`
and test offline rendering in the target browser before relying on it.

### Required MathJax configuration

Configure `window.MathJax` before loading
`<script id="MathJax-script" async src="assets/mathjax-tex-font/tex-mml-svg-mathjax-tex.js"></script>`:

```js
window.MathJax = {
  loader: {
    paths: {
      'mathjax-tex': 'assets/mathjax-tex-font'
    }
  },
  output: {
    font: 'mathjax-tex',
    fontPath: 'assets/mathjax-tex-font',
    displayOverflow: 'linebreak'
  },
  svg: { fontCache: 'global' },
  tex: {
    inlineMath: [['$', '$'], ['\\(', '\\)']],
    displayMath: [['$$', '$$'], ['\\[', '\\]']],
    processEscapes: true,
    processEnvironments: true,
    macros: {
      N: "\\mathbb{N}",
      R: "\\mathbb{R}",
      Z: "\\mathbb{Z}",
      Q: "\\mathbb{Q}",
      dx: "\\mathrm{d}x"
    }
  },
  startup: {
    ready() {
      MathJax.startup.defaultReady();
      MathJax.startup.promise.then(() => {
        const latest = document.getElementById('latest');
        if (latest) latest.scrollIntoView({ behavior: 'instant', block: 'start' });
      });
    }
  }
};
```

## Chat-thread HTML and LaTeX structure

Keep one `.html` file and one companion `.tex` file per topic/session (for
example `~/FIT/BI-MA/<topic>.html` and `~/FIT/BI-MA/<topic>.tex`):

1. **Sticky top bar** with light/dark theme toggle (`data-theme="dark"`) and a
   `Zobrazit LaTeX` toggle revealing `.latex-panel` blocks.
2. **Appended turns** (`<section class="turn">`), moving `id="latest"` to the
   newly appended turn at the bottom and setting `scroll-margin-top: 64px` on
   `.turn` so the sticky top bar does not overlap the latest user prompt.
3. **Each turn contains:**
   - Right-aligned `.user-bubble` with the user's question.
   - Left-aligned `.ai-row` (`.ai-avatar` + `.ai-body`) with:
     - `.source-tag`: exact source file, theorem/example name, and printed + PDF
       page numbers.
     - `.theorem`: quoted definition/theorem from the materials.
     - Optional inline `<svg>` plot computed from exact coordinates when a sketch
       is needed.
     - `.steps`: small sequential algorithm cards (`Krok 1`, `Krok 2`, ...).
     - `.note`: amber callout separating own checks/mnemonics from source text.
     - `.latex-panel.hidden`: raw LaTeX excerpt for quick copying.
4. **Companion `.tex` file:** append a matching `\section*{...}` block separated
   by `\bigskip\hrule\bigskip` so a compilable LaTeX record exists if a TeX
   engine is installed later.

## Opening and verifying

- **Arch Linux (verified 2026-11-13):** open detached from agent processes (per
  `~/.agents/AGENTS.md`):
  ```sh
  systemd-run --user firefox "file://$HOME/FIT/BI-MA/<topic>.html#latest"
  ```
- **Headless render check (verified 2026-11-13):** screenshot in an isolated
  temporary profile and inspect the PNG to confirm MathJax SVG formulas, SVG
  labels, and scroll layout contain no raw `$$...$$` or overlapping text:
  ```sh
  firefox --headless --new-instance --profile /tmp/ff-verify-prof \
    --window-size=960,1850 --screenshot=/tmp/verify.png \
    "file://$HOME/FIT/BI-MA/<topic>.html"
  ```
- **macOS (untested here; adapt when recreating):** open the local HTML file in
  the browser (e.g., `open` on the file path, relying on the `MathJax.startup`
  `#latest` scroll rather than `file://...#fragment` if `open` treats `#` as a
  literal filename).
