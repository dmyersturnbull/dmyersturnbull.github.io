---
tags:
  - software-setup
---

# Arduino setup

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

## Install Arduino

!!! prerequisites

    You need the [GitHub CLI](https://github.com/cli/cli) (`gh`).

These instructions, though hardly worth keeping, show how to download and install the
[Arduino IDE](https://www.arduino.cc/en/software/)
from its [home on GitHub](https://github.com/arduino/arduino-ide).

=== "Linux (x86-64)"

    ```bash
    gh release download --repo arduino/arduino-ide --pattern 'arduino-ide_*64bit.AppImage'
    f=$(ls *.AppImage)
    chmod +x "$f"
    dest="$HOME"/bin/arduino/"${f##*/}"
    mkdir -p "$(dirname "$dest")"
    mv "$f" "$dest"
    printf "Installed to '%s'.\n" "$dest"
    ```

=== "Windows"

    ```bash
    gh release download --repo arduino/arduino-ide --pattern 'arduino-ide_*64bit.msi'
    open arduino-ide_*64bit.msi
    ```

=== "macOS (ARM)"

    ```bash
    gh release download --repo arduino/arduino-ide --pattern 'arduino-ide_*arm64.dmg'
    open arduino-ide_*arm64.dmg
    ```

=== "macOS (Intel)"

    ```bash
    gh release download --repo arduino/arduino-ide --pattern 'arduino-ide_*64bit.dmg'
    open arduino-ide_*64bit.dmg
    ```
