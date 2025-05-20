## Rust

For Rust, just [install the Rust toolchain](https://rustup.rs/).

## Java

For Java, download [the latest JDK from Temurin](https://adoptium.net/temurin/releases/).

To understand why you should use Temurin, see
[whichjdk.com](https://whichjdk.com/).
In particular,
do **not** use Java 8, java.com, jdk.java.net, a pre-installed JDK, or the `openjdk` apt package.

!!! tip "Pro-tip – macOS"

    Temurin releases are available on Homebrew, so just run

    ```bash
    brew install --cask temurin
    ```

Make sure it’s on your `$PATH` by checking the version via `java --version` and `javac --version`.
Example:

```console
❯ openjdk 24.0.1 2025-04-15
OpenJDK Runtime Environment Temurin-24.0.1+9 (build 24.0.1+9)
OpenJDK 64-Bit Server VM Temurin-24.0.1+9 (build 24.0.1+9, mixed mode, sharing)
```

## Python

For Python, install and use [uv](https://docs.astral.sh/uv/).
You don’t need anything else – and you **really shouldn’t use anything else**.
Make your life easier:
(1) Leave your system Python alone,
(2) don’t install Python via a package manager,
and (3) install and use Conda/Mamba only if necessary.

_[LTS]: Long-Term Support
_[JDK]: Java Development Kit
