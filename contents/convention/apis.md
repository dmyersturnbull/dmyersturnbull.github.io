# API conventions

## JSON and data representation

Use [JSON Schema](https://json-schema.org/), version 2020-12.

Follow the [Google JSON guide](https://google.github.io/styleguide/jsoncstyleguide.xml).
Contradicting that guide, property names may follow other conventions if needed to accommodate other needs.
Avoid periods (`.`) in property names;
doing so complicates using
[JsonPath](https://github.com/json-path/JsonPath),
[JMESPath](https://jmespath.org/),
[jq](https://jqlang.github.io/jq/),
[YAML](https://yaml.org/), and
[TOML](https://toml.io/).
Permit only 1 type for a given key or array.

### Null and missing values; numerical range and precision

??? rationale

    Null values

    1. Clash with [JSON Merge Patch / RFC 7396](https://datatracker.ietf.org/doc/html/rfc7396).
       They cannot be expressed because the standard reserves `null` for deletions; and
    2. Have no agreed-upon or obvious meaning.
       They could signal an invalid value, a truly missing value (i.e. never found/added),
       or a selective decision to exclude (e.g. to save bandwidth).

    <small>
    About using `null` for missing-but-schema-supported keys:
    This practice is not obvious, wastes bandwidth, is supurfulous to the schema, and breaks if the schema changes.
    Let the schema specify what keys are allowed.
    </small>

**Do not use JSON `null`**, except in [JSON Merge Patch](https://datatracker.ietf.org/doc/html/rfc7396).
JSON Merge Patch uses it to signal deletion, so using `null` for other purposes effectively prevents HTTP `PATCH`.
It’s problematic for other reasons; refer to the _rationale_ box.
Tip: replace any `{"key": null}` with `{}` or (e.g.) `{"status: "error:too_few_samples}"}`.
If a null value is encountered (e.g. in a received payload), pretend it isn’t there.

#### NaN, Inf, and -Inf

JSON does not support numerical `NaN`, `Inf`, or `-Inf`.
If NaN or infinite values are applicable for a given key or array, encode them as strings.
For example, if values in an array can be a float, `Inf`, or `-Inf`, encode them like this:
`["5.3", "Inf", "6.8", "-Inf"]`.
Write literally `NaN`, `Inf`, or `-Inf`, with that capitalization.
(The minus sign must be U+002D.)

#### Range and precision

Generally, assume that JSON consumers will use IEEE 754 _double_ range and precision.
When writing numbers that might exceed that range or precision (where that precision is important),
encode them as strings (as with NaN, Inf, and -Inf).

#### Case study: Representing inconclusive or unknown values

Null values are often used to encode types like `string | null` and `int | null`.
Instead, be explicit about `null`’s meaning.

Consider a sensor measuring electric current.
The values are then divided by preceeding average to get a ratio, that is,
$R(I_t) = \left. I_t \middle/ \text{Avg}_{i=1}^{t-1} I_i \right.$
,
where $I_t$ is the current for trial $t$.
Compare these two representations:

=== "❌ Incorrect – using `null`"

    Did the measurement fail? A hardware connection issue?
    Was the ratio `Inf` (`1/0`), `-Inf` (`-1/0`), or `NaN` (`0/0`)?

    ```json
    [
      {"trial": 1, "value": 12.0},
      {"trial": 2, "value": null},
    ]
    ```

=== "✅ Correct – modeling explicitly"

    Specify the status values with a JSON Schema `enum`.
    The simpler alternative `{"success": <boolean>}` could work, too.

    ```json
    [
      {"trial": 1, "status": "success", "value": 12.0},
      {"trial": 2, "status": "error:no_signal"}
    ]
    ```

### Encoding specific types

#### Dates and times

Use [RFC 3339](https://www.rfc-editor.org/rfc/rfc3339), including a UTC offset.
Note that the UTC offset is written with a hyphen, not a minus sign.
Use only IANA timezones.
For example:

```json
{
  "date-time": "2023-11-02T14:55:00 -08:00",
  "timezone": "America/Los_Angeles"
}
```

#### Durations and intervals

A duration may be written as
(1) a number of days, hours, minutes, seconds, etc.;
(2) an ISO 8601 duration starting with `PT`; or
(3) `HH:MM:SS[.iii[iii]]`.

??? example "Examples"

    **✅ ok** `35.2` for a key `duration_sec`

    **✅ ok** `PT23H55M55S`

    **✅ ok** `23:45:55`

    **❌ Not ok** `P6M2WT45M55S` (ambiguous – months have indeterminate durations)

    **❌ Not ok** `P2S` (unambiguous but does not start with `PT`)

    **❌ Not ok** `05:22` (is this min:sec or hour:min?)

**For intervals**, both `{"start": ..., "end": ...}` and ISO 8601 `T1--T2` syntax are acceptable.
Do not separate times with `/` or use a start-time/duration pair.

!!! warning

    Be careful when calculating durations.
    Things like NTP synchronization events can cause $T^C_1 - T^C_2$ for a clock $C$ to not correspond
    to an elapsed time (or true duration).

## HTTP APIs

### Status codes

This section applies to REST-like HTTP APIs.
Servers should only use response codes in accordance with this guideline.
This table includes most non-completely-obvious responses;
the folded table following this one includes responses that are obvious or specialized.

| code | name                 | methods                | response | use case                         |
|------|----------------------|------------------------|----------|----------------------------------|
| 200  | OK                   | `HEAD`/`GET`/`PATCH`⁁  | resource |                                  |
| 201  | Created              | `POST`/`PUT`           | uri‡     |                                  |
| 202  | Accepted             | `P`/`P`/`P`/`DELETE`§  | ∅        |                                  |
| 204  | No Content           | `DELETE`               | ∅        | Successful deletion              |
| 308  | Permanent Redirect   | any                    | resource | Point to canonical URI           |
| 400  | Bad Request          | any                    | error♯   | Invalid endpoint, body, etc.     |
| 401  | Unauthorized         | any                    | error    | Not authenticated                |
| 403  | Forbidden            | any                    | error    | Insufficient privileges          |
| 404  | Not Found            | `GET`/`DELETE`/`PATCH` | error    | No such resource (e.g. by id)    |
| 409  | Conflict             | `P`/`P`/`P`            | error    | Resource already exists          |
| 409  | Conflict             | `DELETE`               | error    | Other resources depend on this   |
| 410  | Gone                 | `GET`/`DELETE`/`PATCH` | error    | Resource removed                 |
| 422  | Unprocessable Entity | `P`/`P`/`P`            | error    | Sematic; invalid reference, etc. |
| 429  | Too Many Requests    | any                    | error    | Ratelimit hit                    |
| 500  | Server Error         | any                    | error    | General server error             |
| 503  | Service Unavailable  | any                    | error    | Maintenance or overload          |

<b>Footnotes:</b>

- † `POST`/`POST`/`PATCH`
- ⁁ `PATCH` should use [JSON Merge Patch](https://datatracker.ietf.org/doc/html/rfc7396) (assuming JSON).
- ‡ A JSON document containing at least `uri`; e.g. `{"uri": "https://domain.tld/api/thing/1"}`.
  The value should be the canonical URI for which `GET` returns the resource.
- § `POST`/`POST`/`PATCH`/`DELETE`
- ♯  An [RFC 7807](https://datatracker.ietf.org/doc/html/rfc7807) JSON payload

<b>About 404 Not Found:</b>

404 Not Found is reserved for resources that _could_ exist but do not;
attempts to access an invalid endpoint must always generate a 400 (Bad Request).
For example, if `id` must be hexadecimal for `/machine/{id}`, then `/machine/zzz` should generate a 400.
The response body
([RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457#name-members-of-a-problem-detail) problem details)
can (and likely should) describe the problem; e.g. `{..., "detail": "{id} must match ^[0-9A-F]{16}$"}`.

<b>About 422 Unprocessable Entity:</b>

Use 422 Unprocessable Entity for errors with respect to the model semantics and/or data.
For example, in `{"robot: "22-1-44", "action": "sit"}`, a 422 might be sent
if robot 22-1-44 does not exist or lacks sit/stand functionality.
A 409 Conflict might result if it 22-1-44 cannot accept the command because it is currently handling another.
Respond 409 Conflict for conflicting <em>state</em>,
most notably to a request to delete a resource that other resources reference.

=== details "Table including obvious and specialized responses"

      Some APIs may need other responses.
      (Few services need every response in this table.)

      | code | name                   | methods                | response | use case                         |
      |------|------------------------|------------------------|----------|----------------------------------|
      | 100  | Continue¹              | `P`/`P`/`P`            | ∅        | `100-continue` succeeded (rare)  |
      | 200  | OK                     | `HEAD`/`GET`/`PATCH`   | resource |                                  |
      | 201  | Created                | `POST`/`PUT`           | uri      |                                  |
      | 202  | Accepted               | `P`/`P`/`P`/`D`        | ∅        |                                  |
      | 204  | No Content             | `DELETE`               | ∅        | Successful deletion              |
      | 206  | Partial Content        | `GET`                  | part     | Range was requested              |
      | 304  | Not Modified           | `HEAD`/`GET`           | ∅        | `If-None-Match` matches          |
      | 308  | Permanent Redirect     | any                    | resource | Point to canonical URI           |
      | 400  | Bad Request            | any                    | error    | Invalid endpoint, body, etc.     |
      | 401  | Unauthorized           | any                    | error    | Not authenticated                |
      | 403  | Forbidden              | any                    | error    | Insufficient privileges          |
      | 404  | Not Found              | `GET`/`DELETE`/`PATCH` | error    | No such resource (e.g. by id)    |
      | 406  | Not Acceptable         | `HEAD`/`GET`           | error    | `Accept` headers unsatisfiable   |
      | 409  | Conflict               | `P`/`P`/`P`            | error    | Resource already exists          |
      | 409  | Conflict               | `DELETE`               | error    | Other resources depend on this   |
      | 410  | Gone²                  | `GET`/`DELETE`/`PATCH` | error    | Resource removed                 |
      | 412  | Precondition Failed¹   | `P`/`P`/`P`/`D`        | error    | Mid-air edit (`If-...`)          |
      | 413  | Content Too Large²     | `P`/`P`/`P`            | error    | Overly long request payloads     |
      | 414  | URI Too Long²          | `GET`                  | error    |                                  |
      | 415  | Unsupported Media Type | `P`/`P`/`P`            | error    | Invalid payload media type       |
      | 416  | Range Not Satisfiable  | `GET`                  | error    | Requested range out of bounds    |
      | 417  | Expectation Failed¹    | `P`/`P`/`P`            | error    | `Expect: 100-continue` failed    |
      | 422  | Unprocessable Entity   | `P`/`P`/`P`            | error    | Sematic; invalid reference, etc. |
      | 418  | I'm a teapot³          | any                    | error    | Request blocked                  |
      | 428  | Precondition Required¹ | `P`/`P`/`P`/`D`        | error    | `If-...` required                |
      | 431  | … Fields Too Large²    | any                    | error    | Overly long headers              |
      | 429  | Too Many Requests      | any                    | error    | Ratelimit hit                    |
      | 500  | Server Error           | any                    | error    | General server error             |
      | 503  | Service Unavailable    | any                    | error    | Maintenance or overload          |

??? details "Notes about specific codes"

    - ¹ Only useful for modifiable resources.
    - ² Preferred but optional. A 400 Bad Request may be used instead.
    - ³ 418 I'm a Teapot may optionally be used to communicate with a client that has been locked out
      for reasons other than ratelimiting.
      For example, this might be sent if the client previously sent several suspicious queries,
      is sending a query that appears malicious, or sent an excessive amount of data over the last few minutes.<br />
      <small>
      While nonstandard, 418 is sometimes used this way to distinguish these types of situtations from more common ones.
      A 418 indicates that the client cannot rectify the problem,
      that the server may or may not be willing to process a different request,
      and that the server may or may not accept the same request if it is re-sent later.
      These factors cleanly distinguish 418 from 403 Forbidden, 429 Too Many Requests, etc.
      Note that simply refusing connections is an alternative but may be more frustrating to users.
      </small>

### Problem details for 4xx/5xx responses

All 4xx and 5xx responses should include a
[RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457#name-members-of-a-problem-detail) body
with media-type `application/problem+json`.
`title` is required.
It should be a short, free-form, human-readable statement that ends with a period.
`detail` should similarly contain free-form, human readable statements (one or more sentences).
`type` must be in either all or no responses; same for `status`.

`type` must serve `application/json` and `text/html; charset=utf-8` (which RFC 9457 requires).
`text/x-markdown` is also recommended, preferably identical to the corresponding OpenAPI schema
[`response.description`](https://spec.openapis.org/oas/v3.1.0#fixed-fields-14).

Always include _extensions_ that a client would likely want to parse.
For example, specify the incorrect request parameter or header, or the dependent resource for a 409 Conflict.
Use kebab-case or camelCase according to the convention your overall API uses.
Occasionally, these extensions will be redundant to headers, such as `Accept` and `RateLimit-Limit`;
this is ok.

??? example "Examples"

    === "500 Internal Server Error"

      ```json
      {
        "title": "Internal server error",
        "type": "https://domain.tld/help/error/server.internal"
        "status": "500",
      }
      ```

    === "422 Unprocessable Entity"

      ```json
      {
        "title": "DSL parse error",
        "type": "https://domain.tld/help/error/client.dsl-parse"
        "status": "422",
        "detail": "Line number 22 contains an unidentified symbol '@' at column 14.",
        "lineNumber": 22,
      }
      ```

    === "400 Bad Request"

      ```json
      {
        "title": "Malformed parameter.",
        "status": "400",
        "detail": "Parameter 'name' is malformed. It must be a 10-digit hexadecimal string.",
        "parameter": "name"
      }
      ```

### Links

If links per [HATEOAS](https://en.wikipedia.org/wiki/HATEOAS) are used, they should be limited to direct connections.
For example, if a `species` resource links to its `genus`, which links to `family`,
`species` should **not** link to `family`.
Consider putting links in a custom header to avoid polluting JSON response bodies.

### Headers

#### Content types

Provide `Accept:` on non-`HEAD` requests – for example, `Accept: text/json`.
Similarly, provide `Content-Type:` on `POST` – for example, `Content-Type: text/json`.

#### Rate-limiting

Use [draft IETF rate-limiting headers](https://www.ietf.org/archive/id/draft-polli-ratelimit-headers-02.html):
`RateLimit-Limit`, `RateLimit-Remaining`, and `RateLimit-Reset`.
These should always be included for 429 (Too Many Requests) responses
and MAY be included for other responses as well.

#### Location

Include `Location` for 201 Created responses.

## Formal grammars

Grammars may be specified in any well-defined form.
[ABNF](https://en.wikipedia.org/wiki/Augmented_Backus%E2%80%93Naur_form)
(see [RFC5234](https://datatracker.ietf.org/doc/html/rfc5234)),
[XML’s custom meta-grammar](https://www.w3.org/TR/xml/#sec-notation),
and [regex-BNF](https://dmyersturnbull.github.io/post/regex-bnf) are recommended.

??? rationale

    `=/` modifies an already-defined rule, which complicates reading.
    `LWSP` is commonly understood to be problematic.

With ABNF, do not use the incremental alternatives notation (`=/`),
and avoid the core rules `CHAR`, `LWSP`, `CTL`, `VCHAR`, and `WSP`.
