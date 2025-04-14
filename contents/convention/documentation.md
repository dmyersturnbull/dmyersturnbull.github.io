# Documentation conventions

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

### Summary points / highlights

These guidelines are aggressive and lengthy (more than originally intended).
Skip the details gloss over the details.
Here are the important points.

<b>Filenames:</b>

- Use _lowercase-kebab-case_, limiting characters to `[a-z0-9-]`.
- Use `LICENSE.txt` and`config.yaml` over `LICENSE` and `config.yml`.

<b>Language:</b>

- Keep language simple, and be explicit.
- Sometimes an example is sufficient.

<b>Markdown:</b>

- Start a new line for every sentence (it helps with diffs).
- Limit lines to 120 characters, breaking at sensible places.
- Use `**bold**` for emphasis, `_italics_` as the
  [`<i>` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/i),
  and `<b></b>` for non-emphasized but bold text; e.g. `<b>Score:</b> 12.5`.

<b>Comments (in code):</b>

- Forgo comments that are superfluous or included out of habit or convention.

## Filenames

This section can apply to naming of URI nodes, database IDs, and similar constructs.
These are general guidelines: Alternatives should be used in some situations.
For example, if camelCase is used in your JSON Schema, use camelCase for schema document filenames.

??? rationale

    The [official YAML extension is `.yaml`](https://yaml.org/faq.html).
    Moreover, the IANA media types are `application/yaml`, `text/html`, and `image/jpeg`.
    `.yml`, `.htm`, and `.jpg` are relics of DOS.
    Extensions prominently show essential information, and ommitting them can cause confusion.
    For example, a file named `info` could be a plain-text info document or a shell script that writes the info.
    Instead, write it as `info.txt` or `info.sh`.

Prefer kebab-case (e.g. `full-document.pdf`), treating `-` as a space.
Restrict to `-`, `.`, `[a-z]`, and `[0-9]`, unless there is a compelling reason otherwise.
If necessary, `--`, `+`, and `~` can be used as specialized word separators.
For example, `+` could denote joint authorship in `mary-johnson+kerri-swanson-document.pdf`.

Always use one or more filename extensions, except for executable files;
e.g. `LICENSE.txt` or `LICENSE.md`, **not** `LICENSE`.
Where possible, use `.yaml` for YAML, `.html` for HTML, and `.jpeg` for JPEG.
In particular, **do not** use `.yml`, `.htm`, `.jpg`, or `.jfif`.

## Comments

Comments must be maintained like all other elements of code.
Avoid unnecessary comments, such as those added out of habit or ritual.
Forgo comments that are obvious or otherwise unhelpful.

??? example "Examples"

    === "❌ Incorrect"

        ```python
        class SpecialCache[T]:
            """
            Soft cache supporting the Foobar backend.
            Uses a Least Recently Used (LRU) policy with an expiration duration.
            """

            def get_cache_item(selfself, key: str) -> T:
                # (1)!
                """
                Gets the cache item corresponding to key `key`.

                Arguments:
                    key: A string-valued key

                Returns:
                    The value for the key `key`
                """
                return self._items[key]
        ```

        1. The docstring argument list and return description serve no function.

    === "✅ Correct"

        ```python
        class SpecialCache[T]:
            """
            Soft cache supporting the Foobar backend.
            Uses a Least Recently Used (LRU) policy with an optional expiration duration.
            """

            def get_cache_item(selfself, key: str) -> T:
                return self._items[key]
        ```

## Language and grammar

**Apply these guidelines to both comments and documentation.**
See [Google’s documentation style guide](https://developers.google.com/style/) for additional guidelines.

### Style

Remove text that is repetitive or superfluous.
Be direct.
Use examples, diagrams, formal grammars, pseudocode, and mathematical expressions.
Write English descriptions for diagrams and any other elements that are be inaccessible to screen readers.

Keep language accessible:
Introduce or explain jargon, favor simpler words, and replace idioms with literal phrasing.
Do not rely on mutual agreement about subtle differences between similar words.
For example, do not use both _significant_ and _substantial_.
To distinguish a very significant finding from a significant one, write _very significant_.
Be explicit.
Use singular _they_ and other gender-neutral terms, and use inclusive language.
Substitute long phrases with shorter ones.

Great documentation should not win poetry awards.
Keep things simple and direct.

??? example "Examples: overlong phrases"

    | ❌ Avoid                        | ✅ Preferred    |
    |--------------------------------|----------------|
    | _utilize_                      | _use_          |
    | _due to the fact that_         | _because_      |
    | _a great number of_            | _many_         |
    | _is able to_                   | _can_          |
    | _needless to say_              | (omit)         |
    | _it is important to note that_ | _importantly,_ |

### Spelling

Use American English spelling.
American English is the [most widespread dialect](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5969760/),
and it generally has more phonetic and shorter spellings.

### Grammar and punctuation

Use 1 space between sentences.

Use sentence case for titles and table headers (e.g. _This is a title_).
Capitalize the first word after a colon only if it begins a complete sentence;
do not capitalize the first word after a semicolon.

### Terminology

Prefer the term
[URI](https://datatracker.ietf.org/doc/html/rfc3986),
over the terms
[URL](https://datatracker.ietf.org/doc/html/rfc1738)
and
[URN](https://datatracker.ietf.org/doc/rfc8141/).

??? rationale

    From [RFC 3986 §1.1.3](https://datatracker.ietf.org/doc/html/rfc3986#section-1.1.3):

    > Future specifications and related documentation should use the general term "URI"
    > rather than the more restrictive terms "URL" and "URN"
    > [[RFC3305]](https://datatracker.ietf.org/doc/html/rfc3305#section-2.2 "RFC 3305").

## Markdown

**Where applicable, apply these guidelines to other documentation, not just Markdown.**

### Line breaks

**Start each sentence on a new line.**

!!! rationale

    Keeping each sentence on its own line dramatically simplifies diffs.

??? bug "Incorrect `\n` treatment in GitHub Issues, Discussions, and PRs"

    As recently as 2024-12, GitHub incorrectly renders `\n` as `<br>` in Discussions, Issues, and Pull Requests.
    Per
    [the original Markdown spec](https://daringfireball.net/projects/markdown/syntax#block),
    [CommonMark](https://spec.commonmark.org/0.31.2/#soft-line-breaks),
    and
    [GitHub Flavored Markdown](https://github.github.com/gfm#soft-line-breaks),
    a non-consecutive `\n` is a soft line break, either a space or `\n` in HTML.
    In contrast, GitHub uses the correct behavior for `.md` files (e.g. `README.md`).
    Obviously, prioritize readability of the rendered document over readability of the source.

If needed to prevent a line from exceeding 120 characters, add line breaks elsewhere.
Look for one of these places to add a line break:

- Before and/or after a Markdown link
- Before an opening HTML tag (or Markdown equivalent) or after a closing tag
- After punctuation that begins an independent clause
- At another natural place

Also add a line break somewhere if you think it’s helpful.
In particular, consider around a long Markdown link, or before items of an inline list.
For example:

```markdown
You must abide by
[ARPA, 16 U.S.C. §§ 470aa–470mm](https://uscode.house.gov/view.xhtml?path=/prelim@title16/chapter1B&edition=prelim),
particularly
§ 470hh, “Confidentiality of information concerning nature and location of archeological resources”
and
§ 470ii, “Rules and regulations; intergovernmental coordination”.
```

### Text styles and semantics

!!! rationale

    This balancces between ease of writing Markdown, readability of the rendered HTML, and semantic precision.

Some semantic HTML elements are result in identical styles (in most browsers).
This table summarizes how to use them in HTML and in Markdown.

| element                                                                      | style     | usages                                                                   | equivalent Markdown           |
| ---------------------------------------------------------------------------- | --------- | ------------------------------------------------------------------------ | ----------------------------- |
| [`em`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/em)         | italic    | emphasis; [stress](<https://en.wikipedia.org/wiki/Stress_(linguistics)>) | `<em>text</em>` (prefer bold) |
| [`i`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/i)           | italic    | technical terms; foreign text; more                                      | `_text_`                      |
| [`var`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/dfn)       | italic    | terms being defined                                                      | `_term_` or `<dfn>term</dfn>` |
| [`var`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/var)       | italic    | variables                                                                | `$var$`                       |
| [`strong`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/strong) | bold      | strong emphasis                                                          | `**text**`                    |
| [`b`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/b)           | bold      | keywords, miscellaneous                                                  | `<b>text</b>`                 |
| [`code`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/code)     | monospace | source code                                                              | `` `code` ``                  |
| [`samp`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/samp)     | monospace | sample output                                                            | `` `code` ``                  |
| [`kbd`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/kbd)       | monospace | keyboard keys                                                            | `<kdb>keys</kbd>`             |

#### Italics

**Take `_`/`_`** (and `*`/`*`) as semantically equivalent to the
**[`<i>` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/i)**.

<a id="uses-of-__"></a>**Uses of `_`/`_`:**

- Foreign words, technical terms, etc.
- Literal references to words/phrases themselves.
  Importantly, single quotation marks (`‘`/`’`) or Markdown backticks may also be used.

<a id="non-uses-of-__"></a>**Non-uses of `_`/`_`:**

- Ubiquitous foreign phrases like _in vivo_, _in sitro_, _in silico_, and \_et al.;
  no markup is needed.
- Emphasis or importance. Instead, use bold `**`/`**`.
- Stress (e.g. to distinguish `<<I>> will go there` and `I will go <<there>>`.).
  (Refer to the following section.)

<a id="using-em-for-stress"></a>**Using `<em>` for stress:**

[Linguistic stress](https://en.wikipedia.org/wiki/Stress_(linguistics)
is usually marked using italics.
Consider the difference between `_I_ will go there` and `I will go _there_`.
The italicization is essential to the meaning.
This can lead to confusion if read as plaintext or by a screen reader, which may not announce the italicization.
It’s best to make the exact meaning explicit by rephrasing, such as in `I specifically will go there.`
If you need to use italics for stress, prefer explicit `<em></em>`.

<a id="using-the-dnf-element"></a>**Using the `<dfn>` element**

The [`dfn` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/) can be used in Markdown.
`_`/`_` is an acceptable fallback.

#### Bold

**Use `**`/`**` bold for emphasis.**
Take `**`/`**` as semantically equivalent to the
**[`<strong>` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/strong)**.

Use the [`<b>` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/b) explicitly
rather than `**`/`**` for text that should be bold but not emphasized –
i.e. semantically distinct from the surrounding text.
For example, you might write `<b>Score:</b> 55.3%`.

#### Code and math

!!! tip "Tip: Smarty plugin"

    With the Material for mkdocs
    [Smarty plugin](https://squidfunk.github.io/mkdocs-material/reference/formatting/#adding-keyboard-keys),
    you can use `++`/`++` instead of `<kdb>`/`<kdb>`; e.g. `++ctrl+alt+del++`.

Use backticks for code, `<kbd>`/`</kdb>` for keyboard keys.
For math, use LaTeX inline `$`/`$` for single-line and `$$`/`$$` for multi-line.

#### Menu navigation

To describe menu navigation, use [`➤`](https://www.fileformat.info/info/unicode/char/27A4/index.htm) in italics; e.g.
_File ➤ Export ➤ Export as Text_.
Try to use the exact words, capitalization, and punctuation.
For example, write _File ➤ Settings... ➤ Advanced_ if the menu uses
`...` (and not [U+2026 / `…`](https://www.fileformat.info/info/unicode/char/2026/index.htm)).

### Encoding

Write most non-ASCII characters as-is, not with entity references.
For example, write an en dash as `–`, not `&#x2013;`.

**Except**, use hexadecimal entity references for

- non-space whitespace characters; and
  (such as [no break space](https://www.fileformat.info/info/unicode/char/00A0/index.htm), `&nbsp;`);
- punctuation that is highly or extremely likely to confuse anyone reading the source code
  (such as [soft hyphen](https://www.fileformat.info/info/unicode/char/00AD/index.htm), `&#x00ad;`); and
- characters that must be escaped for technical reasons

### Unicode characters

!!! tip "Tip: Smarty plugin"

    With the Material for mkdocs
    [Smarty plugin](https://python-markdown.github.io/extensions/smarty/),
    you can use use `'` and `"` for quotation marks,
    `--` for en dashes, `---` for em dashes, and `...` for ellipses.

Use the correct Unicode characters for punctuation.
(Of course, use regular <i>hyphen-minus</i> (U+002D) for hyphens, **not** <i>hyphen</i> (U+2010).))

??? example "Examples"

    - `’` for apostrophes
    - `‘`, `’`, `“`, and `”` for quotation marks
    - `–` (_en dash_) for numerical ranges (e.g. `5–10`)
    - `—` (_em dash_) to separate a blockquote and its source
    - `‒` (_figure dash_) in numerical formatting
    - `…` (_ellipses_)
    - `−` (_minus sign_)
    - `µ` (_micro sign_)

### Punctuation (prescriptive grammar)

Use an en dash surrounded by spaces (`–`) to mark breaks in thoughts, **not** an em dash.
For example:

```markdown
An en dash – in contrast to an em dash – should be used here.
```

For _i.e._ and _e.g._, skip the comma (British English) and normally introduce with _;_.
For example: `say something nice; e.g. “nice boots”.`.

### Abbreviations

For the first appearance, consider writing it out in this format: _Public Library of Science (PLOS)_ †.
Omit periods (`.`) for initialisms; e.g. _USA_, not _U.S.A._.

<small>
<b>†</b> Note that the correct abbreviation for <abbr title="Public Library of Science">PLOS</abbr> is
<a href="https://theplosblog.plos.org/2012/07/new-plos-look/">
<i>PLOS</i>, <strong>not</strong> <i>PL<b>o</b>S</i>.
</a>
</small>

You can use, e.g., the
[Material for MkDocs Abbreviations extension](https://mrkeo.github.io/reference/abbreviations/)
[`<abbr>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/abbr),
or just an HTML tag with the `title` attribute.

### Admonitions

Use
[Material for mkdocs admonitions](https://squidfunk.github.io/mkdocs-material/reference/admonitions/),
[GitHub-Flavored Markdown alerts](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts),
or other “admonition” syntax the same way as the
[`<aside>` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/aside).
The content should be
(A) “offset” or “aside”,
(B) important when skimmed, or
(C) metatext (describes its surrounding content).

### Footnotes

??? rationale

    These symbols are easily recognized as indicating footnotes.
    Superscript numbers could be confused with reference numbers or even exponents in some places,
    and they are less accessible for people who are vision-impaired.

    - The asterisk `*` has other very common meanings and is inconvenient in Markdown.
      (The [U+204E `⁎`](https://www.fileformat.info/info/unicode/char/204e/index.htm) avoids the second problem.)
    - The double vertical bar `‖` has other very common meanings.
    - The pilcrow `¶` is too heavy and prominent in most fonts.
    - Doubled-up footnote symbols mean you have too many footnotes.

Use either a Markdown extension for footnotes, or follow this format:

```markdown
This statement is false. †

<small>
<b>†</b> Note that this is a contradictory statement.
</small>
```

The symbols don’t need to be superscripted.
Placement is discretionary: position before or after punctuation, with or without a space.
These symbols are recommended, in order:
`†` (dagger), `‡` (double dagger), `§` (section mark), `♯` (musical sharp), `♮` (musical natural), and `◊` (lozenge).

You can modify this list if needed,
or use another scheme like superscript numbers, superscript lowercase letters, etc.

### Citations

For references, use the IEEE inline style: `[1]`, `[2]`, etc.
IEEE style is also encouraged for bibliographies.

### Quotations

!!! rationale

    This preserves the semantic difference between punctuation _inside_ and _outside_ of quotations.
    This rule is always followed when using code in backticks, anyway.

Place punctuation outside of quotation marks (British-style rules).
For example, in `Also write ‘hard’, ‘difficult’, or ‘strenuous’.`

Introduce code blocks with punctuation only where semantically valid.
If it is semantically valid, use a colon rather than a comma.
In blockquotes, use `_— author_` (with an em dash) to cite the source.

??? example "Examples"

    In the following block, use _then run_, not _then run:_.

    ````markdown
    Then run

    ```
    ps -a -x
    ```
    ````

    However, use a colon here:

    ```markdown
    Mark Twain also said:

    > When in doubt‚ tell the truth.
    > This is a blockquote, which is ordinarily introduced by punctuation.
    > For clarity, we introduce such blockquotes with colons.
    > _— Mark Twain_
    ```

### Inline lists (enumerations)

For inline lists, follow this format:

(1) Use `(1)`, `(a)`, `(A)`, `(i)`, or `(I)`;
(2) use commas or semicolons;
(3) start a line for each item;
(4) specify `and`, `or`, or `nor`; and
(5) end the last line with the applicable punctuation.

### Formatting numbers

Numbers, units, dimensioned quantities, ranges, and measurement uncertainties must be readable.
This guide follows the
[IEEE recommendation](https://www.ieee.org/content/dam/ieee-org/ieee/web/org/conferences/style_references_manual.pdf).
Also see [NIST note 1297](https://www.nist.gov/pml/nist-technical-note-1297)
and the [Guides in Metrology](https://www.bipm.org/en/committees/jc/jcgm/publications).

!!! tip: "Tip: LuaTeX, siunitx, and fontspec"

    LuaTeX, [siunitx](https://ctan.org/pkg/siunitx), and [fontspec](https://ctan.org/pkg/fontspec)
    is the ideal solution, but it is not usable in Markdown.
    You need a suitable font, and `fontspec`, `\unimathsetup` and `\sisetup` as shown in
    [`fontworthy.sty`](https://github.com/dmyersturnbull/desert-latex/blob/main/src/fontworthy.sty#L220).

#### Numbers

Use:

- A period (`.`) as the
  [decimal separator](https://en.wikipedia.org/wiki/Decimal_separator)
- A narrow no break space,
  (` `, [U+002D](https://www.compart.com/en/unicode/U+u22c5)/`&nbsp;`)
  as the thousands separator

<b>Example:</b>

- **✅ Preferred**
  `1 024.222 222` (result: 1 024.222 222)
- **✅ Preferred (LaTeX)** `$1~024.222~222$ (result: $1~024.222~222$)
- **✅ Preferred (SIUnitX)** `$\num{1024.222222}$`
- **🟨 Acceptable** `1024.222222` (result: 1024.222222)
- **❌ Not acceptable** `1,024.222222` or `1.024,222222`

#### Dimensioned quantities

Use:

- A normal space **or**
  a no-breaking space
  (` `/[U+00A0](https://www.fileformat.info/info/unicode/char/00A0/index.htm)/`&nbsp;`)
  to separate magnitude and units.
- A middle dot
  (`·`/[U+00B7](https://www.fileformat.info/info/unicode/char/00B7/index.htm)/`&middot;`)
  to multiply units.
- [Unicode superscript](../cheatsheet/click-to-copy-symbols.md#superscript)
  digits (`⁰¹²³⁴⁵⁶⁷⁸⁹`) and minus sign (`⁻`) for unit exponents.

<b>Examples:</b>

- **✅ Preferred** `5 kg·m²·s⁻²` (result: 5 kg·m²·s⁻²)
- **✅ Preferred (LaTeX)** `$5~\mathrm{kg\cdot m^2\cdot s^{-2}}$`
  (result: $5~\mathrm{kg \cdot m^2 \cdot s^{-2}}$)
- **✅ Preferred (SIUnitX)** `$\qty{5 \kilogram\meter\squared\per\second\squared}$`
- **🟨 Acceptable** `5 kg m^2 / s^2` (result: 5 kg m^2 / s^2)
- **❌ Not acceptable** `5 kg*m^2/s^2` (result: 5 kg\*m^2/s^2)

#### Specific cases

- For the micro SI prefix, use the micro sign,
  `μ`/[U+00B5](https://www.fileformat.info/info/unicode/char/00B5/index.htm). †
- For Ohms, use the Greek capital letter omega,
  `Ω`/[U+03A9](https://www.fileformat.info/info/unicode/char/03a9/index.htm) †
- Write `50 kibibytes` or `50 kiB`,
  using the base-2
  [ISO/IEC 80000 standard](https://en.wikipedia.org/wiki/Binary_prefix),
  which includes prefixes kibi- (Ki), mebi- (Mi), gibi- (Gi), tebi- (Ti), etc.
- You may use **either** `50%` (widely used) or `50 %` (NIST-recommended).
- For angles, omit a space before `°` as in `90°`.
- Prefer [decimal degrees notation](https://en.wikipedia.org/wiki/Decimal_degrees)
  – e.g. `90° 30′ 15″` – for longitude and latitude.
  Use no-break spaces
  (` `/[U+00A0](https://www.fileformat.info/info/unicode/char/00A0/index.htm)/`&nbsp;`),
  and proper symbols for
  prime
  (`′`/[U+2023](https://www.fileformat.info/info/unicode/char/2032/index.htm)/`&prime;`)
  and double prime
  (`″`/[U+2033](https://www.fileformat.info/info/unicode/char/2033/index.htm)/`&Prime;`).

<small>

<b>† Why U+00B5 micro and not U+03BC mu?</b>

Use the micro sign instead of the greek letter mu, but capital omega instead of the ohm sign.
From the
[Unicode spec, “Greek Letters as Symbols”](https://www.unicode.org/versions/Unicode16.0.0/core-spec/chapter-7/#G12477):

> For compatibility purposes, a few Greek letters are separately encoded as symbols in other character blocks.
> Examples include U+00B5 µ MICRO SIGN in the Latin-1 Supplement character block
> and U+2126 Ω OHM SIGN in the Letterlike Symbols character block.
> The ohm sign is canonically equivalent to the capital omega,
> and normalization would remove any distinction.
> <mark>[The Ohm sign's] use is therefore discouraged in favor of capital omega.</mark> > <mark>The same equivalence does not exist between micro sign and mu</mark>,
> and use of either character as a micro sign is common.

</small>

### Uncertainty measurements

State whether a value means standard error or standard deviation.
Do **not** write `5.0 ±0.1` – that’s ambiguous.
You may use the abbreviations _standard error (SE)_, _standard deviation (SD)_, and _confidence interval (CI)_,
or spell them out.

Use one of these formats:

- Standard error: _7.65 ±1.2 (SE)_
- Standard deviation: _7.65 ±0.54 (SD)_
- Confidence interval: _7.65 (4.0–12.5, 95% CI)_
- SE/SD with units: _(7.65 ±0.54) J·m⁻² (SD)_
- CI with units: _7.65 (4.0–12.5, 95% CI) J·m⁻²_
- CI with units (alt): _7.65 J·m⁻² (4.0–12.5, 95% CI)_
- CI with units (2nd alt): _7.65 J·m⁻² (4.0 to 12.5, 95% CI)_

### Dates and times

Use [RFC 3339](https://www.rfc-editor.org/rfc/rfc3339);
e.g. `2023-11-02T14:55:00-08:00`.
Note that the UTC offset is written with a hyphen, not a minus sign.
If a timezone is needed, use a _Canonical_ IANA timezone such as `America/Los_Angeles`,
and set it in square brackets after the UTC offset.
For example: `2023-11-02T14:55:00 -08:00 [America/Los_Angeles]`.

### Durations and intervals

For durations, use _8.3 s_.
`hr`, `min`, and `sec`/`s` are acceptable abbreviations, but `M` for minute is not.
`hh:mm:ss` (e.g. `12:30:55`) is generally ok,
but do **not** use `mm:ss` or `hh:mm` – these are ambiguous.
Also do **not** use the ISO 8601’s `P`/`PT` duration syntax (e.g. `PT45M55S`) in documentation.

### Filesystem paths and trees

Always use `/` as a path separator in documentation, and denote directories with a trailing `/`.

For filesystem trees, use
[Unicode box-drawing characters](https://www.w3.org/TR/xml-entity-names/025.html).
Refer to the
[research projects guide](../guide/research-projects.md/#example)
for an example.

### Accessibility

Use descriptive titles for link titles.

- **✅ Correct** `Refer to the [documentation conventions](documentation.md).`
- **❌ Incorrect** `Click [here](documentation.md) for conding conventions.`

## HTML

Follow the applicable guidelines from the Markdown section.

### Attributes

Use kebab-case for `id` and `name` values and for `data` keys and values.
Use the `alt` attribute for media elements, including `<img>`, `<video>`, `<audio>`, and `<canvas>`.

### Formatting

Use [Prettier](https://prettier.io/) with default options except for line length, which must be 120.
Note that Prettier wraps tags in way that looks strange at first;
it does that to avoid adding extra whitespace.

#### Closing tags

Always include the `<html>`, `<head>`, and `<body>` elements.
Also, always close tags – for example, use `<p>The end.</p>`, **not** `<p>The end.`.

These two practices improve readability and massively simplify parsing.
The rules for
[omitting `<html>`, etc.](https://html.spec.whatwg.org/#syntax-tag-omission)
are also complex and better ignored.

## Formal grammars

Grammars may be specified in any well-defined meta-grammar.
Specify the syntax used.

Notable good options:

- [ABNF](https://en.wikipedia.org/wiki/Augmented_Backus%E2%80%93Naur_form)
  (per [RFC 5234](https://datatracker.ietf.org/doc/rfc5234/))
- The [meta-grammar defined in the XML spec](https://www.w3.org/TR/xml/#sec-notation)
- [regex-BNF](../spec/regex-bnf.md)

With ABNF, avoid the incremental alternatives notation (`=/`).
Because this modifies an already-defined rule, it complicates reading.
Also avoid the core rules `CHAR`, `LWSP`, `CTL`, `VCHAR`, and `WSP`,
which are misleading because they are restricted ASCII.

[`IEC`]: International Electrotechnical Commission
