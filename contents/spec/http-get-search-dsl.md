<!--
SPDX-FileCopyrightText: Copyright 2017-2024, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->
# HTTP GET search DSL

!!! tip "Status: ready to use"

    This specification is legitimately useful and ready to be used.
	(It’s currently used in a production environment.)
	Take it, modify it, use it. (CC-BY-SA)
	_Note: The image extension is experimental._

## Idea

I wanted to sketch out what a query language over HTTP `GET` for filtering records from REST-like resources
would look like as an alternative to GraphQL.

### Goals

- Queries must be URI-safe. _They must not require percent encoding._ †
- It must be easier to use and easier to implement than GraphQL.
- It must fit naturally into `GET` parameters.
- It must support normalization to cache keys.
- It must support standard comparison operators, including `=`, `<`, `>` and as regex matching.
- It must support the standard logical operators AND and OR.

### Non-goals

- It does not need to be as flexible as GraphQL.
- It need not allow selecting which fields are returned (only which records).

### † URI safety

You only need to escape characters in the regex class `[:/?#[]@]` inside a URI query.
See
[URI-safe characters](../post/uri-safe-characters.md)
for a dive into the URI RFCs.

## Grammar

This includes optional extensions for images.

**Using [bnf-with-regex](advanced-bnf-with-regex.md):**

### Main grammar

```text
param          = where | return | sort
where          = 'where[' INDEX ']=' condition ('|' condition)*
where          = param-defn condition ('|' condition)*
param-defn     = 'where' '(' INDEX ')' '='
condition      = key ':' STR-VERB ':' STR
               | spec(STR-VERB) STR
               | spec(INT-VERB) INT
               | spec(FLOAT-VERB) FLOAT
               | spec(BOOLEAN-VERB) BOOLEAN
               | spec(DATETIME-VERB) DATETIME
               | spec(DEFINED-VERB) BOOLEAN
               | spec(CONTAINS-VERB) (STR | INT | BOOLEAN)
               | spec(SIZE-VERB) LITERAL-NONNEG-INT
               | spec(KEY-VERB) key

spec(verb)     = key ':' verb ':'
return         = 'get=' key ('|' key)*
sort           = 'sort=' sort-spec ('|' sort-spec)*
sort-spec      = ASCENDING? key
key            = KEY-NODE ( '.' KEY-NODE )*
STR-VERB       = 'eq' | 'neq' | 'regex'
INT-VERB       = 'eq' | 'neq' | 'lt' | 'gt' | 'le' | 'ge'
FLOAT-VERB     = 'lt' | 'gt' | 'le' | 'ge'
BOOLEAN-VERB   = 'eq'
DEFINED-VERB   = 'defined'
CONTAINS-VERB  = 'has-value' | 'lacks-value'
SIZE-VERB      = 'has-size' | 'has-min-size' | 'has-max-size'
KEY-VERB       = 'eq-key' | 'neq-key' | 'lt-key' | 'gt-key' | 'le-key' | 'ge-key' | 'in-key'
KEY-NODE       = [A-Za-z0-9_-]+
INDEX          = LITERAL-POSITIVE-INT
ASCENDING      = '-'
STR            = ( NORMAL-CHAR | SPECIAL-CHAR | '%' OCTET )+
INT            = LITERAL-INT | E-NOTATION-INT
FLOAT          = LITERAL-FLOAT | E-NOTATION-FLOAT
NORMAL-CHAR    = ALPHANUM | [_.~-]
SPECIAL-CHAR   = [=!$()*+,/?]
```

### Image extension

```text
param          = where | return | sort | crop | scale | rotate

crop           = 'crop=' ( coordinate=top-left 'x' coordinate=bottom-right )
scale          = 'scale=' ( INT | '1/' INT )
rotate         = 'rotate=' ( ROTATE | FLIP )
coordinate     = '(' INT ',' INT ')'
ROTATE         = '90' | '180' | '270'
FLIP           = 'flip-x' | 'flip-y' | 'flip-top-left' | 'flip-top-right'
```

Although reserved characters are allowed in keys, avoid them where possible.
Also note that the grammar **restricts queries to conjunctive normal form!**

## Example

