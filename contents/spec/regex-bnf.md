# Advanced BNF with regex

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

<b>Spec status: Use with caution.</b>
Although useful, applying it in practice might cause confusion.
Take it, modify it, use it. (CC-BY-SA)

**An advanced BNF derivative.**

Standards for specifying grammars are a mess, as [Wirth et al. describe](https://dl.acm.org/doi/10.1145/359863.359883).
David A. Wheeler also wrote a
[complaint about current grammar standards](https://dwheeler.com/essays/dont-use-iso-14977-ebnf.html),
particularly objecting to [ISO’s EBNF (ISO/IEC 14977:1996)](https://www.iso.org/standard/26153.html).
[ABNF (RFC5234)](https://datatracker.ietf.org/doc/html/rfc5234) is an improvement,
but it doesn’t use regex and has a non-obvious syntax for repetitions.
The [W3C XML EBNF](https://www.w3.org/TR/xml/#sec-notation) is better,
but it still lacks some functionality and the expressiveness that regex can provide.

!!! tip "Tip: diagrams"

    A tool called the
    [Railroad Diagram Generator](https://www.bottlecaps.de/rr/ui)
    can generate excellent diagrams from W3C XML EBNF.
    It’s maintained as of early 2025.

In the spirit of [XKCD #927](https://xkcd.com/927/), here is a new proposal.
It’s a hybrid between ABNF, W3C XML EBNF, and syntax from parser generators, including [ANTLR](https://www.antlr.org/).
Use it to describe
[PEGs](https://en.wikipedia.org/wiki/Parsing_expression_grammar)
and
[CFGs](https://en.wikipedia.org/wiki/Context-free_grammar).

Most importantly, _regex-bnf_ supports full
[ECMA 262 regular expressions](https://tc39.es/ecma262/#sec-patterns).
It has additional, very powerful features, including

- intersection: `A & B`, where both rules consume the same input
- complement: `(! A)`, any sequence that does not match rule A
- exclusion: `A - B`, which requires that `B` rejects the input that `A` accepts
- exclusive disjunction: `A ^ B`, equivalent to `(A - B) | (B - A)`
- repetition: `A{5,10}`, rule A at least 5 times and at most 10

Rules can be declared with `=` (ABNF), `::=` (XML), or `:=`.
Similarly, inline `;` comments (ABNF) and `/* */` (XML) multiline comments are allowed.
For alternation, both `/` (ABNF) and `|` (XML) are supported,
but **`/` signals ordered choice** in contrast to `|`.
Always use `/` for PEGs.

As syntactic sugar, you can declare inline rules; e.g. `cmd = name (' --force')=force`.
You can also use some predefined rules, such as `ALPHA`, `BASE64`, and `RFC-3339-DATETIME`.
(The full list is shown further down.)

## Grammar

The formal grammar for regex-bnf is presented in both itself and in
[W3C XML EBNF](https://www.w3.org/TR/REC-xml/#sec-notation).

=== "in itself"

    ```text
    grammar         = statement+
    statement       = (START | LF+) (SP* comment? | rule-defn) (SP | LF)*
    comment         = ';' (! LF)*=comment-text

    rule-defn       = rule-name def-symbol rule-rhs
    func-defn       = rule-name arg-spec def-symbol rule-rhs
    def-symbol      = SP+ (`:?:?=`) SP+
    rule-rhs        = (SP* NL)+ SP+ rule-rhs | rule-expr
    rule-expr       = (group-expr | term) inline-label?
    arg-spec        = '(' rule-name (',' rule-name)* ')'

    inline-label    = '=' rule-name

    group-expr      = group quant-expr?
    group           = parenthesized | complement
    parenthesized   = '(' SP* rule-expr SP* ')'
    complement      = '(!' SP+ primitive ')'

    term            = singleton
                      | concatenation
                      | intersection
                      | exclusion
                      | ordered-alt
                      | unordered-alt
                      | exclusive-or
    concatenation   = rule-expr SP+ rule-expr
    intersection    = rule-expr SP+ '&' SP+ rule-expr
    exclusion       = rule-expr SP+ '-' SP+ rule-expr
    ordered-alt     = rule-expr SP+ '/' SP+ rule-expr
    unordered-alt   = rule-expr SP+ '|' SP+ rule-expr
    exclusive-or    = rule-expr SP+ '^' SP+ rule-expr

    quant-expr      = unit-quant
                      | exact-quant
                      | min-quant
                      | max-quant
                      | range-quant
    exact-quant     = '{' (DIGIT+)=count '}'
    range-quant     = '{' (DIGIT+)=min ',' (DIGIT+)=max '}'
    min-quant       = '{' (DIGIT+)=min ',}'
    max-quant       = '{,' (DIGIT*)=max '}'

    unit-quant-expr = rule-expr unit-quant modifier?
    unit-quant      = '?'=zero-or-one | '*'=zero-plus | '+'=one-plus
    modifier        = '?'=lazy | '+'=possessive

    singleton       = rule-name | primitive | regex

    regex           = bracket-regex | dot-regex | tick-regex
    bracket-regex   = '[' [^ ]]+? ']'
    dot-regex       = '.' quant-expr
                      ; Note: a single . MUST be enclosed in ``.
                      ; This avoids ambiguity with the ABNF's concatenation operator.
    tick-regex      = ``(`+)(?<pattern>[^`].*?[^`])(\1)``
                      ; Enclose in as many backticks as needed (ala Markdown).
                      ; The pattern <pattern> MUST NOT start or end with a backtick.
                      ; (Escape the backtick as \u0060 if needed.)

    primitive       = literal | unicode-escape | unicode-name
    literal         = `"[^"]++"` | `'[^']++'`
    unicode-escape  = '#'? `[0-9A-F]{1,8}+` | '%x' `[0-9A-F]{2}`
    unicode-name    = "#'" [A-Za-z0-9,/()-,]+ "'"
                      ; Example: #'Micro Sign'

    rule-name       = CORE-RULE-NAME | LEXER-RULE-NAME | MAIN-RULE-NAME
    CORE-RULE-NAME  = `@?[A-Z0-9]+(-[A-Z0-9]+)*`
                      ; A @ prefix MAY be used to mark core rules references.
    LEXER-RULE-NAME = `[A-Z0-9]+(-[A-Z0-9]+)*`
    MAIN-RULE-NAME  = `[a-z0-9]+(-[a-z0-9]+)*`
    ```

=== "in W3C XML EBNF"

    ```ebnf
    grammar         ::= statement+
    statement       ::= (START | [#x0d]) (' '* comment? | rule-defn | func-defn) [#x0d]*
    comment         ::= ';' comment-text
    comment-text    ::= [^#x0d]*

    rule-defn       ::= rule-name def-symbol rule-rhs
    func-defn       ::= rule-name arg-spec def-symbol rule-rhs
    def-symbol      ::= ' '+ ('::=' | '=' | ':=') ' '+
    rule-rhs        ::= (' '* #x0d)+ ' '+ rule-rhs | rule-expr
    rule-expr       ::= (group-expr | term) inline-label?
    inline-label    ::= '=' rule-name
    arg-spec        ::= '(' rule-name (',' rule-name)* ')'

    group-expr      ::= group quant-expr?
    group           ::= parenthesized | complement
    parenthesized   ::= '(' ' '* rule-expr ' '+ ')'
    complement      ::= '(!' ' '+ primitive ')'

    term            ::= singleton
                      | concatenation
                      | intersection
                      | exclusion
                      | ordered-alt
                      | unordered-alt
                      | exclusive-or
    concatenation   ::= rule-expr ' '+ rule-expr
    intersection    ::= rule-expr ' '+ '&' ' '+ rule-expr
    exclusion       ::= rule-expr ' '+ '-' ' '+ rule-expr
    ordered-alt.    ::= rule-expr ' '+ '/' ' '+ rule-expr
    unordered-alt   ::= rule-expr ' '+ '|' ' '+ rule-expr
    exclusive-or    ::= rule-expr ' '+ '^' ' '+ rule-expr

    quant-expr      ::= unit-quant
                      | exact-quant
                      | min-quant
                      | max-quant
                      | range-quant
    exact-quant     ::= '{' count '}'
    range-quant     ::= '{' min ',' max '}'
    min-quant       ::= '{' min ',}'
    max-quant       ::= '{,' max '}'
    count           ::= [0-9]+
    min             ::= [0-9]+
    max             ::= [0-9]+

    unit-quant-expr ::= rule-expr unit-quant modifier?
    unit-quant      ::= zero-or-one | zero-plus | one-plus
    modifier        ::= greedy | lazy | possessive
    zero-or-one     ::= '?'
    zero-plus       ::= '*'
    one-plus        ::= '+'
    greedy          ::= '*'
    lazy            ::= '?'
    possessive      ::= '+'

    singleton       ::= rule-name | primitive | regex
    primitive       ::= literal | unicode-escape | unicode-name

    literal         ::= '"' [^"]+ '"' | "'" [^']+ "'"
    unicode-escape  ::= ('#' HEX-UTF) | '%x' HEX HEX
    unicode-name    ::= "#'" [A-Za-z0-9,/()-,]+ "'"
    HEX-UTF         ::= HEX HEX? HEX? HEX? HEX? HEX? HEX? HEX?
    HEX             ::= [0-9A-F]

    regex           ::= bracket-regex | dot-regex | tick-regex
    bracket-regex   ::= '[' [^ ]+ ']'
    dot-regex       ::= '.'  quant-expr
    tick-regex      ::= '`' [^`]+ '`'
    /* Approximate! Cannot replicate this rule in W3C XML EBNF. */
    /* Enclose in as many backticks as needed (ala Markdown). */
    /* The pattern <pattern> MUST NOT start or end with a backtick. */
    /* (Escape the backtick as \u0060 if needed.) */

    rule-name       ::= CORE-RULE-NAME | LEXER-RULE-NAME | MAIN-RULE-NAME
    CORE-RULE-NAME  ::= '@'? [A-Z0-9]+ ('-' [A-Z0-9]+)*
    /* A @ prefix MAY be used to mark core rules references. */
    LEXER-RULE-NAME ::= [A-Z0-9]+ ('-' [A-Z0-9]+)*
    MAIN-RULE-NAME  ::= [a-z0-9]+ ('-' [a-z0-9]+)*
    ```

## Core rules

Where available, these match
[ABNF’s core rules](https://datatracker.ietf.org/doc/html/rfc5234#appendix-B.1).

```
URI                        = <per RFC 3986>
UTF-GRAPHIC                = `\p{L}|\p{LC}|\p{M}|\p{N}|\p{S}|\p{Zs}`
UTF-FORMAT                 = `\p{Cf}`
UTF-SURROGATE              = `\p{Cs}`
UTF-CONTROL                = `\p{Cc}`
UTF-SPACE                  = `\p{Zs}`
BACKSLASH                  = '\\'
BOOLEAN                    = 'true' | 'false'
OCTDIG                     = `[0-8]`
OCTET                      = OCTDIG{2}
DIGIT                      = [0-9]
BASE64                     = [A-Za-z0-9+/]
BASE64URL                  = [A-Za-z0-9-_]
ALPHA                      = [A-Za-z]
UPPERCASE                  = [A-Z]
LOWERCASE                  = [a-z]
HEXDIG                     = [0-9A-F]
LOWER-HEXDIG               = [0-9a-f]
ALPHANUM                   = ALPHA | DIGIT
SQUOTE                     = "'"
DQUOTE                     = '"'
RFC-3339-DATETIME          = `20\d\d-(12|11|[1-9])-(\d|[12]\d|3[01])\
                              T([01]\d|2[0-3])(:([0-5]\d|60)){2}\
                              (\.{3}|\.{6})?Z`
E-NOTATION-FLOAT           = LITERAL-FLOAT ('E' LITERAL-FLOAT)?
E-NOTATION-NONNEG-FLOAT    = LITERAL-NONNEG-FLOAT ('E' LITERAL-FLOAT)?
E-NOTATION-POSITIVE-FLOAT  = LITERAL-POSITIVE-FLOAT ('E' LITERAL-FLOAT)?
E-NOTATION-NONZERO-FLOAT   = LITERAL-NONZERO-FLOAT ('E' LITERAL-FLOAT)?
E-NOTATION-INT             = LITERAL-FLOAT ('E' LITERAL-FLOAT)?
E-NOTATION-NONNEG-INT      = LITERAL-NONNEG-INT ('E' LITERAL-NONNEG-INT)?
E-NOTATION-POSITIVE-INT    = LITERAL-POSITIVE-INT ('E' LITERAL-NONNEG-INT)?
E-NOTATION-NONZERO-INT     = LITERAL-NONZERO-INT ('E' LITERAL-NONNEG-INT)?
LITERAL-FLOAT              = '-'? DIGIT-STR ('.' DIGIT-STR)?
LITERAL-NONNEG-FLOAT       = DIGIT-STR ('.' DIGIT-STR)?
LITERAL-POSITIVE-FLOAT     = [1-9] DIGIT-STR ('.' DIGIT-STR)?
LITERAL-NONZERO-FLOAT      = '-'? [1-9] DIGIT-STR ('.' DIGIT-STR)?
LITERAL-INT                = '-'? DIGIT-STR
LITERAL-NONNEG-INT         = DIGIT-STR
LITERAL-POSITIVE-INT       = [1-9] DIGIT-STR
LITERAL-NONZERO-INT        = '-'? [1-9] DIGIT-STR
BIN-STR                    = BIN+
OCT-STR                    = OCTDIG+
HEX-STR                    = HEXDIG+
ALPHA-STR                  = ALPHA+
DIGIT-STR                  = DIGIT+
ALPHANUM-STR               = (ALPHA | DIGIT)+
BASE64-STR                 = BASE64+ '='{0,8}
BASE64URL-STR              = BASE64URL+ '='{0,8}
TICK                       = '`'
BIT                        = [01]
CRLF                       = CR LF
CR                         = '\r'
LF                         = '\n'
HTAB                       = '\t'
SP                         = ' '
```

## Example

```
literal-1     = ' "ab" '
                ; can also use ::= as in XML-MG
literal-2     = " 'ab' "
concatenation = literal-1 'defg'
alternation   = literal-1 | 'xy'
                ; slash is an alterative to |
intersection  = alternation & .{10}
                ; intersection of multiple rules!!
                ; 'intersection' must be exactly ' "ab" xyxyxy'
dot-regex     = .+
                ; regex starting with '.' need not be enclosed in ``
simple-regex  = [^A-Z]{2,4}
                ; regex starting with '[' need not be enclosed in ``
complex-regex = `.+? *\d`
                ; any regex can be enclosed in ``
grouping      = ('ab' | 'cd') 'xy'
complement    = (! 'abc')
                ; complement!!
                ; 'complement' is any text (0+ chars) except 'abc'
set-minus     = .+ - 'abc'
                ; exclusion!
                ; this is identical to 'complement' (above)
unicode-1     = #5F028322
unicode-2     = #'Plus-Minus Sign'
inline-label  = label-1 ([^ ]+)=my-label
                ; declare an inline rule, which can be used anywhere
```

## Style guide

- Use `=` instead of `::=`.
- Align the `=` at a generous column, with plenty of space to rename rules for clarity
  (or to add new rules, if the grammar is still being designed).
- Limit lines to 120 characters, breaking before `|` (preferably) or another operator as needed.
  On the continued line, put the operator on the same column as the `=`.
  The goal here is to limit the number of lines unnecessarily included in a diff.
- Align `;` comments to 2 characters after the `=`.
- Always use `-` to separate words in rule names.
