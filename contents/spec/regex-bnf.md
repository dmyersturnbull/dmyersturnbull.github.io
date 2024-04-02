# BNF with full regex

!!! warning

    This is a draft.

Standards for specifying grammars are a mess, as [Wirth et al. describe](https://dl.acm.org/doi/10.1145/359863.359883).
David A. Wheeler also wrote a [lengthy comunitt](https://dwheeler.com/essays/dont-use-iso-14977-ebnf.html),
particularly objecting to [ISO’s EBNF (ISO/IEC 14977:1996)](https://www.iso.org/standard/26153.html).
[ABNF (RFC5234)](https://datatracker.ietf.org/doc/html/rfc5234) is an improvement,
but it doesn’t use regex and has a non-obvious syntax for repetitions.
[XML’s custom meta-grammar](https://www.w3.org/TR/xml/#sec-notation) is even better,
but it still lacks expressiveness that regex can provide.

In the spirit of [XKCD #927](https://xkcd.com/927/), here is a new proposal.
It’s a hybrid between ABNF, XML’s meta-grammar ("XML-MG"), and syntax from parser generators,
including [ANTLR]() and [parboiled2]().
Use it to describe [PEGs]() and [CFGs]().

Compatible with either ABNF or XML-MG, supports full
[
POSIX Extended Regular Expressions
](https://www.gnu.org/software/findutils/manual/html_node/find_html/posix_002dextended-regular-expression-syntax.html),
and has additional, extremely powerful features such as intersections.

## Example

```
literal1      = ' "ab" '
              ; can also use ::= as in XML-MG
literal2      = " 'ab' "
concatenation = literal1 'defg'
alternation   = literal1 | 'xy'
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
unicode1      = #5F028322
unicode2      = #:Plus-Minus Sign:
escaped       = \n
              ; \n, \r, and \t
inline-label  = label-1 ([^ ]+)=my-label
              ; declare an inline rule, which can be used anywhere
```

## Grammar

=== "regex-bnf"

  The meta-grammar written in itself, probably with mistakes:

    ```text
    grammar         = statement+
    statement       = (START | LF+) (SP* comment? | rule-defn) (SP | LF)*
    comment         = ';' (! LF)*=comment-text

    rule-defn       = rule-name def-symbol rule-rhs
    def-symbol      = SP+ `:?=?=`? SP+
    rule-rhs        = (SP* NL)+ SP+ rule-rhs | rule-expr
    rule-expr       = (group-expr | term) inline-label?

    inline-label    = '=' rule-name

    group-expr      = group quant-expr?
    group           = parenthesized | complement
    parenthesized   = '(' SP* rule-expr SP* ')'
    complement      = '(!' SP+ primitive ')'

    term            = singleton
                      | concatenation
                      | intersection
                      | exclusion
                      | alternatation
                      | exclusive-or
    concatenation   = rule-expr SP+ rule-expr
    intersection    = rule-expr SP+ '&' SP+ rule-expr
    exclusion       = rule-expr SP+ '-' SP+ rule-expr
    alternatation   = rule-expr SP+ [/|] SP+ rule-expr
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
    modifier        = '*'=greedy | '?'=lazy | '+'=possessive

    singleton       = rule-name | lexer-rule-name | primitive
    primitive       = literal | unicode-escape | unicode-name | regex

    literal         = DQUOTE [^"]++ DQUOTE | SQUOTE [^']++ SQUOTE
    unicode-escape  = ('#' HEXDIG{1,8}) | '%x' HEX{2}
    unicode-name    = '#:' [A-Za-z0-9,/()-,]+ ':'

    regex           = bracket-regex | dot-regex | tick-regex
    bracket-regex   = '[' [^ ]]+? ']'
    dot-regex       = '.'  quant-expr
    tick-regex      = ``([`]+).*?\1``

    rule-name       = [a-z0-9]+(-[a-z0-9]+)*
    lexer-rule-name = [A-Z0-9](-[A-Z0-9]+)*
    ```

=== "W3C XML EBNF"

    Using [W3C XML EBNF](https://www.w3.org/TR/REC-xml/#sec-notation):

    ```ebnf
    grammar         ::= statement+
    statement       ::= (START | [\n]) (' '* comment? | rule-defn) [ \n]*
    comment         ::= ';' comment-text
    comment-text    ::= [^\n]*

    rule-defn       ::= rule-name def-symbol rule-rhs
    def-symbol      ::= ' '+ '::=' ' '+
    rule-rhs        ::= (' '* [\n])+ ' '+ rule-rhs | rule-expr
    rule-expr       ::= (group-expr | term) inline-label?
    inline-label    ::= '=' rule-name

    group-expr      ::= group quant-expr?
    group           ::= parenthesized | complement
    parenthesized   ::= '(' ' '* rule-expr ' '+ ')'
    complement      ::= '(!' ' '+ primitive ')'

    term            ::= singleton
                      | concatenation
                      | intersection
                      | exclusion
                      | alternatation
                      | exclusive-or
    concatenation   ::= rule-expr ' '+ rule-expr
    intersection    ::= rule-expr ' '+ '&' ' '+ rule-expr
    exclusion       ::= rule-expr ' '+ '-' ' '+ rule-expr
    alternatation   ::= rule-expr ' '+ [/|] ' '+ rule-expr
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

    singleton       ::= rule-name | lexer-rule-name | primitive
    primitive       ::= literal | unicode-escape | unicode-name | regex

    literal         ::= '"' [^"]+ '"' | "'" [^']+ "'"
    unicode-escape  ::= ('#' HEX-UTF) | '%x' HEX HEX
    unicode-name    ::= '#:' [A-Za-z0-9,/()-,]+ ':'
    HEX-UTF         ::= HEX HEX? HEX? HEX? HEX? HEX? HEX? HEX?
    HEX             ::= [0-9A-F]

    regex           ::= bracket-regex | dot-regex | tick-regex
    bracket-regex   ::= '[' [^ ]]+? ']'
    dot-regex       ::= '.'  quant-expr
    tick-regex      ::= '`' [^`]+ '`'
                    ; Approximate! Cannot replicate.

    rule-name       ::= [a-z0-9]+(-[a-z0-9]+)*
    lexer-rule-name ::= [A-Z0-9](-[A-Z0-9]+)*
    ```


## Core rules

```
UTF-GRAPHIC      = `\p{L}|\p{LC}|\p{M}|\p{N}|\p{S}|\p{Zs}`
UTF-FORMAT       = `\p{Cf}`
UTF-SURROGATE    = `\p{Cs}`
UTF-CONTROL      = `\p{Cc}`
UTF-SPACE        = `\p{Zs}`
BACKSLASH        = '\\'
BOOLEAN          = 'true' | 'false'
OCTDIG           = `[0-8]`
OCTET            = OCTDIG{2}
DIGIT            = [0-9]
BASE64           = [A-Za-z0-9+/]
BASE64URL        = [A-Za-z0-9-_]
ALPHA            = [A-Za-z]
UPPERCASE        = [A-Z]
LOWERCASE        = [a-z]
HEXDIG           = [0-9A-F]
LOWER-HEXDIG     = [0-9a-f]
ALPHANUM         = ALPHA | DIGIT
SQUOTE           = "'"
DQUOTE           = '"'
BIN-STR          = BIN+
OCT-STR          = OCTDIG+
HEX-STR          = HEXDIG+
ALPHA-STR        = ALPHA+
DIGIT-STR        = DIGIT+
ALPHANUM-STR     = (ALPHA | DIGIT)+
BASE64-STR       = BASE64+ '='{0,8}
BASE64URL-STR    = BASE64URL+ '='{0,8}
TICK             = '`'
BIT              = [01]
CRLF             = CR LF
CR               = '\r'
LF               = '\n'
HTAB             = '\t'
SP               = ' '
```