```http
GET https://things.tld/food?where=type:eq:fruit|grams:lt:5.0&where=name:regex:.+?apple
HTTP/3
Content-Type: text/json
```

!!! tip

    If you dislike exploded query paramters (i.e. `key=value-1&key=value-2`),
    consider appending `(n)` to the each key; e.g. `where(1)=...&where(2)=...`.
    This is differs from the form-field paramter convention of `[]`,
    but there’s really no need to follow that, and `()` doesn’t need percent-encoding.

## Canonicalization

Canonicalize a URI by these steps:

1. Extract the query arguments (values of the `where` parameters).
2. Sort the arguments lexigraphically (per the order in Unicode).
3. Re-number the `where(.)` parameters accordingly.
4. Stitch the URI back together

!!! example "For the prior example"

    1. Extract `type:eq:fruit|grams:lt:5.0` and `name:regex:.+?apple`.
    2. Sort. `n` comes before `t`, so the order should be reversed.
    3. Set `where=name:regex:.+?apple` and `where=type:eq:fruit|grams:lt:5.0`.
    4. Concatentate to get
         `https://things.tld/food?where=name:regex:.+?apple&where=type:eq:fruit|grams:lt:5.0`

## JSON dual

The DSL has a JSON array dual:

??? details "Example"

    ```json
    [
      {
        "key": "grams",
        "verb": "lt",
        "value": 5
      },
      {
        "key": "type",
        "verb": "eq",
        "value": "fruit"
      }
    ],
    [
      {
        "key": "name",
        "verb": "regex",
        "value": ".+?apple"
      }
    ]
    ```

Starting at nesting level $L=0$, the operator is _AND_ for even $L$ and _OR_ for odd $L$.

A cache key can be obtained by converting to JSON, sorting, minifying, computing a hash, and base64url-encoding.
Pagination parameters and request headers such as `If-Match` should be considered.
For example, a pagination cursor/limit pair can be added to the JSON, and the ETag compared separately.

## Additional params

### `get`

List the fields to return ala GraphQL.
Field names are delimited by `|`.

!!! example

    `get=author|metadata.version`
    requests the JSON object `author` and the string `version` under `metadata`.

### `sort`

Sort by one or more keys, delimited by `|` and listed from high to low precedence.
Prepending `-` to a key reverses the sort order.
For `sort=-author.name|author.email`, `author.name` is in descending order, and `author.email` is used to break ties.
Note that a total ordering is guaranteed if and only if at least one field is unique for all records.

## Images

### format

`/api/image/{id}{suffix}` is recommended, but `format={format}` is acceptable.
Example: `/api/image/9hfzk2lr-01.avif` and `/api/image/9hfzk2lr-01.webp`.

### `crop`

Extracts a rectangular subregion of an image, specified in terms of pixels.
Syntax: `(top,left)x(bottom,right)`

### `scale`

Scales both dimensions by a factor.
The syntax is `scale=(\d+)` to upscale and `scale=1/(\d+)` to downscale.
Examples:

- `scale=2` doubles the size.
- `scale=1/2` halves the size.

!!! rationale

    This preserves relative magnitudes.
    `1/40` reveals the intent more clearly than `0.025`.

### `rotate`

Rotations and reflections are supported by a single parameter, `rotate`, an enum of 7 values.

I couldn’t think of a good name for this parameter.

Yes, `rotate` isn’t exactly correct here.
`orient` is a reasonable alternative, though it seems too vague.

| `rotate=` (recommended) | `orient=`           | effect                        |
|-------------------------|---------------------|-------------------------------|
| ``                      | ``                  | none / identity               |
| `90`                    | `rotate-90`         | rotate 90 degrees clockwise   |
| `180`                   | `rotate-180`        | rotate 180 degrees clockwise  |
| `270`                   | `rotate-270`        | rotate 270 degrees clockwise  |
| `flip-x`                | `flip-x`            | flip horizontally             |
| `flip-y`                | `flip-y`            | flip vertically               |
| `flip-top-left`         | `flip-top-left`     | flip top-left to bottom-right |
| `flip-top-right`        | `flip-bottom-right` | flip top-right to bottom-left |
