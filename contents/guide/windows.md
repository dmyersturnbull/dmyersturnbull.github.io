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

!!! danger

    Remember to save your encryption key securely!

Enable BitLocker disk encryption and restart again.

### Built-in apps

Purge Windows’s horrifically unnecessary built‐in apps.
In an unmistakably irresponsible choice, Windows comes with Candy Crush.
Err on the side of assuming they’re useless and shouldn’t be there.
[Kill it with fire](https://tvtropes.org/pmwiki/pmwiki.php/Main/KillItWithFire)
([1](https://www.wired.com/2013/10/why-kill-it-with-fire-is-a-terrible-terrible-idea/)).

### Game Bar

Run this to disable Game Bar:

```powershell
Get-AppxPackage Microsoft.XboxGamingOverlay | Remove-AppxPackage
Get-AppxProvisionedPackage -Online |`
    Where-Object {$_.PackageName -like "*XboxGamingOverlay*"} |`
    Remove-AppxProvisionedPackage -Online
```

### Optional Features

Install the Windows Developer Mode.
Go to the start menu and type _features_.
Navigate to
_Apps and Features ➤ Manage optional features ➤ add feature ➤ Windows Developer Mode ➤ install_.

Also enable OpenSSH, uninstall Notepad and Wordpad, and disable other unnecessary Optional Features
(most are unnecessary).
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
Otherwise, your system clock can drift seconds or even minutes after a few restarts.

### Power settings

Configure your Power Plan.

In some cases, you should disable scanning in a drive to avoid the performance drops.
Scanning can also cause errors because it opens file handles.

### Update settings

#### Configuring via _Settings_

First, review the settings under _Settings ➤ Windows Updates ➤ Advanced options_.
Set _Active hours_ and make sure _Get me up to date_ is unchecked.†

!!! tip
    Although you can throttle download speeds, that setting applies even when you explicitly download updates.

#### Making updates non-automatic

You may want to disable automatic updates to manage them yourself,
something Windows doesn’t normally allow.
An app I used and recommended called Win Update Stop is now paid-only.
The GitHub repo
[Aetherinox/pause-windows-updates](https://github.com/Aetherinox/pause-windows-updates)
has a pair of registry keys, one to pause and another to resume.
It worked flawlessly on my laptop, but I have only tested it on that machine.
Alternatively, you can search for
[other apps on GitHub](https://github.com/search?q=disable+windows+11+updates&type=repositories).

!!! warning

    Make sure that any app includes an on/off toggle or that it doesn’t prevent manual updates.
    Additionally, check that it can be fully uninstalled.

## Packages and package managers

### WinGet

Review the documentation for
[WinGet](https://learn.microsoft.com/en-us/windows/package-manager/).

### Powershell Core

```powershell
winget install --exact --id Microsoft.PowerShell
```

Set powershell-core as your default shell in Terminal.
Check the PowerShell version using: `Get-Host | Select-Object Version`.
Make sure it’s 7+.

### Chocolatey, Scoop, and Snappy

Install three other package managers:
[Chocolatey](https://chocolatey.org/),
[Scoop](https://scoop.sh/),
and [SnapPy](https://snappy.computop.org/installing.html#windows).
After installing Scoop, run
```powershell
scoop bucket add main
scoop install main/scoop-search
```

!!! tip "Which should I use?"

    Apps may be available via multiple package managers.

    Chocolatey runs complex, package-provided configuration as root.
    This allows apps to be integrated into your system to provide
    environment variables, file associations, context menu items, and services.

    I recommend using WinGet by default,
    Scoop for development packages (e.g. Node),
    Chocolatey when required,
    and Snappy for packages not available elsewhere.

### PowerShell Gallery

Also see the
[PowerShell Gallery](https://www.powershellgallery.com/).

You can access it with the built-in
[PSResourceGet](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.psresourceget)
module.
Note that PowerShellGet is deprecated.

### Install packages

Install Git, the GH CLI, and GnuPG:

```powershell
winget install --exact --id Git.Git
winget install --exact --id GitHub.cli
winget install --exact --id GnuPG.GnuPG
```

## Git, SSH, & GPG

**Follow the [Git, SSH, & GPG guide](git-ssh-and-gpg.md)**.
The SSH key and config instructions work in PowerShell because OpenSSH is installed.
Note that GitHub CLI was installed via Chocolatey (in the steps above).

## Long paths

Enable system support for paths with ≥ 260 characters by executing this command:

```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
    -Name LongPathsEnabled `
    -Type DWord `
    -Value 1
```

!!! info "Equivalent registry changes"

    ```reg
    [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem]
    "LongPathsEnabled"=hex(1)
    ```

Next, enable support in Git by running

```powershell
git config --global core.longpaths true
```

!!! bug "This doesn’t guarantee application support"

    Some apps will need to be configured (like Git was), and others simply lack support.

## Programming languages and frameworks

### Build tools

Install the
[Build Tools for Visual Studio](https://visualstudio.microsoft.com/visual-cpp-build-tools/),
**This is not the same as the “redistributable” package.**
You can use WinGet:

```powershell
winget install --exact --id Microsoft.VisualStudio.BuildTools
```

Also install CMake and MSYS2:

```powershell
winget install --exact --id Kitware.CMake
winget install --exact --id MSYS2.MSYS2
```

**Before installing any package,**
check for and uninstall any existing copy under _Add or Remove Programs_.
For example, you’ll want to uninstall the copy of Java that ships with Windows.

!!! tip "Pro-tip: Rust, Python, and Java"

    Install Rust:

    ```powershell
    scoop install main/rust
    cargo install cargo-update
    ```

    Installl Java UV (for Python):

    ```powershell
    scoop install main/uv
    scoop bucket add java
    scoop install java/temurin-jdk
    ```

{%
  include-markdown './includes/_toolkits.md'
  heading-offset=2
%}

### JavaScript

!!! note "Note: NVM"

    I’ve assumed you’ll stick with the latest Node.
    If you’ll need to switch Node versions (not just in containers),
    see [NVM](https://github.com/nvm-sh/nvm)
    or [NVM-Windows](https://github.com/coreybutler/nvm-windows).

Install Node and [pnpm](https://pnpm.io/) with Scoop:

```powershell
scoop bucket add main
scoop install nodejs pnpm
```

## Windows Linux Subsystem

Follow [Microsoft’s instructions](https://learn.microsoft.com/en-us/windows/wsl/install)
to install the Windows Subsystem for Linux (WSL).
Then follow the [Linux setup guide](linux.md).

## Final steps

### Install system utils

First, install
[Sysinternals](https://learn.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite).

Install the command-line utils FZF and Bat:

```powershell
winget install --exacte --id junegunn.fzf
winget install --exact --id sharkdp.bat
```

Finally, install
[PowerToys](https://learn.microsoft.com/en-us/windows/powertoys/),
[TreeSize free](https://www.jam-software.com/treesize),
[UniGetUI](https://github.com/marticliment/UniGetUI),
[7-zip with ZSTD support](https://github.com/mcmilk/7-Zip-zstd),
and, of course,
[Notepad++](https://notepad-plus-plus.org/).
Optionally include
[Files](https://files.community/),
[Pandoc](https://pandoc.org/),
[ImageMagick](https://imagemagick.org),
and [VLC](https://www.videolan.org/vlc/):

```powershell
winget install --exact --id Microsoft.PowerToys
winget install --exact --id JAMSoftware.TreeSize.Free
winget install --exact --id MartiCliment.UniGetUI
winget install --exact --id mcmilk.7zip-zstd
winget install --exact --id Notepad++.Notepad++
winget install --exact --id FilesCommunity.Files
winget install --exact --id JohnMacFarlane.Pandoc
winget install --exact --id ImageMagick.ImageMagick
winget install --exact --id VideoLAN.VLC
```

### Disable startup apps

Disable unnecessary startup apps, which are listed under _Settings ➤ Apps ➤ Startup_.
You should periodically review this list because apps love to add themselves.

### Organize the applications menu

Organize these two locations:

- `%ProgramData%\Microsoft\Windows\Start Menu\Programs`
- `%AppData%\Microsoft\Windows\Start Menu\Programs`

Some apps end up in the parent directories (i.e. in `Start Menu\`);
you can move them.

### Organize the context menus

TODO

---

_Credits: Cole Helsell drafted the original version of this guide with me._
