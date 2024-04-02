# Documentation conventions

### Summary points / highlights

These guidelines are aggressive and lengthy (more than originally intended).
Skip the details gloss over the details.
Here are the important points.

<b>Filenames:</b>

- Use _lowercase-kebab-case_, limiting characters to `[a-z0-9-]`.
- Use `LICENSE.txt` over `LICENSE` and `config.yaml` over `config.yml`.

<b>Language:</b>

- Keep language simple, and be explicit.
- Sometimes an example is sufficient.

<b>Markdown:</b>

- Start a new line for every sentence (it helps with diffs).
- Limit lines to 120 characters, breaking before puncutation where possible.
- Use `**bold**` for emphasis, `_italics_` as the
  [`<i>` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/i),
  and `<b></b>` for non-emphasized but bold text; e.g. `<b>Score:</b> 12.5`.

<b>Comments:</b>

- Forgo comments that are superfluous or included out of habit or convention.

## Filenames

!!! tip

    This section can apply to naming of URI nodes, database IDs, and similar constructs.
    These are general guidelines: Alternatives should be used in some situations.
    For example, if camelCase is used in your JSON Schema, use camelCase for schema document filenames.

??? rationale

    The [official YAML extension is `.yaml`](https://yaml.org/faq.html).
    Moreover, the IANA media types are `application/yaml`, `text/html`, and `image/jpeg`.
    `.yml`, `.htm`, and `.jpg` are relics of DOS.
    Extensions are required because provide useful information; ommitting them can cause confusion.
    For example, a file named `info` could be a plain-text info document or a shell script that writes the info.
    Instead, write it as `info.txt` or `info.sh`.

Prefer kebab-case (e.g. `full-document.pdf`), treating `-` as a space.
Restrict to `-`, `.`, `[a-z]`, and `[0-9]`, unless there is a compelling reason otherwise.
If necessary, `--`, `+`, and `~` can be used as specialized word separators.
For example, `+` could denote join authorship in `mary-johnson+kerri-swanson-document.pdf`.

Always use one or more filename extensions, except for executable files;
e.g. `LICENSE.txt` or `LICENSE.md`, **not** `LICENSE`.
Where possible, use `.yaml` for YAML, `.html` for HTML, and `.jpeg` for JPEG.
In particular, **do not** use `.yml`, `.htm`, `.jpg`, or `.jfif`.

## Comments

Comments must be maintained like all other elements of code.
Avoid unnecessary comments, such as those added out of habit or ritual.
Forgo comments that are obvious or otherwise unhelpful.

??? example

    === "❌ Incorrect"

        ```python
        from typing import Self, TypeVar


        class SpecialCache:
            """
            Soft cache supporting the Foobar backend.
            Uses a Least Recently Used (LRU) policy with an expiration duration.
            """

            def get_cache_item(self: Self, key: str) -> T:
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

        1. This docstring serves no function.

    === "✅ Correct"

        ```python
        from typing import Self, TypeVar


        class SpecialCache:
            """
            Soft cache supporting the Foobar backend.
            Uses a Least Recently Used (LRU) policy with an optional expiration duration.
            """

            def get_cache_item(self: Self, key: str) -> T:
                return self._items[key]
        ```

## Language and grammar

!!! tip

    Apply these guidelines to both comments and documentation.

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

??? example "Examples"

    | ❌ Avoid                        | ✅ Preferred    |
    |--------------------------------|----------------|
    | _utilize_                      | _use_          |
    | _due to the fact that_         | _because_      |
    | _a great number of_            | _many_         |
    | _is able to_                   | _can_          |
    | _needless to say_              | (omit)         |
    | _it is important to note that_ | _importantly,_ |

Great documentation should not win poetry awards.
Keep things simple and direct.

### Spelling

??? rationale

    American English is the [most widespread dialect](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5969760/),
    and it generally has more phonetic and shorter spellings.

Use American English spelling.

### Grammar and punctuation

Use 1 space between sentences.

Use sentence case for titles and table headers (e.g. _This is a title_).
Capitalize the first word after a colon only if it begins a complete sentence;
do not capitalize the first word after a semicolon.

## Markdown

!!! tip

    Where applicable, apply these guidelines to other documentation, not just Markdown.

### Line breaks

??? rationale

    Keeping each sentence on its own line dramatically improves diffs.

**Start a new line for each sentence.**

If needed to prevent a line from exceeding 120 characters, add line breaks elsewhere.
Look for one of these places to add a line break, in order:

1. before a Markdown link
2. After a colon, semicolon, or dash (` – `)
3. After a comma that begins an independent clause
4. After any other punctuation
5. Before an opening HTML tag (or Markdown equivalent) or after a closing tag
6. At any other natural place

<small>
<b>Notes:</b>

- Add line breaks wherever you think they are helpful for items 1–4;
  e.g. before each item of an inline list (i.e. before `(1)`).
- You may leave a series of very short sentences on one line; e.g. `Be smart. Be fast. Be good.`.
</small>

### Text styles and semantics

??? summary "Semantic HTML elements"

    Some semantic HTML elements are result in identical styles (in most browsers).
    This table summarizes how to use them in HTML and in Markdown.

	| element | style   | usages | equivalent Markdown |
	| ------- | ------- | ------ | ------------------- |
	| [`em`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/em) | italic | emphasis; [stress](https://en.wikipedia.org/wiki/Stress_(linguistics)) | `<em>text</em>` (prefer bold) |
    | [`i`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/i) | italic | technical terms; foreign text; more | `_text_` |
	| [`var`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/dfn) | italic | terms being defined | `_term_` or `<dfn>term</dfn>` |
	| [`var`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/var) | italic | variables | `$var$` |
	| [`strong`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/strong) | bold | strong emphasis | `**text**` |
	| [`b`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/b) | bold | keywords, miscellaneous | `<b>text</b>` |
	| [`code`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/code) | monospace | source code | ``` `code` ``` |
	| [`samp`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/samp) | monospace | sample output  | ``` `code` ``` |
	| [`kbd`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/kbd) | monospace | keyboard keys | `<kdb>keys</kbd>` |

#### Italics

Take `_`/`_` (and `*`/`*`) as semantically equivalent to the
**[`<i>` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/i)**.

**Uses of `_`/`_`:**

- Foreign words, technical terms, etc.
- Non-semantic references (words/phrases themselves, not their meanings).
- Single quotation marks (`‘`/`’`) are also acceptable.

**Non-uses of `_`/`_`:**

- Ubiquitous foreign phrases like _in vivo_, _in sitro_, _in silico_, and _et al._
- _Emphasis_ (i.e. importance).
- _Stress_ (e.g. to distinguish `<<I>> will go there` and `I will go <<there>>`.).
  Instead, consider making the exact meaning explicit by rephrasing; e.g.
  `I (specifically) will go there.`
  Keep in mind that screen readers may not announce the italicization.

**`<em>`:**

Italics are _occasionally_ helpful for emphasis or stress.
If needed, use an explicit [`<em>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/);
e.g. `I will go <em>there</em>`.

