
# Arduino setup

## Install Arduino

!!! note
    If you are on Windows, make sure `curl` is available.
    You can get it via [Git for Windows](https://gitforwindows.org/).

    - Using [Chocolatey](https://chocolatey.org/): `choco install poshgit`.
    - Using Scoop: `scoop install main/curl`.

Download and install [Arduino](https://www.arduino.cc/).

=== "Linux"

    ```bash
    curl -L -O -J \
        https://github.com/arduino/arduino-ide/releases/download/2.2.1/arduino-ide_2.2.1_Linux_64bit.zip
    unzip arduino-ide_2.2.1_Linux_64bit.zip
    rm -r arduino-ide_2.2.1_Linux_64bit.zip
    sudo mv arduino-ide_2.2.1_Linux_64bit /opt/arduino
    ```

=== "Windows"

    ```powershell
    curl -L -O -J \
        https://github.com/arduino/arduino-ide/releases/download/2.2.1/arduino-ide_2.2.1_Windows_64bit.msi
    .\arduino-ide_2.2.1_Windows_64bit.msi
    ```

=== "macOS"

    ```powershell
    curl -L -O -J \
        https://github.com/arduino/arduino-ide/releases/download/2.2.1/arduino-ide_2.2.1_macOS_64bit.dmg
    open -a arduino-ide_2.2.1_macOS_64bit.dmg
    ```
