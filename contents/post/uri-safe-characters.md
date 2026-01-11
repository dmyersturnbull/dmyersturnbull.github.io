---
tags:
  - HTTP
---

# URI-safe characters

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

This details exactly what characters must be percent-encoded in URIs.

!!! abstract "Highlights"

    Don’t percent-encode these characters in _query_ parameter values:
    `-`, `_`, `.`, `~`, `!`, `$`, `'`, `(`, `)`, `:`, `@`, `/`, `,`, `;`, `?`, and `=`.

    To parse query parameters, follow this table:

    | to match                       | use regex                   |
    |--------------------------------|-----------------------------|
    | full _query_ URI component     | `?[-\w.~!$'()*+:@/?;,&=]*+` |
    | form-urlencoded key            | `[-\w.~!$'()*+:@/,;?]++`    |
    | form-urlencoded value          | `[-\w.~!$'()*+:@/;,?=]*+`   |
    | OpenAPI _simple_-encoded value | `[-\w.~!$'()*+:@/;?=]*+`    |
    | OpenAPI _form_-encoded value   | same as _simple_-encoded    |
    | OpenAPI _matrix_-encoded value | `[-\w.~!$'()*+:@/?=]*+`     |

## The basics

### Relevant specifications

- [RFC 1738](https://datatracker.ietf.org/doc/html/rfc1738),
  “Uniform Resource Locators (URL)” (Proposed Standard, obsolete)
- [RFC 3986](https://datatracker.ietf.org/doc/html/rfc3986),
  “Uniform Resource Identifier (URI): Generic Syntax” (Internet Standard)
- [RFC 6920](https://datatracker.ietf.org/doc/html/rfc6920),
  “Naming Things with Hashes” (Proposed Standard)
- [RFC 6570](https://datatracker.ietf.org/doc/html/rfc6920),
  “URI Template” (Proposed Standard)
- [IANA-recognized URI schemes](https://www.iana.org/assignments/uri-schemes/uri-schemes.xhtml)

RFC 3986 is the main specification.
There is a **full grammar in
[RFC 3986 Appendix A](https://datatracker.ietf.org/doc/rfc3986/#appendix-A),
“Collected ABNF for URI”.**

### URI Components

[RFC 3986 §3](https://datatracker.ietf.org/doc/html/rfc3986#section-3)
defines 5 main URI _components_.

```text
        [                ]              [             ][          ] # (1)!
 https : // posts.tld:443   /info/users  ? name=carlie  # bulletin
╰─────╯    ╰─────────────╯ ╰───────────╯  ╰───────────╯  ╰────────╯
scheme        authority       path            query       fragment
```

1. Grouping of optional components.

??? info "Rules for _path_"

    The rules for _path_ are a bit complex.
    Although it MUST be present, it MAY be empty.
    (This is a very subtle distinction,
    but it contrasts with _authority_, _query_, and _fragment_, which can be omitted.)
    If _authority_ is present, _path_ MUST either be empty OR start with `/`
    (separating it from the _authority_).
    If _authority_ is omitted, _path_ MAY start with `/` but MUST NOT start with `//`.
    So, `https:/info/users`, `https:info/users`, `https:?name=charlie` are valid,
    but `https://info/users` is not.

??? example "Example: the `file` scheme"

    The `file` scheme,
    defined in [RFC 8089](https://datatracker.ietf.org/doc/html/rfc8089.html),
    only uses _scheme_, _path_, and the _host_ part of _authority_.
    _host_ can be empty, which is treated as `localhost`.

    ```text
           [                ]
     file : // 192.168.1.101   /usr/share/lib
    ╰────╯    ╰─────────────╯ ╰──────────────╯
    scheme       authority         path
    ```

### General delimiters and sub-delimiters

[RFC 3986 §2.2](https://datatracker.ietf.org/doc/html/rfc3986#section-2.2)
splits reserved characters into two sets, **`gen-delims`** and **`sub-delims`**:

```abnf
gen-delims  = ":" / "/" / "?" / "#" / "[" / "]" / "@"
sub-delims  = "!" / "$" / "&" / "'" / "(" / ")" / "*" / "+" / "," / ";" / "="
unreserved  = ALPHA / DIGIT / "-" / "." / "_" / "~"
```

- `General delimiters`:
  Separate components or subcomponents (_userinfo_, _host_, _port_).
  They must be encoded in components where their reserved meanings would apply.
  For example, `:` must be encoded in _authority_ but not _query_;
  e.g. `https://api.tld/a:b:c` is valid.
- `Sub-delimiters`:
  Are used reserved within one or more components but are not general delimiters.
  Whether they must be encoded depends on the component and the scheme.

!!! note "Caution: scheme-specific restrictions"

    A scheme can restrict URIs in many ways, including whether a sub-delimiter must be encoded.
    (In fact, §2.2 states that you should encode a reserved character
    unless the scheme specifically allows it.)
    The following section was written for HTTPS.
    It’s valid for some other schemes, but your mileage may vary.

### Where reserved delimiters are allowed

The following tables show the components in which a reserved delimiter
can be used for its literal meaning without percent-encoding.
Note that `%` must also be encoded.

| component | `:` | `/` | `?` | `#` | `[` | `]` | `@` |
|-----------|-----|-----|-----|-----|-----|-----|-----|
| scheme    |     |     |     |     |     |     |     |
| authority | ¹   |     |     |     |     |     |     |
| path      | y²  |     |     |     |     |     | y   |
| query     | y   | y   | y   |     |     |     | y   |
| fragment  | y   | y   | y   | ³   |     |     | y   |

/// table-caption
<b>General delimiters (_y_ where valid)</b>
///

??? info "Footnotes"

    - <b>¹</b> Technically, `:` is allowed in _userinfo_ and carries no reserved meaning.
      However, this is only for compatibility with a `username:password` syntax,
      which is deprecated.

    - <b>²</b>
      Literal `:` is valid in _path_, except as the first character in a
      [URI Reference](https://datatracker.ietf.org/doc/html/rfc3986#section-4.1) without _scheme_
      (e.g. `https://google.com/:` but `google.com/:` is not).

    - <b>³</b> Perhaps surprisingly, fragments cannot contain `#`.
      This is in contrast to `?`, which can occur in _query_ components.

| component | `!` | `$` | `'` | `(` | `)` | `*` | `&` | `=` | `,` | `;` | `+` |
|-----------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| authority | y   | y   | y   | y   | y   | y   | y   | y   | y   | y   | y   |
| path      | y   | y   | y   | y   | y   | y   | y   | y   | y   | y   | y   |
| query     | y   | y   | y   | y   | y   | y   | y¹  | y¹  | y³  | y³  | y²  |
| fragment  | y   | y   | y   | y   | y   | y   | y   | y   | y   | y   | y   |

/// table-caption
<b>Sub-delimiters (_y_ where valid)</b>
///

??? info "Footnotes"

    - <b>¹</b> `&` and `=` are typically used for key–value parameters.

    - <b>²</b> `,` and `;` are delimiters for some
      [OpenAPI query parameter _styles_](https://spec.openapis.org/oas/v3.2.0.html#style-values):

      - _`simple` and `form` use `,`
      - `matrix` and `cookie` use `,` and `;`

      (Note that `cookie` actually uses `; `.
      `label` uses `.`, which is unreserved;
      and `spaceDelimited`, and `pipeDelimited` use ` ` and `|`, which must be percent-encoded.)

    - <b>³</b> `+` is used in place of a space in
      [`x-www-form-urlencoded`](https://url.spec.whatwg.org/#application/x-www-form-urlencoded),
      as used in HTML forms.

## The _query_ component

RFC 3986 buries some important details,
including aspects that many implementations handle incorrectly.

### From the ABNF

Tracing through the ABNF definitions for `query` yields this:

```abnf
query           = *( pchar / "/" / "?" )
pchar           = unreserved / pct-encoded / sub-delims / ":" / "@"
unreserved      = ALPHA / DIGIT / "-" / "." / "_" / "~"
pct-encoded     = "%" HEXDIG HEXDIG
sub-delims      = "!" / "$" / "&" / "'" / "(" / ")" / "*" / "+" / "," / ";" / "="
```

Which is equivalent to:

```abnf
query  = ALPHA / DIGIT                                                    ; from `unreserved`
       / "-" / "." / "_" / "~"                                            ; also from `unreserved`
       / "!" / "$" / "&" / "'" / "(" / ")" / "*" / "+" / "," / ";" / "="  ; from `sub-delims`
       / ":" / "@"                                                        ; from `pchar`
       / "/" / "?"                                                        ; from `query`
       / "%" HEXDIG HEXDIG                                                ; from `pct-encoded`
```

And to this regex (using the inline _verbose_ flag, `(?x)`):

```regexp
(?x)
[A-Za-z0-9] | [-._~] | [!$&'()*+,;=] | [:@] | [/?]
|
%[A-Fa-f0-9]{2}
```

And, when no percent-encoding is used, to
`[-\w.~!$&'()*+,;=:@/?]`.

### Yes, `/` and `?` are allowed

RFC 3986 says this about query strings:

> The characters slash ("/") and question mark ("?") may represent data within the query component.
> Beware that some older, erroneous implementations may not handle such data correctly […]

[RFC 6920 §3](https://datatracker.ietf.org/doc/rfc6920/#section-3),
“Naming Things with Hashes” affirms these conclusions:

> […] percent-encoding is used to distinguish between reserved and unreserved functions
> of the same character in the same URI component.
> As an example, an ampersand ('&') is used in the query part to separate attribute-value pairs;
> therefore, an ampersand in a value has to be escaped as '%26'.
> Note that the set of reserved characters differs for each component.
> As an example, a slash ('/') does not have any reserved function in a query part
> and therefore does not have to be escaped.

### There are no HTTP-specific restrictions

Ok, fine.
Technically, RFC 3986 also says:

> RFC 3986 excludes portions of
> [RFC 1738](https://www.rfc-editor.org/rfc/rfc1738)
> that defined the specific syntax of individual URI schemes;
> those portions will be updated as separate documents.

Fortunately, the HTTP-specific part of RFC 1738 states (where `(<searchpart>` means `query`):

> Within the <path> and <searchpart> components, "/", ";", "?" are reserved.
> The "/" character may be used within HTTP to designate a hierarchical structure.

That means there is no HTTP-specific ban on our `sub-delims`, either.

## _query_ component parameters

Queries often follow more structure by convention and some standards.
Passing key–value pairs in URIs is elegant, but the standards are a mess.
In their document for
[`x-www-form-urlencoded`](https://url.spec.whatwg.org/#application/x-www-form-urlencoded),
WHATWG writes:

> The application/x-www-form-urlencoded format is in many ways an aberrant monstrosity,
> the result of many years of implementation accidents and compromises
> leading to a set of requirements necessary for interoperability,
> but in no way representing good design practices.

!!! note "Note: WHATWG"

    _WHATWG_ is not in the habit of writing short, precise docs for their specs.
    To describe a [“URL string”](https://url.spec.whatwg.org/#valid-url-string),
    at no point are we shown a formal grammar.
    Instead, we get 20 pages of “basic URL parser” and “URL serializing” algorithms.

Note that OpenAPI's query parameter styles reference
[RFC 6570](https://datatracker.ietf.org/doc/html/rfc6920),
**not** the `x-www-form-urlencoded` used in HTML5.

#### Key–value pairs

This ABNF grammar recognizes a _query_ component and captures its key–value parameters.
I’ve chosen to disallow empty values.

```abnf
query    = '?' param *('&' param)
param    = key '=' value
key      = 1*(LITERAL / ESCAPE)
value    = 1*(LITERAL / ESCAPE / '=')
LITERAL  = ALPHA / DIGIT / "-" / "." / "_" / "~"
         / "!" / "$" / "'" / "(" / ")" / "*" / "+" / "," / ";"  ; removed `&` and '='
         / ":" / "@" / "/" / "?"
ESCAPE   = '%' 2HEXDIG
```

## Implementation considerations

### Some implementations encode more than needed

Many `urlencode` implementations will encode characters that don’t need to be encoded.

This is because the 1994
[RFC 1738](https://datatracker.ietf.org/doc/html/rfc1738) for URLs,
which RFC 3986 obsoletes, had this language

> Thus, only alphanumerics, the special characters "$-\_.+!\*'(),",
>, and reserved characters used for their reserved purposes may be used unencoded within a URL.

RFC 3986 instead says

> If data for a URI component would conflict with a reserved character’s purpose as a delimiter,
> then the conflicting data must be percent-encoded before the URI is formed.

Smart URI `urlencode` implementations could be introduced under new names such as `uriencode`
without breaking backwards compatibility.
Maintainers, get on this.

### Normalization of full URIs

As
[@mgiuca points out](https://unspecified.wordpress.com/2012/02/12/how-do-you-escape-a-complete-uri/),
full URIs cannot be normalized (ala `urlencode`) reliably
because they cannot be partitioned into their components unambiguously.

Examples:

- `https://api.tld/redirect?uri=https://boeing.fly/news?page2&nav=yes`
  Is the redirect to `https://boeing.fly/news?page2&nav=yes`
  or to `https://boeing.fly/news?page2?page2`?
- `https://api.tld/redirect?uri=https://boeing.fly/news#ex`
  Is the redirect to `https://boeing.fly/news#ex`
  or to `https://boeing.fly/news`?

Instead, normalize each URI component separately.

!!! bug "Functions to avoid"

    Avoid these library functions, which return incorrect results for some URIs:

    - [Python `urllib.parse.quote`](https://docs.python.org/3/library/urllib.parse.html)
    - [JavaScript encodeURI](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURI)

### OpenAPI

You should set `allowReserved: true` for
[OpenAPI _parameter_ objects](https://spec.openapis.org/oas/v3.1.1.html#parameter-object).
There is no reason not to.
As described earlier, also be aware that `style` controls whether additional characters must be encoded.

## Full ABNF from RFC 3986

The following are the ABNF lines, copied in order, from
[RFC 3986](https://datatracker.ietf.org/doc/html/rfc3986#appendix-A).
Only minor formatting changes were made (specifically line breaks, indentation, and comments).

```abnf
; ---------------------------  characters  ---------------------------------------------------------

pct-encoded     = "%" HEXDIG HEXDIG
reserved        = gen-delims / sub-delims
gen-delims      = ":" / "/" / "?" / "#" / "[" / "]" / "@"
sub-delims      = "!" / "$" / "&" / "'" / "(" / ")" / "*" / "+" / "," / ";" / "="
unreserved      = ALPHA / DIGIT / "-" / "." / "_" / "~"

; ---------------------------  URI structure  ------------------------------------------------------

URI             = scheme ":" hier-part [ "?" query ] [ "#" fragment ]

hier-part       = "//" authority path-abempty
                / path-absolute
                / path-rootless
                / path-empty

scheme          = ALPHA *( ALPHA / DIGIT / "+" / "-" / "." )

authority       = [ userinfo "@" ] host [ ":" port ]

userinfo        = *( unreserved / pct-encoded / sub-delims / ":" )

host            = IP-literal / IPv4address / reg-name

IP-literal      = "[" ( IPv6address / IPvFuture  ) "]"
IPvFuture       = "v" 1*HEXDIG "." 1*( unreserved / sub-delims / ":" )
; IPv6address and IPv4address are defined in the code block below.
reg-name        = *( unreserved / pct-encoded / sub-delims )

port            = *DIGIT

; ---------------------------  path  ---------------------------------------------------------------

path            = path-abempty    ; begins with "/" or is empty
                / path-absolute   ; begins with "/" but not "//"
                / path-noscheme   ; begins with a non-colon segment
                / path-rootless   ; begins with a segment
                / path-empty      ; zero characters

path-abempty    = *( "/" segment )
path-absolute   = "/" [ segment-nz *( "/" segment ) ]
path-noscheme   = segment-nz-nc *( "/" segment )
path-rootless   = segment-nz *( "/" segment )
path-empty      = 0<pchar>

segment         = *pchar
segment-nz      = 1*pchar
segment-nz-nc   = 1*( unreserved / pct-encoded / sub-delims / "@" )
                ; non-zero-length segment without any colon ":"

pchar           = unreserved / pct-encoded / sub-delims / ":" / "@"

; ---------------------------  query and fragment  -------------------------------------------------

query           = *( pchar / "/" / "?" )

fragment        = *( pchar / "/" / "?" )

; ---------------------------  reference and absolute URI  ------------------------------------------

URI-reference   = URI / relative-ref
relative-ref    = relative-part [ "?" query ] [ "#" fragment ]
relative-part   = "//" authority path-abempty
                / path-absolute
                / path-noscheme
                / path-empty

absolute-URI    = scheme ":" hier-part [ "?" query ]
```

IP address grammars:

```abnf
; ---------------------------  IPV6 address  ------------------------------------------------------

IPv6address     =                            6( h16 ":" ) ls32
                /                       "::" 5( h16 ":" ) ls32
                / [               h16 ] "::" 4( h16 ":" ) ls32
                / [ *1( h16 ":" ) h16 ] "::" 3( h16 ":" ) ls32
                / [ *2( h16 ":" ) h16 ] "::" 2( h16 ":" ) ls32
                / [ *3( h16 ":" ) h16 ] "::"    h16 ":"   ls32
                / [ *4( h16 ":" ) h16 ] "::"              ls32
                / [ *5( h16 ":" ) h16 ] "::"              h16
                / [ *6( h16 ":" ) h16 ] "::"

ls32            = ( h16 ":" h16 ) / IPv4address
                ; least-significant 32 bits of address
h16             = 1*4HEXDIG
                ; 16 bits of address represented in hexadecimal

; ---------------------------  IPv4 address  -------------------------------------------------------

IPv4address     = dec-octet "." dec-octet "." dec-octet "." dec-octet
dec-octet       = DIGIT                 ; 0-9
                / %x31-39 DIGIT         ; 10-99
                / "1" 2DIGIT            ; 100-199
                / "2" %x30-34 DIGIT     ; 200-249
                / "25" %x30-35          ; 250-255
```
