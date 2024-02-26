# API conventions

## JSON and data representation

Follow the [Google JSON guide](https://google.github.io/styleguide/jsoncstyleguide.xml).
Contradicting that guide, property names may follow other conventions if needed to accommodate other needs.
Avoid periods (`.`) in property names;
doing so complicates using [JsonPath](https://github.com/json-path/JsonPath),
[JMESPath](https://jmespath.org/), [jq](https://jqlang.github.io/jq/),
[YAML](https://yaml.org/), and [TOML](https://toml.io/).
Avoid allowing multiple types per key or array.
That means avoiding JSON Schema’s `anyOf` (or `oneOf`) with multiple `type`s.

### Null and missing values

**Do not use JSON `null`**, except in [JSON Merge Patch](https://datatracker.ietf.org/doc/html/rfc7396).
JSON Merge Patch uses it to signal deletion, so using `null` for other purposes effectively prevents HTTP `PATCH`.
It’s problematic for other reasons; refer to the _rationale_ box.
Tip: replace any `{"key": null}` with `{}` or (e.g.) `{"status: "error:too_few_samples}"}`.
If a null value is encountered (e.g. in a received payload), pretend the key–value pair isn’t present.

??? rationale

    Null values:

    1. Clash with [JSON Merge Patch / RFC 7396](https://datatracker.ietf.org/doc/html/rfc7396).
       They cannot be expressed because the standard reserves `null` for deletions; and
    2. Have no agreed-upon or obvious meaning.
       They could signal an invalid value, a truly missing value (i.e. never found/added),
       or a selective decision to exclude (e.g. to save bandwidth).

    <small>
    About using `null` for missing-but-schema-supported keys:
    This practice is not obvious, wastes bandwidth, is supurfulous to the schema, and breaks if the schema changes.
    Specifying allowed keys is a schema’s job.
    </small>

#### NaN, Inf, and -Inf

JSON floats cannot store `NaN`, `Inf`, or `-Inf`.
If such values are applicable, encode all those data as strings.
For example, if values in an array can be a float, `Inf`, or `-Inf`, encode it like this:
`["5.3", "Inf", "6.8", "-Inf"]`.
Use exactly `NaN`, `Inf`, or `-Inf`, with that capitalization.

#### Case study: Representing inconclusive or unknown values

Null values are often used to encode types like `string | null` and `int | null`.
Instead, be explicit about `null`’s meaning.

Consider a sensor measuring electric current.
The values are then divided by preceeding average to get a ratio, that is,

$$
R(I_t) = \left. I_t \middle/ \text{Avg}_{i=1}^{t-1} I_i \right.
$$
, where $I_t$ is the current on trial (measurement $t$).
Compare these two representations:

=== "❌ Incorrect"

    Here,

    ```json
    [
      {"trial": 1, "value": 12.0},
      {"trial": 2, "value": null},  # (1)!
    ]
    ```

    1. Did the measurement fail? A hardware connection issue?
       Was the ratio `Inf` ($1/0$), `-Inf` ($-1/0$), or `NaN` ($0/0$)?

=== "✅ Correct"

    ```json
    [
      {"trial": 1, "status": "success", "value": 12.0},
      {"trial": 2, "status": "err:no_signal"}  # (1)!
    ]
    ```

    1. Specify the status values with a JSON Schema `enum`.
       `{"success": <boolean>}` may be sufficient instead.

### Range and precision

Generally, assume that JSON consumers will use IEEE 754 _double_ range and precision.
When writing numbers that might exceed that range or precision (where that precision is important),
encode them as strings (as in the previous section).

### Encoding specific types

#### Dates and times

Use [RFC 3339](https://www.rfc-editor.org/rfc/rfc3339), including a UTC offset.
Note that the UTC offset is written with a hyphen, not a minus sign.
Use only IANA timezones, encoded separately.
For example:

```json
{
  "date-time": "2023-11-02T14:55:00 -08:00",
  "timezone": "America/Los_Angeles"
}
```

**Note:** A timezone, not just a UTC offset, is necessary to compute the duration between two times.

#### Durations and intervals

Clearly distinguish between **elapsed** and **wall clock** durations,
either in JSON keys or by associated documentation.

??? details "Explanation"

    $D = T^C_2 - T^C_1$ for times $T_2$ and $T_1$, for a clock $C$, depends on the kind of clock.
    If $C$ is monotonic system time, or an NTP server time, $D$ is an elapsed duration.
    If $C$ is an NTP-synced operating system clock, or a system up time: $D$ is **not** an elapsed duration.

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
Do not separate times with `/` or use a time/duration pair.

## HTTP APIs

### Status codes

This section applies to REST-like HTTP APIs.
Servers should only issue response codes in accordance with the following table.

<b>Importantly:</b>
404 (Not Found) is reserved for resources that _could_ exist but do not;
attempts to access an invalid endpoint must always generate a 400 (Bad Request).

<small>
<b>Note:</b>
Few services need every response in this table.
</small>

| code | name                    | methods                       | Body     | use case                             |
|------|-------------------------|-------------------------------|----------|--------------------------------------|
| 100  | Continue                | `POST`/`PUT`/`PATCH`          | ∅        | `Expect: 100-continue` ok            |
| 200  | OK                      | `GET`/`HEAD`/`PATCH`          | resource |                                      |
| 201  | Created                 | `POST`/`PUT`                  | resource |                                      |
| 202  | Accepted                | `POST`                        | ∅        |                                      |
| 204  | No Content              | `DELETE`                      | ∅        | Successful deletion                  |
| 206  | Partial Content         | `GET`                         | partial  | Range was requested                  |
| 303  | See Other †             | any                           | ∅        | Removed endpoint has alternative     |
| 304  | Not Modified ‡          | `GET`/`HEAD`                  | ∅        | `If-None-Match` matches              |
| 308  | Permanent Redirect †    | any                           | ∅        | Endpoint moved                       |
| 400  | Bad Request             | any                           | ∅        | Invalid endpoint                     |
| 401  | Unauthorized            | any                           | ∅        | Not authenticated                    |
| 403  | Forbidden               | any                           | ∅        | Insufficient privileges              |
| 404  | Not Found               | `GET`/`DELETE`/`PATCH`        | ∅        | Resource does not exist              |
| 406  | Not Acceptable          | `GET`/`HEAD`                  | error    | `Accept` headers unsatisfiable       |
| 409  | Conflict                | `PUT`/`POST`                  | error    | Resource already exists              |
| 410  | Gone †                  | any                           | error/∅  | Endpoint removed with no alternative |
| 412  | Precondition Failed ‡   | `POST`/`PUT`/`DELETE`/`PATCH` | error/∅  | Mid-air edit (`If-...`)              |
| 413  | Content Too Large †     | `POST`/`PUT`/`DELETE`/`PATCH` | ∅        |                                      |
| 414  | URI Too Long †          | `GET`/`PUT`/`DELETE`/`PATCH`  | ∅        |                                      |
| 415  | Unsupported Media Type  | `POST`/`PUT`/`PATCH`          | error    | Invalid payload media type           |
| 416  | Range Not Satisfiable   | `GET`                         | ∅        | Requested range out of bounds        |
| 417  | Expectation Failed  ‡   | `POST`/`PUT`/`PATCH`          | error    | `Expect: 100-continue` failed        |
| 422  | Unprocessable Entity    | `POST`/`PUT`/`PATCH`          | error    | Payload references invalid ID, etc.  |
| 418  | I'm a teapot  §         | any                           | ∅        | Request blocked                      |
| 428  | Precondition Required ‡ | `POST`/`PUT`/`DELETE`/`PATCH` | ∅        | `If-...` required                    |
| 429  | Too Many Requests       | any                           | error/∅  | Ratelimit hit                        |
| 431  | … Fields Too Large      | any                           | error/∅  |                                      |
| 500  | Server Error            | any                           | error/∅  | General server error                 |
| 501  | Not Implemented †       | any                           | error    | Optionally in a canary release       |
| 503  | Service Unavailable     | any                           | error    | Maintenance or overload              |

<b>Notes:</b>

<p>
<small>
† 400 Bad Request is an acceptable and simpler alternative.
</small>
</p>
<p>
<small>
‡ Use these only in APIs that are stateful or use PATCH in a non-idempotent and order-dependent way.
This will not occur if [JSON Merge Patch](https://datatracker.ietf.org/doc/html/rfc7396) is always used.
</small>
</p>
<p>
<small>
§ 418 I'm a Teapot is nonstandard but often used to mean
“I’m ignoring you because I am suspicious of and/or angry with you.”
The server decided that the current request, or a prior request, was potentially malicious or otherwise problematic.
</small>
</p>
<p>
<small>
403 Forbidden is similar, and neither indicates whether the request is otherwise valid.
However, users may assume a 403 means that obtaining necessary credentials may correct the problem.
In contrast, 418 I'm a Teapot indicates that the client cannot rectify the problem;
the server may or may not process a different request, and it may or may not allow the request later.
</small>
</p>
<p>
<small>
429 Too Many Requests also differs.
A single specific request may trigger a 418 I'm a Teapot,
and the normal rate-limiting headers (see below) are ommitted.
</small>
</p>

<b>Response bodies:</b>

`resource`

: `{"uri": "https://domain.tld/api/thing/1"}`.
  The value should be the canonical URI for which `GET` returns the resource.

`error`

: An [RFC 7807](https://datatracker.ietf.org/doc/html/rfc7807) JSON payload

### Headers

#### Content types

Provide `Accept:` on non-`HEAD` requests – for example, `Content-Type: text/json`.
Similarly, provide `Content-Type:` on `POST` – for example, `Content-Type: text/json`.

#### Rate-limiting

Use [draft IETF rate-limiting headers](https://www.ietf.org/archive/id/draft-polli-ratelimit-headers-02.html):
`RateLimit-Limit`, `RateLimit-Remaining`, and `RateLimit-Reset`.
These should always be included for 429 (Too Many Requests) responses
and MAY be included for other responses as well.

## Formal grammars

??? rationale

    `=/` modifies an already-defined rule, which complicates reading.
    `LWSP` is commonly understood to be problematic.

Grammars may be specified in any well-known form.
However, [ABNF](https://en.wikipedia.org/wiki/Augmented_Backus%E2%80%93Naur_form) is preferred.
See [RFC5234](https://datatracker.ietf.org/doc/html/rfc5234).
It is sometimes useful to assign uppercase names to rules that would probably be parsed by a lexer.
Do not use ABNF incremental alternatives notation (`=/`).
Also avoid these core rules, which are misleading because of their restriction to US-ASCII:

- `CHAR` (“any 7-bit US-ASCII character, excluding NUL”)
- `LWSP` (“linear white space”)
- `CTL` (“controls")
- `VCHAR` (“visible (printing) characters”)
- `WSP` (“whitespace”)
