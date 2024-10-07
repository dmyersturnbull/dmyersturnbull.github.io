<!--
SPDX-FileCopyrightText: Copyright 2017-2024, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->
# URI safe characters

People misunderstand what characters need to be percent-encoded in URIs.

## Characters allowed in URI queries

The characters `&`, `-`, `~`, `.`, `_`, `=`, `?`, `/`, `!`, `$`, `+`, `'`, `(`, `)`, `*`, `+`, and `,`
do **not** require percent encoding inside a
[URI query](https://datatracker.ietf.org/doc/html/rfc3986#section-3.4),
according to its specification, RFC 3986.

A query can contain any literal character except `:`, `#`, `[`, `]`, `@`, and `%`.
(Note: `?` begins a query but can also be used elsewhere, unescaped.)

This regex matches exactly the set of valid query strings (line breaks and indentation added for clarity):

```
?
(
  [^:#[]@%]+
  |
  %[A-Za-z0-9]{2}
)*
```

## Query parameters

Queries often follow more structure, by convention and subsequent RFCs.
This grammar recognizes query strings and the parameters inside them.
(Note: `?` is a valid query, but we are choosing to forbid `?x&`.)

```
query = '?' ( param ('&' param)* )?
param = (LIT | ESC)+
LIT   = [^:#[]@%]+
ESC   = %[A-Za-z0-9]{2}
```

We can further restrict to `key=value` pairs.
(Note: `value` can contain `=`, but `key` cannot.)

```
query = '?' ( param ('&' param)* )?
param = key '=' value
key   = (LIT | ESC)+
value = (LIT | ESC | '=')+
LIT   = [^=:#[]@%]+
ESC   = %[A-Za-z0-9]{2}
```

## Bugged software

Many `urlencode` implementations will encode these characters regardless.

This is because the 1994
[RFC 1738](https://datatracker.ietf.org/doc/html/rfc1738) for URLs,
which RFC 3986 obsoletes, had this language:

> Thus, only alphanumerics, the special characters "$-_.+!*'(),",
  and reserved characters used for their reserved purposes may be used unencoded within a URL.

RFC 3986 instead says

> If data for a URI component would conflict with a reserved character’s purpose as a delimiter,
  then the conflicting data must be percent-encoded before the URI is formed.

`urlencode` implementations are not smart enough to understand this.
Smart URI `urlencode` implementations could be introduced under new names such as `uriencode`
without breaking backwards compatibility.
I don’t know why that hasn’t happened.

## Explanation

Technically, RFC 3986 splits reserved characters into two sets, `gen-delims` and `sub-delims`:

```abnf
   gen-delims  = ":" / "/" / "?" / "#" / "[" / "]" / "@"
   sub-delims  = "!" / "$" / "&" / "'" / "(" / ")" / "*" / "+" / "," / ";" / "="
   unreserved  = ALPHA / DIGIT / "-" / "." / "_" / "~"
```

It then specificially forbids using `gen-delims` anywhere outside of their reserved meanings,
but also says about query strings:

> The characters slash ("/") and question mark ("?") may represent data within the query component.
  Beware that some older, erroneous implementations may not handle such data correctly [...]

So, the full set of allowed characters in URI queries is

```abnf
unreserved / sub-delims / "/" / "?"`.
```

[RFC 6920 §3](https://www.rfc-editor.org/rfc/rfc6920.html#section-3)
(“Naming Things with Hashes”) affirms these conclusions:

> [...] percent-encoding is used to distinguish between reserved and unreserved functions
  of the same character in the same URI component.
  As an example, an ampersand ('&') is used in the query part to separate attribute-value pairs;
  therefore, an ampersand in a value has to be escaped as '%26'.
  Note that the set of reserved characters differs for each component.
  As an example, a slash ('/') does not have any reserved function in a query part
  and therefore does not have to be escaped.

## Clarification

Ok, fine.
Technically, RFC 3986 also says:

> [RFC 3986] excludes portions of
  [RFC 1738](https://www.rfc-editor.org/rfc/rfc1738)
  that defined the specific syntax of individual URI schemes;
  those portions will be updated as separate documents.

Fortunately, the HTTP-specific part of RFC 1738 states (where `(<searchpart>` means `query`):

> Within the <path> and <searchpart> components, "/", ";", "?" are reserved.
  The "/" character may be used within HTTP to designate a hierarchical structure.

That means there is no HTTP-specific ban on our `sub-delims`, either.
