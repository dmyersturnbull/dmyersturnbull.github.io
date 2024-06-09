# HTTP GET search DSL

!!! tip "Status: ready to use"

    This specification is legitimately useful and ready to use.
    Small changes may be needed.

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

**Using [regex-bnf](regex-bnf.md):**

```text
param          = where | return | sort
where          = param-defn condition ('|' condition)*
param-defn     = 'where[' INDEX ']='
condition      = key ':' str-verb ':' STR
               | spec(str-verb) STR
               | spec(int-verb) INT
               | spec(float-verb) FLOAT
               | spec(boolean-verb) BOOLEAN
               | spec(datetime-verb) DATETIME
               | spec(defined-verb) BOOLEAN
               | spec(contains-verb) (STR | INT | BOOLEAN)
               | spec(size-verb) LITERAL-NONNEG-INT
               | spec(key-verb) key

spec(verb)     = key ':' verb ':'
return         = 'get=' key ('/' key)*
sort           = 'sort=' sort-spec ('/' sort-spec)*
sort-spec      = ASCENDING? key
str-verb       = 'eq' | 'neq' | 'regex'
int-verb       = 'eq' | 'neq' | 'lt' | 'gt' | 'le' | 'ge'
float-verb     = 'lt' | 'gt' | 'le' | 'ge'
boolean-verb   = 'eq'
defined-verb   = 'defined'
contains-verb  = 'contains' | 'does-not-contain'
size-verb      = 'has-size' | 'has-min-size' | 'has-max-size'
key-verb       = 'eq-key' | 'neq-key' | 'lt-key' | 'gt-key' | 'le-key' | 'ge-key' | 'in-key'
key            = KEY-NODE ( '.' KEY-NODE )*
KEY-NODE       = [A-Za-z0-9_-]+
INDEX          = LITERAL-POSITIVE-INT
ASCENDING      = '-'
STR            = ( NORMAL-CHAR | SPECIAL-CHAR | '%' OCTET )+
INT            = LITERAL-INT | E-NOTATION-INT
FLOAT          = LITERAL-FLOAT | E-NOTATION-FLOAT
NORMAL-CHAR    = ALPHANUM | [_.~-]
SPECIAL-CHAR   = [=!$()*+,/?]
```

Although reserved characters are allowed in keys, avoid them where possible.
Also note that the grammar **restricts queries to conjunctive normal form!**

## Example

```http
GET https://things.tld/food?where[1]=type:eq:fruit|grams:lt:5.0&where[2]=name:regex:.+?apple
HTTP/3
Content-Type: text/json
```

## Normalization

The DSL has a dual in JSON.

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
  ]
    ```

A cache key can be obtained by converting to JSON, sorting, minifying, computing a hash, and base64url-encoding.
Pagination parameters and request headers such as `If-Match` should be considered.
For example, a pagination cursor/limit pair can be added to the JSON, and the ETag compared separately.

## Additional params

### `get`

List the fields to return ala GraphQL. Field names are delimited `/`.

??? example

    <b>Data:</b>

    ```json
    [
      "author": {
        "name": "Justine Taylor",
        "email": "justine.taylor@uni.edu.au"
      },
      "metadata": {
        "version": "1.0.0",
        "creation-timestamp": "2022-11-27T17:57:10Z"
      }
    ]
    ```

    `get=author+metadata.version` requests the JSON object `author` and the string `version` under `metadata`.

    <b>Response:</b>

    ```json
    [
      "author": {
        "name": "Justine Taylor",
        "email": "justine.taylor@uni.edu.au"
      },
      "metadata": {
        "version": "1.0.0"
      }
    ]
    ```

### `sort`

Sort by one or more keys, delimited by `/` and listed from high to low precedence.
Prepending `-` to a key reverses the sort order.
For `sort=-author.name|author.email`, `author.name` is in descending order, and `author.email` is used to break ties.
Note that a total ordering is guaranteed if and only if at least one field is unique for all records.

??? details


    ```json
    {
      "where": [
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
      ],
      "return": [
        "name",
        "order.purchase-count"
      ],
      "sort": [
        {
          "key": "name",
          "reverse": false
        }
      ]
    }
    ```
