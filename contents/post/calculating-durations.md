# Calculation durations

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

This document serves only to warn developers against calculating durations by subtracting date-times.
**Don’t.**
To know the amount of time something takes,
**you need either a monotonic clock or calls to an NTP server.**

## Your options

You need to either:

1. Use a monotonic system clock; or
2. Explicitly request the time from an NTP server.

For other purposes, you should also retain the
[IANA timezone](https://www.iana.org/time-zones).
I won’t get into that.

## The problem

Calculating a duration by subtracting date-times is erroneous and a common software antipattern.

The following example shows an ML training procedure, written in a fictional `.lang` language.
It accesses the current system date-time both before training (`t0`) and after training (`t1`).
It writes the values as offset-aware ISO 8601 date-times; e.g. `2024-12-16 T 14:30 -08:00`.
Those strings are later read and subtracted to calculate the amount of time the training took.
Real date-time libraries will happily subtract two date-times.

The problem is that an NTP sync, DST change, or related event could have occurred during `ml-train`.

```text title="train.lang"
main() {
    t0       = sys::current_datetime()
    train()  << "training.data"
    t1       = sys::current_datetime()
    stats    = {"t0": "$t0", "t1": "$t1"}
    stats    >> "stats.json"
}
```

```text title="show-stats.lang"
stats = read("stats.json")
///
{
  "t0": "2024-12-16 T 14:30 -08:00",
  "t1": "2024-12-16 T 15:35 -08:00"
}
///

start = datetime::parse(stats.t0)
end   = datetime::parse(stats.t1)

write "The calculation took ${end - start}."
///
The calculation took 1 hr, 5 min.
///
```
