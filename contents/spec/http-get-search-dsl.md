# HTTP GET search DSL

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

<b>Spec status: Useful and ready to go.</b>
Take it, modify it, use it. (CC-BY-SA)
_Note: The image extension is experimental._

## Summary

A tiny domain-specific language (DSL) to find and download in REST-like APIs.
Queries are highly readable, requiring no percent-encoding.

An example is worth 10k words:

```
GET https://things.tld/foods\
  ?where=name:regex:.+?apple\
  &where=type:eq:fruit|measurements.grams:le:5.0\
  &return=name
  &sort-by=name|-purchase_date
```

The query above finds `foods` with `name` ending in "apple"
and either `type` "fruit" or weight (in `grams`) less than 5.
It sorts by name, then by `purchase_date` in descending order.

### Goals

The language must:

- Be easy to write and easy to implement.
- Be able to represent most data search and download requests.
- Be self-documenting, highly readable, and not require percent-encoding. †
- Have a unique and easy-to-calculate normal form.
- Yield high cache hit rates even for non-normalized queries.
- Support filtering that:
  - Handles nested keys; e.g. `key.subkey == "yes"`.
  - Includes `=`, `<`, `>`, an existence operator, and regex matching.
  - Support logical AND/OR.
- Support requesting any subset of fields.
- Support sorting by any number of fields.

<b>† URI safety:</b>
This means that percent-encoding is not needed (with some exceptions, such as in regex patterns).
You only need to escape characters in the regex class `[:/?#[]@]` inside strings
(e.g. the `@` in `email:eq:admin@api.tld`).
See
[URI-safe characters](../post/uri-safe-characters.md)
for a dive into the URI RFCs.

### Non-goals

It does not need to:

- Be as powerful as SQL for search.
- Be as powerful as GraphQL for download.

### OpenAPI

```yaml
filter:
  in: query
  name: "where"
  description: |
    Array of filter expressions.
    Returned values must match **all** filter expressions.
    _Example_: `type:eq:fruit|grams:lt:5&filter=name:regex:.+?apple`
  allowReserved: true
  style: form
  explode: true
  schema:
    type: string
    example: "type:eq:fruit|grams:lt:5"

return:
  in: query
  name: return
  description: >-
    A key of the records to include in the returned data.
    If no `return` parameter is provided, all keys will be returned.
    (This parameter is split by commas.)
  allowReserved: true
  style: simple
  explode: true
  schema:
    type: string
    pattern: '^([a-z][a-z0-9,;=+~_-]*+)(?:\.([a-z][a-z0-9,;=+~_-]*+))*+$'

sort:
  in: query
  name: sort
  description: >-
    Comma-separated list of keys to sort records by.
    Records will be sorted by the first key, using the second key to break ties, and so on.
    Prefix a key with `-` to reverse the order use descending rather than ascending order.
  allowReserved: true
  schema:
    type: string
    pattern: '^(-?[a-z][a-z0-9,;=+~_-]*+)(?:\.(-?[a-z][a-z0-9,;=+~_-]*+))*+$'

jmespath:
  in: query
  name: jmespath
  description: >-
    JMESPath expression to apply after `filter`, `get`, and `sort`.
    `jmespath` much slower than `filter`.
    Whenever possible, prefer using `filter`, using `jmespath` only for complex non-filtering transformations.
  allowReserved: true
  schema:
    type: string
    minLength: 1

limit:
  in: query
  name: limit
  description: >-
    For pagination, the max number of records to return.
  schema:
    type: number
    minimum: 0

offset:
  in: query
  name: offset
  description: >-
    For pagination, the index of the first record to return (starting at 0).
  schema:
    type: number
    minimum: 0
```

## `where`

### Conjunctive normal form

The grammar restricts queries to conjunctive normal form.
This removes any need for parentheses.
By reducing the number of ways to write a query, it also increases the likelihood of a cache hit.

### `where` grammar

**Using [bnf-with-regex](regex-bnf.md):**

