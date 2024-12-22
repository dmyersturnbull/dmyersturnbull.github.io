<!--
SPDX-FileCopyrightText: Copyright 2017-2024, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Windows setup

A setup guide for programmers, etc., on Windows.

!!! related

    [macOS setup guide](macos.md) and
    [Linux setup guide](linux.md)

## Hardware-specific setup

### Intel and NVIDIA

I used these steps on 6 Intel+NVIDIA workstation builds.

1. Download drivers from the [NVIDIA driver page](https://www.geforce.com/drivers).

2. Download and install the
   [Intel Extreme Tuning Utility](https://downloadcenter.intel.com/download/24075/Intel-Extreme-Tuning-Utility-Intel-XTU-).
   Open it and view the system info and temperatures.

3. Overclock:

   - Restart your computer, enter the BIOS, and open the overclocking settings.
     In general, you’ll want to overclock the memory to the XMP profile.
     This might mean a change from 2400 MHz to 3600 MHz.
   - Overclock the CPU and cache frequencies a little bit at a time.
     After each change, run the Intel tuning utility: Run multiple "benchmarks" and watch the temperature.

4. Install the [CUDA toolkit](https://developer.nvidia.com/cuda-downloads).

## Security & features

First, update Windows to the newest feature release.
In the security settings, enable Core Isolation and Trusted Platform Module in security settings.
Restart your computer.
If appropriate, enable BitLocker and restart again.

Purge Windows’s horrifically unnecessary built‐in apps.
In an unmistakably irresponsible choice, Windows comes with Candy Crush.
Err on the side of assuming they’re useless and shouldn’t be there.
[Kill it with fire](https://tvtropes.org/pmwiki/pmwiki.php/Main/KillItWithFire)
([1](https://www.wired.com/2013/10/why-kill-it-with-fire-is-a-terrible-terrible-idea/)).

Then install the Windows Developer Mode.
Go to the start menu and type _features_.
Navigate to
`Apps and Features → Manage optional features → add feature → Windows Developer Mode → install`.
Enable OpenSSH.
Disable unnecessary Optional Features---which is most of them,
including the Telnet Client, Windows Media Player, and PowerShell 2.0.
Uninstall Notepad and Wordpad.

??? info "Optional Features"

    Your list might have some differences.
    Mine eventually looked like this:

    | Feature                                         | On? |
    |-------------------------------------------------|-----|
    | .Net 3.5                                        |     |
    | .Net 4.8                                        | on  |
    | Internet Information Services                   |     |
    | Internet Information Services Hostable Web Core |     |
    | Legacy Components                               |     |
    | Media Features                                  |     |
    | Microsoft Message Queue (MSMQ) Server           |     |
    | Microsoft Print to PDF                          |     |
    | Microsoft XPS Document Writer                   |     |
    | Print and Document Services                     | on  |
    | Remote Differential Compression API Support     | on  |
    | Simple TCPIP services (i.e. echo, daytime etc)  |     |
    | SMB 1.0/CIFS File Sharing Support               |     |
    | Telnet Client                                   |     |
    | TFTP Client                                     |     |
    | Virtual Machine Platform                        | on  |
    | Windows Hypervisor Platform                     |     |
    | Windows Identity Foundation 3.5                 |     |
    | Windows Powershell 2.0                          |     |
    | Windows Process Activation Server               |     |
    | Windows Projected File System                   |     |
    | Windows Subsystem for Linux                     | on  |
    | Windows TIFF IFilter                            |     |
    | Work Folders Client                             |     |

## Power & update settings

In the power settings, disable hibernation, automatic sleep mode, and USB connection suspending.
While these can save power, chances are too high that they will interfere with a long‐running job or backup.

In some cases, you will want to disable scanning in a drive. This can drop performance.
It can even cause issues because it can open file handles, temporarily preventing writes;
this case it to interfered with data collection on our custom hardware.

Stop automatic updates by installing
[Win Update Stop](https://www.winupdatestop.com/).
Although I understand Microsoft’s rationale, it’s incredibly annoying that Windows forces a restart with short notice.
This is an enormous problem on a workstation that could be running an important job while you’re away --
and you don’t respond in time to postpone the update.
Plus, eventually you can’t postpone further.
To update Windows, first open Win Update Stop and enable updates.
Disable them again when you’re done.

## Chocolatey

Install [Chocolatey](https://chocolatey.org/), a fantastic package manager.
After installing, run `choco upgrade all -Y`.
Install powershell-core (`choco install powershell-core -Y`) and restart your terminal, choosing PowerShell Core.

Set powershell-core as your default shell.
Check the PowerShell version using: `Get-Host | Select-Object Version`. Make sure it’s 7+.

!!! tip

    Although I’m used to shell scripting Linux, Powershell is actually quite good.
    Instead of needing to parse text from stdout when piping between commands, the data structures
    passed around in PowerShell are _tables_. It’s a much better approach, and I recommend
    [learning it](https://devblogs.microsoft.com/powershell/getting-started-with-powershell-core-on-windows-mac-and-linux/).
    You can install it in Linux and macOS.

Install some essential packages by running

```powershell
choco install -Y poshgit gh libressl gnupg  rsync
```

??? tip "Other packages"

    Applications like Zoom, Spotify, DropBox, Chrome, and Firefox are also available.
    Here is a set of popular developer-oriented packages:

    ```powershell
    choco install -Y \
        adobereader \
        googlechrome \
        firefox \
        chocolatey-core.extension \
        teamviewer \
        7zip \
        vlc \
        notepadplusplus \
        sysinternals \
        awscli \
        zoom \
        ffmpeg \
        pandoc \
        treesizefree \
        docker-desktop \
    ```

Keep packages up-to-date by occasionally running `choco upgrade all`.

## Snappy & Scoop

Install [Scoop](https://scoop.sh/), which is great for software used for development:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex
```

Install [Snappy](https://snappy.computop.org/installing.html#windows), a cross-platform package manager.

## Git, SSH, & GPG

**Follow the [Git, SSH, & GPG guide](git-ssh-and-gpg.md)**.
The SSH key and config instructions work in PowerShell because OpenSSH is installed.
Note that GitHub CLI was installed via Chocolatey (in the steps above).

## Language tools

[Install the Rust toolchain](https://rustup.rs/).

Check <i>Add or Remove Programs</i> for _Java_. Uninstall any versions you have installed.
Then, download [JDK 21 LTS from Temurin](https://adoptium.net/temurin/releases/)
(or a newer non-LTS version if preferred).
Do **not** use Java 8, java.com, or OpenJDK.
Make sure it’s on your `$PATH` by checking the version via `java --version` in a new shell.

!!! tip "Pro-tip"

    Install both via

    === "Scoop"

        ```powershell
        scoop install main/rust
        scoop bucket add java
        scoop install java/temurin-jdk
        ```

    === "Chocolatey"

        ```powershell
        choco install -Y temurin rust python
        ```

??? bug "If the JDK is not on your `$PATH`"

    This may happen if you install the JDK manually.
    Confirm where it was installed; t’s likely to be (e.g.) `C:\Program Files\Java\jdk-21`.
    In an administrator console, run this:

    ```powershell
    [Environment]::SetEnvironmentVariable(\
        "Path",\
        [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)\
            + ";C:\Program Files\Java\jdk-21",\
        [EnvironmentVariableTarget]::Machine\
    )
    ```

Install Node.js and Python:

```powershell
scoop bucket add main
scoop install nodejs python
```

Finally, install [pnpm](https://pnpm.io/), a faster alternative to npm:

```powershell
iwr https://get.pnpm.io/install.ps1 -useb | iex
```

## Visual C++ Build Tools

Install the [Visual C++ Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/)
**This is not the same as the "redistributable" package.**
Install the package without optional packages (unless they’re wanted).

!!! bug "Troubleshooting / compiling packages"

    Some packages do not publish wheels for Windows.
    Pip and Poetry will fall back to compiling on Windows if suitable wheels are not found.
    You may need to install older versions of the Visual C++ Build Tools for this to work (as well as the latest).
    However, also take a look at
    [Christopher Golhlke’s wheel archive](https://www.lfd.uci.edu/~gohlke/pythonlibs/).
    It often has Windows wheels for the latest Python versions much earlier than the packages officially release them.

## Windows Linux Subsystem

Follow [Microsoft’s instructions](https://learn.microsoft.com/en-us/windows/wsl/install) to install the WLS.
Then follow the [Linux setup guide](linux.md).

\*[WLS]: Windows Linux Subsystem

!!! note "Thanks"

    Thank you to Cole Helsell for drafting this guide with me.
