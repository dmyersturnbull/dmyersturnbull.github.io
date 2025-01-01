## Restricted ISO 8601

!!! related

    - [Problems with ISO 8601 durations](../post/iso-8601-problems.md#durations)
    - [API conventions](../convention/apis.md#durations-and-intervals)

## Date-times and intervals

Use [RFC 3339](https://datatracker.ietf.org/doc/html/rfc3339).
However, do **not** use `-00:00`, and do **not** use `_` (instead, use `T`).
If fractional seconds are needed, use exactly 6 decimal digits, 0-padded (e.g. `:00.000000`).
Nanoseconds cannot be stored exactly in a (signed or unsigned) float32 or int32, are often not supported, and are almost always very imprecise.
If nanoseconds or below are needed, store them separately.

```regexp
^
(?P<year>\d{4})
-(?P<month>0[1-9]|1[012])
-(?P<day>0[1-9]|[1-2]\d|3[01])
T(?P<hour>[1-9]|1\d|2[0-3])
:(?P<minute>[1-9]|[1-5]\d)
:(?P<second>[1-9]|[1-5]\d(?:\.\d{6})?+)
(?P<offset>Z|[+-]\d{2}:\d{2})
$
```

### Timezone names

[RFC 9557](https://datatracker.ietf.org/doc/html/rfc9557) supports
[affixing a timezone](../post/iso-8601-problems.md#affixing-timezone-names)
or other information to a timezone.
You MAY include a timezone name in the form `[America/Los_Angeles]`.
The prefix `!` (meaning _critical_) MUST NOT be used.

Timezone names:

- MUST be recognized by [IANA](https://www.iana.org/time-zones);
- SHOULD be marked Canonical (not Link);
- SHOULD NOT be `Factory`; and
- SHOULD NOT start with `Etc/`, except for `Etc/UTC`.
- SHOULD NOT use `Etc/UTC` in place of `Europe/London`.

??? example "Example – RFC 9557"

    ```json
    {
      "local-date-time": "2023-11-02T06:20:45-08:00[America/Los_Angeles]",
      "utc-date-time": "2023-11-02T014:20:45Z",
      "source": "0.amazon.pool.ntp.org"
    }
    ```

??? example "Example – explicit"

    ```json
    {
      "utc-date-time": "2023-11-02T14:20:45Z",
      "local-offset": "-08:00",
      "local-zone": "America/Los_Angeles",
      "source": "0.amazon.pool.ntp.org"
    }
    ```

### Intervals

Write intervals using 2 RFC 3339 date-times, separated by `--`.
ISO 8601 permits `--` instead of `/`, which is problematic in URIs and filesystem paths.

I [advise against repeating intervals](../post/iso-8601-problems.md#intervals),
and they are not part of this spec.
Represent them explicitly instead.

??? example "Example – recurring events"

    ```json
    {
      "start": "2024-01-01T09:15:00[-08:00]",
      "end": "2024-01-01T10:00:00[-08:00]",
      "repeat-every": "PT24H",
      "n-events": 7
    }
    ```

## Durations

ISO 8601’s duration format is quite bad but already widespread.
I fixed it by restricting the syntax.
Years, months, and days were removed, along with fractional components (e.g. `PT1.5H`).
The result is `PT<h>H[<m>M[<s>S]]`, which is trivial parse and convert to `hh:mm:ss`.

=== "`PT` syntax"

    ```regexp
    (?
    ^
    PT
    (?:(?P<hour>\d)H)??
    (?:(?P<minute>\d++)M)??
    (?:
    (?P<second>\d++S)?+
    (?:\.(?P<microsecond>\d{1,6}++)?+
    )
    $
    )
    ```

=== "HH:MM:SS syntax"

    ```regexp
    (?
    ^
    (?P<hour>\d{2,}+)
    :(?P<minute>[0-5]\d)
    :(?P<second>[0-5]\d)
    (?:\.(?P<microsecond>\d{6}))?+
    $
    )
    ```

???+ example "Examples"

    **✅ ok** `PT23H45M55.8S` (per the spec, `0.8S` means 8 milliseconds)

    **✅ ok** `23:45:55`

    **✅ ok** `23:45:55.800200` (800 milliseconds and 200 microseconds)

    **❌ not ok** `23:45:55.2` – unclear: is `0.8` 8 or 800 milliseconds?

    **❌ not ok** `23:45:55.800` – use exactly 0 or 6 decimal digits

    **❌ not ok** `P6M2WT45M55S` – ambiguous because months have indeterminate durations

    **❌ not ok** `P1D12H` – unambiguous but not limited to hours, minutes, and seconds

    **❌ not ok** `P2S` – does not start with `PT`; rewrite as `PT2S`

    **❌ not ok** `05:22` – is this `min:sec` or `hour:min`?

    **🟨 not in spec** `35.2 s` – unambiguous; not in spec but good in documentation

## JSON Schema

This is the full specification.

```yaml
date-time:
  type: string
  pattern: >-
    (?P<year>\d{4})
    -(?P<month>0[1-9]|1[012])
    -(?P<day>0[1-9]|[1-2]\d|3[01])
    T(?P<hour>[1-9]|1\d|2[0-3])
    :(?P<minute>[1-9]|[1-5]\d)
    :(?:
    (?P<second>[1-9]|[1-5]\d)
    (?P<microsecond>\.\d{6})?+
    )
    (?P<offset>Z|[+-]\d{2}:\d{2})
    (?:
    \[
    (?P<zone>
    (?:[A-Z][A-Za-z0-9]*+(?:[_+-][A-Za-z0-9]++)))
    (?:/[A-Z][A-Za-z0-9]*+(?:[_+-][A-Za-z0-9]++)){0,3}+
    )
    \]
    )?+

interval:
  type: object
  required:
    - start
    - end
  properties:
    start:
      $ref: "#/date-time"
    end:
      $ref: "#/date-time"

interval-string:
  type: string
  pattern: >-
    (?P<start>
    \d{4}(0[1-9]|1[012])(0[1-9]|[1-2]\d|3[01])
    T([1-9]|1\d|2[0-3]):([1-9]|[1-5]\d):([1-9]|[1-5]\d)(\.\d{6})?+
    (Z|[+-]\d{2}:\d{2})
    )
    --
    (?P<end>
    \d{4}(0[1-9]|1[012])(0[1-9]|[1-2]\d|3[01])
    T([1-9]|1\d|2[0-3]):([1-9]|[1-5]\d):([1-9]|[1-5]\d)(\.\d{6})?+
    (Z|[+-]\d{2}:\d{2})
    )

duration:
  oneOf:
    - $ref: "#/components/schemas/pt-duration"
    - $ref: "#/components/schemas/hhmmss-duration"

pt-duration:
  type: string
  pattern: >-
    ^
    PT
    (?:(?P<hour>\d)H)??
    (?:(?P<minute>\d++)M)??
    (?:
    (?P<second>\d++S)?+
    (?:\.(?P<microsecond>\d{1,6}++)?+)
    )
    $

hhmmss-duration:
  type: string
  pattern: >-
    ^
    (?P<hour>\d{2,}+)
    :(?P<minute>[0-5]\d)
    :(?P<second>[0-5]\d)
    (?:\.(?P<microsecond>\d{6}))?+
    $
```
