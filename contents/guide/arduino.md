# Arduino setup

<!--
SPDX-FileCopyrightText: Copyright 2017-2024, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

## Install Arduino

!!! note

    You need [GitHub CLI](https://github.com/cli/cli) (`gh`).

Download and install [Arduino](https://www.arduino.cc/).

=== "Linux"

    ```bash
    gh release download --repo arduino/arduino-ide --archive=zip --dir arduino-temp
    unzip arduino-temp/*.zip
    sudo mv $(( ls -Art arduino-temp/ | tail -n 1 )) /opt/arduino
    rm -r arduino-temp
    ```

=== "Windows"

    Install the latest from the
    [Arduino GitHub downloads](https://github.com/arduino/arduino-ide/releases/download/).

=== "macOS"

    ```bash
    gh release download --repo arduino/arduino-ide --archive=dmg --dir arduino-temp
    open -a $(( ls -Art arduino-temp/*.dmg | tail -n 1 ))
    rm -r arduino-temp/
    ```
