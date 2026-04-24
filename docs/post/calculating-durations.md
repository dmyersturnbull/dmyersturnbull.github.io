---
tags:
  - datetimes
  - ISO-8601
  - RFC-3339
  - DSL
---

# Calculation durations

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

This document warns developers against calculating durations by subtracting date-times.
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

## Illustration of the problem

Calculating a duration by subtracting date-times is erroneous and a common software antipattern.

The following example shows an ML training procedure, written in a fictional `.lang` language.
It accesses the current system date-time both before training (`t0`) and after training (`t1`).
It writes the values as offset-aware RFC 3339 date-times; e.g. `2024-12-16T14:30-08:00`.
Those strings are later read and subtracted to calculate the amount of time the training took.
Real date-time libraries will happily subtract two date-times.

The problem is that an NTP sync, DST change, or related event could have occurred in `Model::train`.

```text title="train.lang"
run: (Model, Real[n,m] -> Void) := model, data -> (
  start   := Datetime::now()
  data    >> model::train     ; ⚡ DST started during this!
  end     := Datetime::now()
  stats   := Json::of(start, end)
  stats   >> ./stats.json
)
```

```text title="show-stats.lang"
show: Void := path -> (
  stats   << ./stats.json
  stats   >> STDOUT
  start   := Datetime::parse(stats.start)
  end     := Datetime::parse(stats.end)
  msg     := "The calculation took ${end - start}."
  msg     >> STDOUT
)
```

```text title="STDOUT"
{
  "start": "2024-12-16T14:30-08:00",
  "end": "2024-12-16T12:35-08:00"
}
The calculation took −56 minutes.
```

The clock was set back by one hour during the training, which took 4 minutes.
The result is 4 − 60 = −56 minutes.

### Solution 1: Use a monotonic clock

```text title="train.lang"
run: (Model, Real[n,m] -> Void) := model, data -> (
  start   := Datetime::now()
  c0      := MonoClock::now()
  data    >> model::train
  elapsed := MonoClock::now() - c0
  stats   := Json::of(start, elapsed)
  stats   >> ./stats.json
)
```

### Solution 2: Ask an NTP server

```text title="train.lang"
run: (Model, Real[n,m] -> Void) := model, data -> (
  start   := Datetime::ntp()
  data    >> model::train
  end     := Datetime::ntp()
  stats   := Json::of(start, end)
  stats   >> ./stats.json
)
```

### Also: don’t overflow

```text title="train.lang"
run: (Model, Real[n,m] -> Void) := model, data -> (
  start   := Datetime::now()
  c0      := MonoClock::now()
  timer   := Coroutine::periodic(1M, Coroutine::exit_if(c0+24H < MonoClock::now()))   ; ⚡ overflow
  timer   := Coroutine::periodic(1M, Coroutine::exit_if(MonoClock::now() - c0 > 24H)) ; fixed
  call    := Coroutine::map(data >> model::train, timer)
  call    >> Async::await
  ; ...
)
```
