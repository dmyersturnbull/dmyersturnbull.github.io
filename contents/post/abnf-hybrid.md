# ABNF hybrid

Standards for specifying grammars are a mess, as [Wirth et al. describe](https://dl.acm.org/doi/10.1145/359863.359883).
David A. Wheeler also wrote a [lengthy complaint](https://dwheeler.com/essays/dont-use-iso-14977-ebnf.html),
particularly objecting to [ISO’s EBNF (ISO/IEC 14977:1996)](https://www.iso.org/standard/26153.html).
[ABNF (RFC5234)](https://datatracker.ietf.org/doc/html/rfc5234) is an improvement,
but it doesn’t use regex and has a non-obvious syntax for repetitions.
[XML’s custom meta-grammar](https://www.w3.org/TR/xml/#sec-notation) is even better,
but it still lacks expressiveness that regex can provide.

So, I made my own standard as per [XKCD #927](https://xkcd.com/927/).
It’s a hybrid between ABNF, XML’s meta-grammar ("XML-MG"), and syntax from parser generators,
including [ANTLR]() and [parboiled2]().
Use it to describe [PEGs]() and [CFGs]().

Compatible with either ABNF or XML-MG, and supports full regex.

## Example

```
; A simple comment
/* A multiline
   comment.
*/
literal       = '"ab"'
              ; "ab"; use "'ab'" for 'ab'
              ; can also use ::= as in XML-MG
concatenation = literal 'de'
              ; or: literal . 'de'
alternation   = literal / 'xy'
              ; or literal | 'xy'
dot-regex     = .+
              ; one or more of any chars
simple-regex  = [^A-Z]{2,4}
              ;
complex-regex = `.+?xx\d`
              ; note the lazy match
grouping      = ('ab' / 'cd') 'xy'
set-minus     = .+ - 'abc'
              ; anything but 'abc'
complement    = (! 'abc')
              ; same as set-minus
unicode       = #5F028322
              ; or %0x for decimal
inline-label  = label-1 ([^ ]+)=my-label
expansion     = rule1 '+' rule2 ~~> rule1 '*' rule1
              ; an expression substitutes for another
```

## Grammar

The meta-grammar written in itself, probably with mistakes:

```text
grammar             = statement+
statement           = (START / LF+) (SP* comment? / rule-defn) (SP / LF)*

comment             =  1-line-comment / n-line-comment
1-line-comment      = ';' (! LF)*=comment
n-line-comment      = '/*' (`.*` - '*/')=comment '*/'

rule-defn           = rule-name def-symbol rule-rhs expansion?
def-symbol          = SP+ ('=' / ':==') SP+
rule-rhs            = (SP* NL)+ SP+ rule-rhs / expr-line
expr-line           = group-expr / term
expansion           = (NL SP{2,})? '~~>' expansion-expr
expansion-expr      = ( (.+ - '$' DIGIT+)*? / ('$' DIGIT+)=param )+

group-expr          = group / repeated-group / labeled-group
repeated-group      = group repeat-expr
labeled-group       = group simple-repeat-expr? inline-label
term-expr           = term repeat-expr?
inline-label        = '=' rule-name

group               = parenthesized / complement
parenthesized       = '(' SP* rule-expr SP* ')'
complement          = '(!' SP+ primitive ')'

term                = singleton / concatenation / exclusion / alternatation)
exclusion           = rule-expr SP+ '-' rule-expr
concatenation       = rule-expr SP+ '.' SP+ rule-expr
alternatation       = rule-expr SP+ [/|] SP+ rule-expr

repeat-expr         = repeat ('?')?=lazy
repeat              = simple-repeat / exact-repeat / min-repeat / max-repeat / range-repeat
exact-repeat        = '{' (DIGIT+)=count '}'
range-repeat        = '{' (DIGIT+)=min ',' (DIGIT+)=max '}'
min-repeat          = '{' (DIGIT+)=min ',}'
max-repeat          = '{,' (DIGIT*)=max '}'

simple-repeat-expr  = simple-repeat ('?')?=lazy
simple-repeat       = zero-or-one / zero-plus / one-plus
zero-or-one         = rule-expr '?'
zero-plus           = rule-expr '*'
one-plus            = rule-expr '+'

singleton           = rule-name / lexer-rule-name / primitive
primitive           = literal / escape / unicode-escape / unicode-name / regex

literal             = DQUOTE [^"]+ DQUOTE / SQUOTE [^']+ SQUOTE
unicode-escape      = ('#' HEXDIG{1,8}) / '%x' HEX{2}
unicode-name        = '#:' [A-Za-z0-9,/()-,]+ ':'
escape              = ('\t')=tab / ('\n')=line-feed / ('\r)=carriage-return

regex               = bracket-regex / dot-regex / tick-regex
bracket-regex       = '[' [^ ]]+? ']'
dot-regex           = '.'  repeat-expr
tick-regex          = TICK ('``' / (.* - TICK{2} - SP))+ '`'

rule-name           = [a-z0-9]+(-[a-z0-9]+)*
lexer-rule-name     = [A-Z0-9](-[A-Z0-9]+)*
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
ALPHA            = [A-Z]
ALPHANUM         = ALPHA | DIGIT
SQUOTE           = "'"
DQUOTE           = '"'
BIN-STR          = BIN+
OCT-STR          = OCTDIG+
HEX-STR          = HEXDIG+
ALPHA-STR        = ALPHA+
DIGIT-STR        = DIGIT+
ALPHANUM-STR     = (ALPHA / DIGIT)+
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
