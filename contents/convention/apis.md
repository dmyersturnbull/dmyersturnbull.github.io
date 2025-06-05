# API conventions

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

## JSON and data representation

Use the newest [JSON Schema](https://json-schema.org/) (version 2020-12 as of 2024-12).
Follow the [Google JSON guide](https://google.github.io/styleguide/jsoncstyleguide.xml).
Contradicting that guide,
property names may follow other conventions if needed to accommodate other needs.

### Property definitions

Don’t try to anticipate lookup needs or pretend your JSON is an index.
Let consumers build indices for fast lookup if they need to.

=== "❌ Incorrect – using arbitrary names as keys"

    ```json
    {
      "authorEmails": {
        "John Kerry": "john.kerry@state.gov",
        "Madeleine Albright": "albright@state.gov"
      }
    ```

=== "✅ Correct – leaving the names as values"

    ```json
    {
      "people": [
        {
          "name": "John Kerry",
          "email": "john.kerry@state.gov"
        }
      ]
    ```

??? rationale

    A consumer may want to search by a different key; e.g. by `email` in the above example.
    Ignoring lookup needs when designing the schema simplifies the design process,
    creates more understandable and obvious schemas,
    and increases flexibility (e.g. `age` can be added to `people`).
    Finally, it avoids needing problematic property names, as discussed next.

### Property names

Restrict keys to one of these patterns:

- `^[a-z0-9][a-z0-9+-]*$` – kebab-case; general, and allowing `+` to mean _and_
- `^[a-z][a-z0-9-]*$` – kebab-case; trivial interoperability with Python
- `^[a-z][A-Za-z0-9]*$` – camelCase; JavaScript/Java-compatible
  (in practice, avoid consecutive `[A-Z]`; i.e. prefer `^[a-z]([A-Z]?[a-z0-9]+)*[A-Z]?$`.)
- `^[a-z][a-z_]*$` – snake_case; Python-compatible
- another pattern that disallows **at least** `` ./:|{}*?#/"'`<>`` and non-printable characters

Doing this simplifies using
[JsonPath](https://github.com/json-path/JsonPath),
[JMESPath](https://jmespath.org/),
[jq](https://jqlang.github.io/jq/),
[YAML](https://yaml.org/), and
[TOML](https://toml.io/).
Permit only 1 type for a given key or array.

### Null and missing values; numerical range and precision

??? rationale

    Null values

    1. Clash with
       [JSON Merge Patch / RFC 7396](https://datatracker.ietf.org/doc/rfc7396/).
       They cannot be expressed because the standard reserves `null` for deletions; and
    2. Have no agreed-upon or obvious meaning.
       They could signal an invalid value, a truly missing value (i.e. never found/added),
       or a selective decision to exclude (e.g. to save bandwidth).

    Also don’t use `null` to indicate that a key is supported in the schema but not used.
    This practice is not always understood, wastes bandwidth, is supurfulous to the schema,
    and breaks if the schema changes.
    Let the schema specify what keys are allowed.

#### Null values (JSON `null`):

**Do not use JSON `null`**, except in
[JSON Merge Patch](hhttps://datatracker.ietf.org/doc/rfc7396/).
JSON Merge Patch uses it to signal deletion,
so using `null` for other purposes effectively prevents HTTP `PATCH`.
It’s problematic for other reasons; refer to the _rationale_ box.
Tip: replace any `{"key": null}` with `{}` or (e.g.) `{"status: "error:too_few_samples}"}`.
If a null value is encountered (e.g. in a received payload), pretend it isn’t there.

#### NaN, Inf, and -Inf:

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
The values are then divided by preceding average to get a ratio, that is,
$R(I_t) = \left. I_t \middle/ \text{Avg}_{i=1}^{t-1} I_i \right.$,
where $I_t$ is the current for trial $t$.
Compare these two representations:

=== "❌ Incorrect – using `null`"

    **This is a bad design.**
    Did the measurement fail? For example, was there a hardware connection issue?
    Or was the ratio `Inf` (`1/0`) or `-Inf` (`-1/0`)? Or `NaN` (`0/0`)?

    ```json
    [
      {"trial": 1, "value": 12.0},
      {"trial": 2, "value": null},
    ]
    ```

=== "✅ Correct – modeling explicitly"

    **This is a good design.**
    Specify the status values with a JSON Schema `enum`.
    The simpler alternative `{"success": <boolean>}` could work, too.

    ```json
    [
      {"trial": 1, "status": "success", "value": 12.0},
      {"trial": 2, "status": "error:no_signal"}
    ]
    ```

### Encoding specific types

#### Date-times

Use [RFC 3339](https://datatracker.ietf.org/doc/rfc3339/), including a UTC offset.
Note that the UTC offset is written with a hyphen (technically a hyphen-minus), not a minus sign.
Use only IANA timezones.
Note that OpenAPI uses this format for `date-time` and `date` types.
For example:

```json
{
  "date-time": "2023-11-02T14:55:00-08:00",
  "timezone": "America/Los_Angeles"
}
```

You can append a timezone name per
[RFC 9557](https://datatracker.ietf.org/doc/html/rfc9557);
see [_affixing timezone names_](../post/iso-8601-problems.md#affixing-timezone-names).
Example:

```
2023-11-02T14:55:00-08:00[America/Los_Angeles]
```

#### Durations and intervals

??? rationale

    ISO 8601’s duration format is quite bad but already widespread.
    **See [problems with ISO 8601 durations](../post/iso-8601-problems.md#durations).**

A duration may be written these three ways:

1. A number of days, hours, minutes, seconds, etc.;
2. An [ISO 8601 duration](https://en.wikipedia.org/wiki/ISO_8601#Durations)
   using only integral hours, minutes, and seconds and starting with `PT`; or
3. Hours, minutes and seconds; i.e. `HH:MM:SS[.iii[iii]]` (also defined by ISO 8601).

**See [restricted ISO-8601 specification](../spec/fixed-iso-8601.md)**

**For intervals**, both `{"start": ..., "end": ...}` and ISO 8601 `T1--T2` syntax are acceptable.
Do not separate times with `/` or use a start-time/duration pair.

!!! note "Caution: calculating durations"

    Be careful when calculating durations.
    Things like NTP synchronization events can cause $T^C_1 - T^C_2$
    for a clock $C$ to not correspond
    to an elapsed time (or true duration).
    See [_calculating durations_](../post/calculating-durations.md).

## HTTP APIs

### Methods

| Method   | Symbol | Request body     | Response body |
| -------- | ------ | ---------------- | ------------- |
| `HEAD`   | 🎩     | ∅                | ∅             |
| `GET`    | 🔻     | ∅                | JSON          |
| `POST`   | ✉️     | JSON             | JSON          |
| `PUT`    | 🗃️     | JSON             | JSON or ∅     |
| `PATCH`  | 🩹     | JSON Merge Patch | JSON or ∅     |
| `DELETE` | 🗑️     | ∅                | JSON or ∅     |

/// table-caption
HTTP methods with request/response body formats, assuming a JSON-only API.
///

[JSON Merge Patch](https://datatracker.ietf.org/doc/rfc7396/)
SHOULD be used for all PATCH requests.
See the [JSON Merge Patch section](#json-merge-patch) for details and discussion.

### Status codes

This section applies to REST-like HTTP APIs.
Servers may only use response codes in accordance with this guideline.
The acceptable responses and conditions are listed in two tables below.
These are exhaustive;
servers must not use status codes, methods, responses, or conditions not listed here.

#### General status codes

!!! prerequisites "Legend"

    Refer to the HTTP Method symbols defined above.

| Code | Name                   | Methods     | Response  | Condition(s)                                  |
| ---- | ---------------------- | ----------- | --------- | --------------------------------------------- |
| 200  | OK                     | 🎩🔻🩹      | resource  | Requested resource is being returned          |
| 201  | Created                | ✉️ 🗃️       | ∅         | Resource has been created                     |
| 202  | Accepted               | 🔻✉️🗃️🩹🗑️† | ticket ‡  | Request is being processed asynchronously     |
| 204  | No Content             | 🗑️          | ∅         | Deletion was successful                       |
| 308  | Permanent Redirect     | ✉️🗃️🩹🗑    | resource  | Non-canonical URI was used                    |
| 400  | Bad Request            | any         | problem § | Invalid endpoint, params, or body syntax      |
| 401  | Unauthorized           | any         | problem   | Authentication was not provided               |
| 403  | Forbidden              | any         | problem   | Authentication with insufficient privileges   |
| 404  | Not Found              | 🔻🩹🗑️      | problem   | Resource does not exist                       |
| 406  | Not Acceptable         | 🎩🔻        | problem   | `Accept` headers are unsatisfiable            |
| 409  | Conflict               | ✉️🗃️🩹      | problem   | Resource already exists                       |
| 409  | Conflict               | 🗑️          | problem   | Can’t delete resource because it’s referenced |
| 410  | Gone                   | 🔻🩹🗑️      | problem   | Resource doesn’t exist, although it used to   |
| 413  | Content Too Large      | ✉️🗃️🩹      | problem   | Request payload is too large                  |
| 415  | Unsupported Media Type | ✉️🗃️🩹      | problem   | Request payload’s media type is unsupported   |
| 422  | Unprocessable Entity   | ✉️🗃️🩹      | problem   | Request has semantic errors                   |
| 429  | Too Many Requests      | any         | problem   | Client has exceeded the rate limit            |
| 500  | Server Error           | any         | problem   | Server encountered an internal error          |
| 503  | Service Unavailable    | any         | problem   | Overloaded or down for maintenance            |

/// table-caption
HTTP Response Codes with allowed methods, responses, and uses.
///

<small>
<!-- -->
<b>†</b> Use 202 Accepted in response to both
(1) A POST, PUT, PATCH, or (rarely) DELETE
to indicate that the request was accepted for asynchronous processing; and
(2) A GET sent before the resource is ready.
Use the same response format for both.

<b>‡</b>
The response SHOULD include a URI for polling and a suggested time or duration to poll.
Info about the progress (e.g. `"current-task": "post-process"`) may be included if helpful.
These keys are SUGGESTED:

```json
{
  "poll-uri": "https://api.tld/api/jobs/20od7-sk9khz",
  "wait-for": "2025-05-30T12:34:56Z",
  "wait-until": "2025-05-30T12:34:56Z"
}
```

<b>§</b> Use
[RFC 9457](https://datatracker.ietf.org/doc/rfc9457/#name-members-of-a-problem-detail)
problem details; see the [problem details section](#problem-details).

<!-- -->
</small>

#### Specialized status codes

| Code | Name                            | Methods  | Response | Use case                                   |
| ---- | ------------------------------- | -------- | -------- | ------------------------------------------ |
| 100  | Continue ♯                      | ✉️🗃️🩹   | ∅        | `100-continue` request succeeded (rare)    |
| 206  | Partial Content                 | 🔻       | part     | Range was requested and is being returned  |
| 304  | Not Modified                    | 🎩 🔻    | ∅        | `If-None-Match` condition has match.       |
| 412  | Precondition Failed ♯           | ✉️🗃️🩹🗑️ | problem  | Edit collision (`If-...` header)           |
| 416  | Range Not Satisfiable           | 🔻       | problem  | Requested range is out of bounds.          |
| 417  | Expectation Failed ♯            | ✉️🗃️🩹   | problem  | `Expect: 100-continue` expectation failed. |
| 418  | I'm a Teapot                    | any      | problem  | Blocked due to suspicious activity         |
| 423  | Locked                          | ✉️🗃️🩹🗑️ | problem  | Needed resource is in use _(discouraged)_  |
| 428  | Precondition Required ♯         | ✉️🗃️🩹🗑️ | problem  | `If-...` header required                   |
| 431  | Request Header Fields Too Large | any      | problem  | Headers are too large.                     |

<small>
<b>♯</b> These statuses are only applicable to modifiable resources.
</small>

#### 404 Not Found

404 Not Found is reserved for resources that _could_ exist but do not;
attempts to access an invalid endpoint must always generate a 400 (Bad Request).
For example, if `id` must be hexadecimal for `/machine/{id}`,
then `/machine/zzz` should generate a 400.
The response body in
[RFC 9457](https://datatracker.ietf.org/doc/rfc9457/#name-members-of-a-problem-detail)
problem details should describe the problem;
e.g. `{..., "detail": "{id} must match ^[0-9A-F]{16}$"}`.

Occasionally, the server might know that the resource will exist later.
For example, if the client PUT a resource, received a 202 Accepted,
and then tried to GET the resource too early.
A 404 is still appropriate for this.
You can indicate the resource’s status in the problem details (`detail` and/or custom field).

#### 422 Unprocessable Entity and 409 Conflict

Use 422 Unprocessable Entity for errors with respect to the model semantics and/or data.
For example, in `{"robot: "22-1-44", "action": "sit"}`, a 422 might be sent
if robot `22-1-44` does not exist or lacks sit/stand functionality.
A 409 Conflict might result if `22-1-44` is currently handling another command.
Respond 409 Conflict for conflicting <em>state</em>,
most notably to a request to delete a resource that other resources reference.

#### 418 I'm a Teapot

**This is an optional response.**
418 I'm a Teapot may be used to communicate with a client that has been locked out,
for reasons other than ratelimiting.
Although this status is nonstandard, some servers use it for similar reasons.

Clients should respond to these situations very differently than to other 4xx responses,
such as 401, 403, and 429.
A 418 conveys that:

1. The client cannot rectify the problem;
2. The server may or may not be willing to process a different request; and
3. The server may or may not accept the same request if it is re-sent later.

Use cases:

- Suspicious queries: The client has previously sent several suspicious queries.
- Clearly malicious query: The client is currently sending a query that is clearly malicious.
- Excessive data: The client has sent an excessive amount of data over a short period.

### JSON Merge Patch

For JSON, all PATCH endpoints must use [JSON Merge Patch](https://datatracker.ietf.org/doc/rfc7396/).
Because JSON Merge Patch uses `null` to signal deletion,
`null` may not be used for any other purpose.
See the [null section](#null-and-missing-values-numerical-range-and-precision) for more information.

For non-JSON data, there are two options:

1. Use JSON Merge Patch with a JSON string.
   If the data is binary, encode it as base64.
2. Use a multipart request with a JSON Merge Patch, with the Merge Patch first.
   The Merge Patch might choose to reference the additional files by filename.

## Problem details

Use [RFC 9457 (“problem details”)](https://datatracker.ietf.org/doc/rfc9457/).
All 4xx and 5xx responses must include an RFC 9457 body with media-type `application/problem+json`.

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

<b>Keys:</b>

- `title` (**required**): A short, human-readable title that ends with a period.
- `detail` (**required** sans 500 Server Error and 418 I'm a Teapot):
  A human-readable description of the problem in one or more complete sentences.
- `type` (**optional**; if used, it should be used for all responses):
  A URI at which the client can find more information about the problem type (see below).
- `status` (**optional**): The status code (e.g. `400`) shared with the response status code.
- `instance` (**optional**; if used, it should be used for all responses sans 500 and 418):
  A URI that identifies the specific occurrence of the problem for this response.
- extensions: Any additional keys that a client may find useful.

**There must be a 1-1 correspondence between `type` and `title`.**
It is recommended that the same `type`/`title` only map to one status code.

#### RFC 9457 `type` key

_Example:_ `https://domain.tld/help/error/client#dsl-parse`
As shown in the example, a
[URI fragment](https://en.wikipedia.org/wiki/URI_fragment) is perfectly acceptable.
The response body must include the problem detail’s `title` alongside a more detailed description.

Multiple representations must be available via content negotiation:

- `text/html; charset=utf-8` (**required** per RFC 9457):
  Include the title in an `<h1>`, ⋯, `<h6>`.
- `application/json` (**required**):
  Include at least the keys `title` and `description`.
- `text/x-markdown` (**recommended**):
  Include the title in an `#`, ⋯, `#####`.
  If OpenAPI is used, use the schema’s
  [`response.description`](https://spec.openapis.org/oas/v3.1.0#fixed-fields-14).

#### RFC 9457 extensions

Always include extensions that a client would likely want to parse.
For example, for a 400 Bad Request, specify the incorrect parameter or header.
For a 409 Conflict, specify the dependent resource.
Use kebab-case or camelCase according to the convention your overall API uses.
These extensions might occasionally be redundant to headers, such as `Accept` and `RateLimit-Limit`;
that’s fine.

### Response headers

#### Links

If [HATEOAS](https://en.wikipedia.org/wiki/HATEOAS)
links are used, they should be limited to direct connections.
For example, if a `species` resource links to its `genus`, which links to `family`,
`species` should **not** link to `family`.
To avoid polluting JSON response bodies, put the links in
[`Link` headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Link)
or [`See` headers](../spec/http-see-header.md).

#### Content types

Provide `Accept:` on non-`HEAD` requests – for example, `Accept: text/json`.
Similarly, provide `Content-Type:` on `POST` – for example, `Content-Type: text/json`.

#### Rate-limiting

Use the
[draft RateLimit headers](https://datatracker.ietf.org/doc/draft-ietf-httpapi-ratelimit-headers/):
`RateLimit-Limit`, `RateLimit-Remaining`, and `RateLimit-Reset`.
These should always be included for 429 (Too Many Requests) responses along with a
[`Retry-After`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Retry-After) header.
`RateLimit-Limit`, `RateLimit-Remaining`, and `RateLimit-Reset`
MAY be included for other responses as well.

#### Content-Disposition

Include `Content-Disposition: attachment` where it would be useful for browsers,
even if access via browsers is not expected.
This should include responses of > 10 MB.
The filename should include the resource type,
a resource id (or other value with a 1-1 correspondence with the resource),
and a filename extension.
Example:

```text
Content-Disposition: attachment; filename="store-item-5221-3q.parquet"
```

#### Warnings

Use the nonstandard header `Warning` for non-fatal issues.
The header should follow this format:

```text
Warning: <description>{; <key>="<value>"}
```

??? example "Examples"

    - `"Warning: deprecated endpoint; use-instead="https://domain.tld/api/endpoint"`
    - `"Warning: non-canonical URI; canonical="https://domain.tld/api/search?filter=color:eq:red"`

#### Other headers

Include:

- `Content-Length`
- `Content-Range` for 206 Partial Response responses
- `Location` for 201 Created responses
- `ETag` for modifiable resources
- `Last-Modified` for modifiable resources (optionally)
- `Vary` (optionally)
- `Cache-Control` (optionally)

You can omit `Date`, `Age`, `Origin`, `Host`, `Server`, and `From`.
If they’re already being sent, that’s also fine.