```text
param          = where | return | sort
where          = 'where[' INDEX ']=' condition ('|' condition)*
where          = param-defn condition ('|' condition)*
param-defn     = 'where' '(' INDEX ')' '='
condition      = spec(KEY-VERB) key
condition      = key ':' STR-VERB ':' STR
               | spec(STR-VERB) STR
               | spec(INT-VERB) INT
               | spec(FLOAT-VERB) FLOAT
               | spec(BOOLEAN-VERB) BOOLEAN
               | spec(DATETIME-VERB) DATETIME
               | spec(DEFINED-VERB) BOOLEAN
               | spec(CONTAINS-VERB) (STR | INT | BOOLEAN)
               | spec(SIZE-VERB) LITERAL-NONNEG-INT

spec(verb)     = key ':' verb ':'
return         = 'return=' key ('|' key)*
sort           = 'sort-by=' sort-spec ('|' sort-spec)*
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

!!! note "Caution: avoid reserved characters in keys"

    Although this grammar allows reserved characters in keys, avoid them where possible.

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

## Example

```http
GET https://things.tld/food?where=type:eq:fruit|grams:lt:5.0&where=name:regex:.+?apple
HTTP/3
Content-Type: text/json
```

!!! tip "Tip: `where(1)` instead of `where[1]`"

    If you dislike exploded query paramters (i.e. `key=value-1&key=value-2`),
    consider appending `(n)` to the each key; e.g. `where(1)=...&where(2)=...`.
    This is differs from the form-field paramter convention of `[]`,
    but there’s really no need to follow that, and `()` doesn’t need percent-encoding.

## Normalization

To normalize a URI:

1. Extract the query arguments (key–value pairs).
   These must, of course, be order-independent.
2. Sort the arguments lexicographically (per the order in Unicode).
3. Re-number any `where(.)` parameters.
4. Stitch the URI back together.

!!! example

    Returning to the fruit example:

    1. Extract `type:eq:fruit|grams:lt:5.0` and `name:regex:.+?apple`.
    2. Sort. `n` comes before `t`, so the order should be reversed.
    3. Set `where=name:regex:.+?apple` and `where=type:eq:fruit|grams:lt:5.0`.
    4. Concatentate to get
         `https://things.tld/food?where=name:regex:.+?apple&where=type:eq:fruit|grams:lt:5.0`

## Caching

!!! note "Note: caching"

    For caching, some request headers may need to be used in the caching logic.
    For example, `If-Match` may need to be handled along with `ETag`.
    None of this is shown here.

### Client

The client can cache each GET request and response.
If queries area always written the same way, this works well.
However, a client may GET `/resource?where=<<1>>&where=<<2>>`,
then later `/resource?where=<<2>>&where=<<1>>`, thereby bypassing the cache.
No recommendation is made to avoid that.

### Server:

If caching, use a multi-key (many-to-one) cache with URIs as the keys.

1. Check the URI `U` against the cache `C`.
2. If not found, compute the normalized URI `N`.
   If `N` is in `C` with response `R`, add `(C, R)` to `N`.
3. Compute the response `R`.
   Add `(U, R)` and `(N, R)` to `C`.

## JSON dual

The DSL has a JSON array dual:

??? example

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

## Params

### `where`

Choose to implement one or both of these:

- `where=<<1>>&where=<<2>>`
- `where(1)=<<1>>&where(2)=<<2>>`

Refer to the grammar for details on this parameter.

### `return`

List the fields to return ala GraphQL.
Field names are delimited by `|`, which signals union.

!!! example

    `return=author|metadata.version`
    requests the JSON object `author` and the string `version` under `metadata`.

### `sort-by`

Sort by one or more keys, delimited by `|` and listed from high to low precedence.
Prepending `-` to a key reverses the sort order.
For `sort-by=-author.name|author.email`, `author.name` is in descending order, and `author.email` is used to break ties.
Note that a total ordering is guaranteed if and only if at least one field is unique for all records.

## Images

### format

Two options are acceptable.
However, supporting both is discouraged.

- `/api/image/{id}{suffix}`.
  This is not very resource-oriented †, but it is convenient and obvious.
  Example: `/api/image/9hfzk2lr-01.avif`
- `format={format}`.
  This is more common in REST-like APIs.
  Example: `/api/image/9hfzk2lr-01.webp`

<small>
    <b>†</b> Specifically, we’ll term an API resource-oriented if
    URIs represent the same resource **iff** they have the same path.
</small>

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
    `1/40` reveals the intent (divide by 40) more  clearly than `0.025`.

### `rotate`

Rotations and reflections are supported by a single parameter, `rotate`, an enum of 7 values.

Yes, `rotate` isn’t exactly correct here.
Alternatives considered included `orient` (vague) and `view` (also vague).
To fulfill our uniqueness requirement, `rotate=0` is not allowed.

| `rotate=`        | effect                        |
| ---------------- | ----------------------------- |
| ``               | none / identity               |
| `90`             | rotate 90 degrees clockwise   |
| `180`            | rotate 180 degrees clockwise  |
| `270`            | rotate 270 degrees clockwise  |
| `flip-x`         | flip horizontally             |
| `flip-y`         | flip vertically               |
| `flip-top-left`  | flip top-left to bottom-right |
| `flip-top-right` | flip top-right to bottom-left |
