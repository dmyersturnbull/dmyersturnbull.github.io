# Query DSL

## Idea

I wanted to sketch out what a query language over HTTP `GET` for filtering records from REST-like resources
would look like as an alternative to GraphQL.

### Goals

- Queries must be URI-safe. _They must not require percent encoding._ †
- It must be easier to use and easier to implement than GraphQL.
- It must fit naturally into `GET` parameters.
- It must support normalization to cache keys.
- It must support standard comparison operators, including `=`, `<`, and `>`, as well as regex matching.
- It must support the standard logical operators `&` and `|`.
- It must understand missing values, e.g., through a `NULL` type.

### Non-goals

- It does not need to be as flexible as GraphQL.
- It need not allow selecting which fields are returned (only which records).


### † URI safety

The characters `-`, `~`, `.`, `_`, `=`, `?`, `/`, `!`, `$`, `+`, `'`, `(`, `)`, `*`, `+`, and `,`
do not require percent encoding when used in a URI _query_
according to [RFC 3986](https://datatracker.ietf.org/doc/html/rfc3986).

!!! bug "`urlencode`"

    Many `urlencode` implementations will encode these characters regardless.

!!! note "Note 1"

    This is because the 1994 [RFC 1738](https://datatracker.ietf.org/doc/html/rfc1738) for URLS,
    which RFC 3986 obsoletes, had this language:

    > Thus, only alphanumerics, the special characters "$-_.+!*'(),",
      and reserved characters used for their reserved purposes may be used unencoded within a URL.

    RFC 3986 instead says:

    > If data for a URI component would conflict with a reserved character’s purpose as a delimiter,
      then the conflicting data must be percent-encoded before the URI is formed.

    `urlencode` implementations are not smart enough to understand this.
    Smart URI `urlencode` implementations could be introduced under new names such as `uriencode`
    without breaking backwards compatibility.
    I don’t know why that hasn’t happened.

!!! note "Note 2"

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

!!! note "Note 3"

    Ok, fine. RFC 3986 also says:

    > [RFC 3986] excludes portions of RFC 1738 that defined the specific syntax of individual URI schemes;
      those portions will be updated as separate documents.

    The HTTP-specific part of RFC 1738 states (where `(<searchpart>` means `query`):

    > Within the <path> and <searchpart> components, "/", ";", "?" are reserved.
      The "/" character may be used within HTTP to designate a hierarchical structure.

    So there is no HTTP-specific ban on our `sub-delims`.

## Grammar

=== "regex-bnf"

    Using [regex-bnf](regex-bnf.md):

    ```text title="regex-BNF notation"
    query      = [ filter ('&' filter)* ] ;
    filter     = filter '(' condition ('|' condition)* ')' ;
    condition  = key EQ_VERB ( STR | FLOAT | BOOLEAN | NULL )
               | key STR_VERB STR
               | key FLOAT_VERB FLOAT
               ;
    key        = STR ;
    STR        = "'" { CHAR | '%' OCTET } "'" ;
    EQ_VERB    = '(eq)' | '(neq)' ;
    STR_VERB   = '(re)' ;
    FLOAT_VERB = '(lt)' | '(gt)' ;
    FLOAT      = ['-'] DIGIT ('.' DIGIT+)? ;
    NULL       = 'null' ;
    CHAR       = NORMAL_CHAR | SPECIAL ;
    NORMAL     = DIGIT | UPPERCASE | LOWERCASE | [_.~-] ;
    SPECIAL    = [=!$+()*+,/?] ;
    ```

=== "W3C XML EBNF"

    Using [W3C XML EBNF](https://www.w3.org/TR/REC-xml/#sec-notation):

  ```ebnf
    query      ::= ( filter { '&' filter } )? ;
    filter     ::= 'filter' '(' condition { '|' condition } ')' ;
    condition  ::= key EQ_VERB ( STR | FLOAT | BOOLEAN | NULL )
               | key STR_VERB STR
               | key FLOAT_VERB FLOAT
               ;
    key        ::= STR ;
    STR        ::= "'" (CHAR | OCTET-ESC)* "'" ;
    EQ_VERB    ::= '(eq)' | '(neq)' ;
    STR_VERB   ::= '(re)' ;
    FLOAT_VERB ::= '(lt)' | '(gt)' ;
    FLOAT      ::= '-'? [0-9]+ ('.' [0-9]+)? ;
    NULL       ::= 'null' ;
    BOOLEAN    ::= 'true' | 'false' ;
    CHAR       ::= NORMAL | SPECIAL ;
    NORMAL     ::= [0-9A-Za-z_-.~] ;
    OCTET-ESC  ::= '%' [0-9A-F][0-9A-F] ;
    SPECIAL    ::= [=!$+()*+,/?] ;
    ```

Note that `.` in keys is meant for hierarchical access;
`null` is the value if any node along the path is not present.
Although reserved characters are technically allowed in keys, they should not be used.

Also note that the grammar restricts queries to conjunctive normal form!

## Example

```http
GET https://things.tld/food?filter(type(eq)fruit|grams{lt}5.0|grams{gt}20.0)&filter(name{match}'.+?apple') HTTP/3
Content-Type: text/json
```

A few things to note:

- The same set of keys is not permitted in separate disjunctive clauses.
  For example, `filter(size(lt)5)&filter(size=5)` and `filter(a(eq)1|b(2))` not allowed.
- Regex (`(re)` strings are left as-is.
  This causes the only cases of semantic equivalence (in the linguistic sense)
  between nonidentical, normalized queries.

## Normalization

The server normalizes this to a cache key by:

1. Splitting clauses by `&` and sort them.
2. Within each clause, splitting by `|` and those strings.
3. Stripping trailing zeros from decimal values.

The example above results in the cache key

```text
food?filter(grams(gt)20|grams(lt)5|type(eq)fruit)&filter(name(match)'.+?apple')
```
