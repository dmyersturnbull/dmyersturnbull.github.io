---
tags:
  - software-setup
---

# FFmpeg setup

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

## Compiling FFmpeg on Ubuntu

Configure hardware video encoding, if supported by your GPU.
QuickSync is one option; it should support AV1 eventually on Alder Lake and higher.

Then, compile ffmpeg with required options.

See:
[:fontawesome-solid-code: `files/install-ffmpeg.sh`](files/install-ffmpeg.sh).

_Credits: Cole Helsell drafted the original version of this guide with me._
