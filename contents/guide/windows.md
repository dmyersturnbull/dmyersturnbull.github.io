---
tags:
  - Windows
  - OS-setup
---

# Windows setup

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

A setup guide for programmers, etc., on Windows.

!!! related

    - [macOS setup guide](macos.md)
    - [Linux setup guide](linux.md)

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

## Security and cleanup

### Security & features

First, update Windows to the newest feature release.
In the security settings, enable Core Isolation and Trusted Platform Module in security settings.
Restart your computer.
If appropriate, enable BitLocker and restart again.

### Built-in apps

Purge Windows’s horrifically unnecessary built‐in apps.
In an unmistakably irresponsible choice, Windows comes with Candy Crush.
Err on the side of assuming they’re useless and shouldn’t be there.
[Kill it with fire](https://tvtropes.org/pmwiki/pmwiki.php/Main/KillItWithFire)
([1](https://www.wired.com/2013/10/why-kill-it-with-fire-is-a-terrible-terrible-idea/)).

### Optional Features

Install the Windows Developer Mode.
Go to the start menu and type _features_.
Navigate to
_Apps and Features ➤ Manage optional features ➤ add feature ➤ Windows Developer Mode ➤ install_.

Also enable OpenSSH, uninstall Notepad and Wordpad, and disable other unnecessary Optional Features
(most of them are unnecessary).
These include the Telnet Client, Windows Media Player, and PowerShell 2.0.

??? example "Example Optional Features"

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

## System settings

### Services

!!! warning

    Be careful when disabling services.
    When in doubt, leave a service alone.

Next, open the Services app.
Disable unnecessary services (set them to _Manual_ start).
However, set Windows Time Service to _Automatic_ to force an NTP sync every startup.
Otherwise, your system clock can drift seconds or even minutes after a small number of restarts.

### Power settings

In the power settings, disable hibernation, automatic sleep mode, and USB connection suspending.
Although these can save power, they’re likely to interfere with a long‐running job or backup.

In some cases, you will want to disable scanning in a drive. This can drop performance.
It can even cause issues because it can open file handles, temporarily preventing writes;
this case it to interfered with data collection on our custom hardware.

### Update settings

#### How Windows manages updates

Although I understand Microsoft’s rationale,
it’s frustrating that Windows automatically downloads updates.
The updates **share bandwidth** with everything else.
In an important meeting or a remote interview?
If you don’t see the notification (e.g. in Focus Mode), it’s going to be rough.

Even more frustrating is that it forces restarts, providing only a short window to postpone.
That’s a serious problem for any **non-interruptable or time-sensitive task** you leave running
because you can’t postpone a restart if you’re not there.
Apps often won’t block the restart.
Worse, Windows eventually stops further postponing.

#### Configuring via _Settings_

First, review the settings under _Settings ➤ Windows Updates ➤ Advanced options_.
Set _Active hours_ and make sure _Get me up to date_ is unchecked.†

<small>
<b>†</b>
Although you can throttle download speeds,
but that applies even when you’re idle and would want to download updates
(and may, in fact, want it to finish quickly).
I recommend keeping this option disabled and instead make sure
</small>

#### Making updates non-automatic

_Note: The following section was reviewed and updated as of April 2025._

You may want to disable automatic updates to manage them yourself,
something Windows doesn’t normally allow.
An app I used and recommended called Win Update Stop is now paid-only.
The GitHub repo
[Aetherinox/pause-windows-updates](https://github.com/Aetherinox/pause-windows-updates)
has a pair of registry keys, one to pause and another to resume.
It worked flawlessly on my laptop, but I have only tested it on that machine.
Alternatively you can search for
[other apps on GitHub](https://github.com/search?q=disable+windows+11+updates&type=repositories).

!!! warning

    Make sure that any app includes an on/off toggle or that it doesn’t prevent manual updates.
    Additionally, check that it can be fully uninstalled.

## Chocolatey and Powershell Core

Install [Chocolatey](https://chocolatey.org/), a fantastic package manager.
After installing, run `choco upgrade all -Y`.
Install powershell-core (`choco install powershell-core -Y`)
and restart your terminal, choosing PowerShell Core.

Set powershell-core as your default shell.
Check the PowerShell version using: `Get-Host | Select-Object Version`. Make sure it’s 7+.

!!! tip "Tip: PowerShell"

    Although I’m used to shell scripting Linux, Powershell is actually quite good.
    Instead of needing to parse text from stdout when piping between commands, the data structures
    passed around in PowerShell are _tables_. It’s a much better approach, and I recommend
    [learning it](https://devblogs.microsoft.com/powershell/getting-started-with-powershell-core-on-windows-mac-and-linux/).
    You can install it in Linux and macOS.

Install some essential packages by running

```powershell
choco install -Y poshgit gh libressl gnupg rsync
```

??? tip "Tip: Other packages"

    Applications like Zoom, Spotify, DropBox, Chrome, and Firefox are also available.
    Here is a set of popular developer-oriented packages:

    ```powershell
    choco install -Y \
      chocolatey-core.extension \
      sysinternal notepadplusplus 7zip \
      googlechrome firefox teamviewer \
      vlc ffmpeg pandoc treesizefree
    ```

Keep packages up-to-date by occasionally running `choco upgrade all`.

## Other package managers (Snappy & Scoop)

Install [Snappy](https://snappy.computop.org/installing.html#windows),
a cross-platform package manager.
Then install [Scoop](https://scoop.sh/),
another package manager specialized for software development.

## Git, SSH, & GPG

**Follow the [Git, SSH, & GPG guide](git-ssh-and-gpg.md)**.
The SSH key and config instructions work in PowerShell because OpenSSH is installed.
Note that GitHub CLI was installed via Chocolatey (in the steps above).

## Programming languages and frameworks

**Note:** Before installing a package,
check for and uninstall any existing copy under _Add or Remove Programs_.
For example, you’ll want to uninstall the copy of Java that ships with Windows.

### Java, Rust, and Python

!!! tip "Tip: automate with a package manager"

    Install Rust and Java via either Scoop or Chocolatey:

    === "Scoop"

        ```powershell
        scoop install main/rust
        scoop bucket add java
        scoop install java/temurin-jdk
        ```

    === "Chocolatey"

        ```powershell
        choco install -Y temurin rust
        ```

<!--     Toolkits; e.g. Java and Rust     -->

{%
  include-markdown './includes/_toolkits.md'
  heading-offset=2
%}

??? bug "If the JDK is not on your `$PATH`"

    This may happen if you install the JDK manually.
    Confirm where it was installed; t’s likely to be (e.g.) `C:\Program Files\Java\jdk-21`.
    In an administrator console, run this:

    ```powershell
    [Environment]::SetEnvironmentVariable( \
      "Path", \
      [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) \
      + ";C:\Program Files\Java\jdk-21", \
      [EnvironmentVariableTarget]::Machine \
    )
    ```

### JavaScript ecosystem

Install Node.js:

```powershell
scoop bucket add main
scoop install nodejs
```

Finally, install [pnpm](https://pnpm.io/), a faster alternative to npm:

```powershell
iwr https://get.pnpm.io/install.ps1 -useb | iex
```

### Visual C++ Build Tools

**Note: This step is essential.**
Install the [Visual C++ Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/)
**This is not the same as the “redistributable” package.**
Install the package without optional packages (unless they’re wanted).

!!! bug "Troubleshooting: Building packages from source"

    Some packages do not publish wheels for Windows.
    Uv, as well as Pip and Poetry, will fall back to compiling on Windows
    if suitable wheels are not found.
    You may also need to install older versions of the Visual C++ Build Tools for this to work.
    Also take a look at
    [Christopher Golhlke’s wheel archive](https://www.lfd.uci.edu/~gohlke/pythonlibs/).
    It often has Windows wheels much earlier than the packages officially release them.

## Windows Linux Subsystem

Follow [Microsoft’s instructions](https://learn.microsoft.com/en-us/windows/wsl/install)
to install the WLS.
Then follow the [Linux setup guide](linux.md).

## Final steps

### Disable startup apps

Disable unnecessary startup apps, which are listed under _Settings ➤ Apps ➤ Startup_.
You should periodically review this list because apps love to add themselves.

\*[WLS]: Windows Linux Subsystem

---

_Credits: Cole Helsell drafted the original version of this guide with me._