**`<dfn>`**
Using the [`dfn` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/)
in Markdown is good practice.
`_`/`_` is an acceptable substitute.

#### Bold

**Use `**`/`**` bold for emphasis.**
Take `**`/`**` as semantically equivalent to the
**[`<strong>` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/strong)**.

Use the [`<b>` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/b) explicitly
rather than `**`/`**` for text that should be bold but not emphasized –
i.e. semantically distinct from the surrounding text.
For example, you might write `<b>Score:</b> 55.3%`.

#### Code and math

!!! tip

    With the Material for mkdocs
    ["Smarty" plugin](https://squidfunk.github.io/mkdocs-material/reference/formatting/#adding-keyboard-keys),
    you can use `++`/`++` instead of `<kdb>`/`<kdb>`; e.g. `++ctrl+alt+del++`.

Use backticks for code, `<kbd>`/`</kdb>` for keyboard keys,
and LaTeX (`$`/`$`) for variables and mathematical expressions.
To describe menu navigation, use [`➤`](https://www.compart.com/en/unicode/U+27A4) without markup; e.g.
File ➤ Export ➤ Export as Text.

### Encoding

Write most non-ASCII characters as-is, not with entity references.
For example, write an en dash as `–`, not `&#x2013;`.

<b>Exceptions:</b>

Use hexadecimal entity references for

- non-space whitespace characters; and
  (such as [no break space](https://www.compart.com/en/unicode/U+00A0), `&nbsp;`); and
- punctuation that is highly likely to confuse anyone reading the source code
  (such as [soft hyphen](https://www.compart.com/en/unicode/U+00ad), `&#x00ad;`); and
- characters that must be escaped for technical reasons

### Unicode characters

!!! tip

    With the Material for mkdocs
    [“Smarty” plugin](https://python-markdown.github.io/extensions/smarty/),
    you can use use `'` and `"` for quotation marks,
    `--` for en dashes, `---` for em dashes, and `...` for ellipses.

Use the correct Unicode characters for punctuation.

??? example "Examples"

    - `’` for apostrophes
    - `‘`, `’`, `“`, and `”` for quotation marks
    - `–` (_en dash_) for numerical ranges (e.g. `5–10`)
    - `—` (_em dash_) to separate a blockquote and its source
    - `‒` (_figure dash_) in numerical formatting
    - `…` (_ellipses_)
    - `−` (_minus sign_)
    - `µ` (_micro sign_)

<small>However, use regular _hyphen-minus_ (U+002D) for hyphens, **not** _hyphen_ (U+2010).</small>

### Punctuation (prescriptive grammar)

Use an en dash surrounded by spaces (` – `) to mark breaks in thoughts, **not** an em dash.
For example:

```markdown
An en dash – in contrast to an em dash – should be used here.
```

For _i.e._ and _e.g._, skip the comma (British English) and normally introduce with _;_,.
For example: `say something nice; e.g. “nice boots”.`.

### Abbreviations

Use the
[`<abbr>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/abbr)
HTML tag with the `title` attribute in Markdown.
For the first appearance, consider writing it out in this format: _Public Library of Science (PLOS)_.
Omit periods (`.`) for initialisms; e.g. _USA_, not _U.S.A._.

<small>
† Note that the correct abbreviation for <abbr title="Public Library of Science">PLOS</abbr>
is <i>PLOS</i>, <strong>not</strong> <i>PLoS</i>.
</small>

### Admonitions

[Material for mkdocs](https://squidfunk.github.io/mkdocs-material/) supports
[admonitions](https://squidfunk.github.io/mkdocs-material/reference/admonitions/).
Use them for content that either:

- is offset/apart/distinct from the surrounding text
  (i.e. like the [`<aside>` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/aside));
- <em>describes</em> the content itself; or
- content that many readers should skip (do this sparingly).

### Footnotes

??? rationale

    These symbols are easily recognized as indicating footnotes, whereas superscript numbers could be confused
    with reference numbers or even exponents in some places.
    They are more accessible than superscript symbols for people who are vision-impaired.
    (The pilcrow is excluded because it is too thick/prominent.)

Unless the Markdown flavor handles footnotes in another way, follow this format:

```markdown
This statement is false.

<small>† Note that this is a contradictory statement.</small>
```

Use these symbols, in order: `†` (dagger), `†` (double dagger), `§` (section mark), `♯` (paragraph mark),
`♯` (musical sharp), `𝄮` (musical neutral), `𝄽` (musical rest).
Other schemes, such as superscript numbers or letters, may sometimes be acceptable alternatives.

### Quotations

??? rationale

    This preserves the semantic difference between punctuation _inside_ and _outside_ of quotations.
    This rule is always followed when using code in backticks, anyway.
    A colon is a visual signal that the prose goes with its following code block, reducing refactoring mistakes.

Place punctuation outside of quotation marks (British-style rules).
For example:

```markdown
Also write ‘hard’, ‘difficult’, or ‘strenuous’.
```

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

    Here, a colon is appropriate:

    ```markdown
    Mark Twain also said:

    > When in doubt‚ tell the truth.
    > This is a blockquote, which is ordinarily introduced by punctuation.
    > For clarity, we introduce such blockquotes with colons.
    > _— Mark Twain_
    ```

### Inline lists (enumerations)

For inline lists, follow this format:

(1) Use `(1)`, `(a)`, or `(i)`;
(2) use commas or semicolons;
(3) start a line for each item;
(4) include `and`, `or`, or `nor` at the end of the line; and
(5) end the last line with `.` (or other appropriate punctuation).

### Quantities

??? rationale

    This is the format that
    [IEEE recommends](https://www.ieee.org/content/dam/ieee-org/ieee/web/org/conferences/style_references_manual.pdf).

- A period (`.`) as the decimal marker
- A narrow no break space, ` ` (NNBSP / U+002D / `&#x202f;`) as the thousands separator
- A full space (` `) to separate magnitude and units

**✅ Preferred** `1 024.222 222 µm` (result: 1 024.222 222 µm)

**🟨 Acceptable** `1024.222222 µm` (result: 1024.222222 µm)

**❌ Not acceptable** `1,024.222222 µm` or `1.024,222222 µm`

Preferably, write units using decimal dot (`·`, [U22C5](https://www.compart.com/en/unicode/U+u22c5)).

**✅ Preferred** `5.4 kg·m²·s⁻²` (result: 5.4 kg·m²·s⁻²)

**🟨 Acceptable** `5.4 kg m^2 / s^2` (result: 5.4 kg m^2 / s^2)

**❌ Not acceptable** `5.4 kg m^2 /s^2` (result: 5.4 kg m^2 / s^2)

<b>Note:</b>
You can use inline LaTeX (`$`/`$`) to format dimensioned values instead.
E.g., `5.4 kg m^2 s^{-2}`.
Preferably, use [siunitx](https://ctan.org/pkg/siunitx) with
`mode=match,reset-math-version=false,reset-text-family=false`.

### Uncertainty measurements

State whether the values refer to standard error or standard deviation.

<b>Abbreviations:</b>

- _SE_: standard error
- _SD_: standard deviation

Examples:

- > 7.65 (4.0–12.5, 95% confidence interval)
- > 7.65 ±1.2 (SE)

**❌ Do not** just write the uncertainty without explanation, e.g. `5.0 ±0.1` – it is ambiguous.

**✅ Do** describe how the uncertainty was estimated (i.e. a statistical test).

### Dates and times

Use [RFC 3339](https://www.rfc-editor.org/rfc/rfc3339).
For example: `2023-11-02T14:55:00-08:00`.
Note that the UTC offset is written with a hyphen, not a minus sign.
If a timezone is needed, use a recognized IANA timezone such as `America/Los_Angeles`,
and set it in square brackets.
The UTC offset must still be included.
For example: `2023-11-02T14:55:00 -08:00 [America/Los_Angeles]`.

### Durations and intervals

For durations, use, e.g., _8.3 s_.
`hr`, `min`, and `sec`/`s` are acceptable abbreviations, whereas `M` for minute is not.
(Avoid ISO 8601 durations (e.g. _PT45M55S_) in documentation.)

### Paths and filesystem trees

Always use `/` as a path separator in documentation, and denote directories with a trailing `/`.

For filesystem trees, use Unicode box-drawing characters.
Refer to the
[research projects guide](https://dmyersturnbull.github.io/guide/research-projects/#example)
for an example.

### Accessibility

Use descriptive titles for link titles.

**❌** `Click [here](documentation.md) for conding conventions.`

**✅** `Refer to the [documentation conventions](documentation.md).`

## HTML

Follow the applicable guidelines from the Markdown section.

### Attribute values

Use kebab-case for `id` and `name` values and for `data` keys and values.

Skip the `type` attribute  for scripts and stylesheets.
Instead, use `<link rel="stylesheet" href="..." />` for stylesheets
and `<script src="..." />` for scripts.

### Accessibility

Use the `alt` attribute for media elements, including `<img>`, `<video>`, `<audio>`, and `<canvas>`.

### Formatting

Use [Prettier](https://prettier.io/) with default options except for line length, which must be 120.

!!! note

    Prettier wraps tags in way that looks strange at first.
    It does that to avoid adding extra whitespace.

#### Closing tags

??? rationale

    Requiring closing tags (and trailing slashes, which Prettier will add)
    improves readability and simplifies parsing.

Always close tags.
For example, use `<p>The end.</p>`, **not** `<p>The end.`.

#### `<html>`, `<head>`, and `<body>` elements

??? rationale

    The rules for
    [ommitting `<html>`, `<head>`, and `<body>`](https://html.spec.whatwg.org/#syntax-tag-omission)
    are complex and better ignored.

Always include these elements.
