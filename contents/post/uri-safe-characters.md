<!--
SPDX-FileCopyrightText: Copyright 2017-2024, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->
# URI safe characters

People misunderstand what characters need to be percent-encoded in URIs.

## Correct answer: characters allowed in URI queries

The characters `&`, along with `-`, `~`, `.`, `_`, `=`, `?`, `/`, `!`, `$`, `+`, `'`, `(`, `)`, `*`, `+`, and `,`
do **not** require percent encoding when used in a URI query
according to
[RFC 3986](https://datatracker.ietf.org/doc/html/rfc3986).

So, you can use any character except in `[^:/?#[]@]`.
A URI query is then `^([^:/?#[]@]++)(?:&([^:/?#[]@]++))$`.

<small>
Note that the initial `?` is not part of the query string.
</small>

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

## Clarification 1

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

## Clarification 2

Ok, fine. RFC 3986 also says:

> [RFC 3986] excludes portions of RFC 1738 that defined the specific syntax of individual URI schemes;
  those portions will be updated as separate documents.

The HTTP-specific part of RFC 1738 states (where `(<searchpart>` means `query`):

> Within the <path> and <searchpart> components, "/", ";", "?" are reserved.
  The "/" character may be used within HTTP to designate a hierarchical structure.

So there is no HTTP-specific ban on our `sub-delims`.
