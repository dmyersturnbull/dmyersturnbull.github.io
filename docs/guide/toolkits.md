---
tags:
  - Java
  - OS-setup
  - Python
  - Rust
  - software-setup
---

# Toolkits

<!--
SPDX-FileCopyrightText: Copyright 2017-2026, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

## Rust

For Rust, just [install the Rust toolchain](https://rustup.rs/).

## Java

For Java, download [the latest Temurin JDK](https://adoptium.net/temurin/releases/).

To understand why you should use Temurin, see
[whichjdk.com](https://whichjdk.com/).
Do **not** use Java 8, java.com, jdk.java.net, a pre-installed JDK, or the `openjdk` apt package.

Make sure it’s on your `$PATH` by checking the version via `java --version` and `javac --version`.
Example:

```console
openjdk 26.0.1 2026-05-06
OpenJDK Runtime Environment Temurin-26.0.1+8 (build 26.0.1+8)
OpenJDK 64-Bit Server VM Temurin-26.0.1+8 (build 26.0.1+8, mixed mode, sharing)
```

## Python

For Python, install and use [uv](https://docs.astral.sh/uv/).
You don’t need anything else — and you **really shouldn’t use anything else**.

After installing uv, use it to install the latest Python version:

```powershell
uv python install --default
```

