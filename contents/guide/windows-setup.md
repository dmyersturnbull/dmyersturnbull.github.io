# Windows setup

A companion to a similar [guide for macOS](https://dmyersturnbull.github.io/#macos-setup).
Note that this one is a bit different.
There are similar guides across the web, but this one contains workarounds for various issues.
Contents:

- Setup for hardware
- Features & configuration
- Fixing power settings issues
- Installing Chocolatey and useful apps
- Final security steps

## Basic hardening

Enable BitLocker.

## Intel + NVIDIA

This details setup for specific hardware that I have used on 6 PC/workstation builds.

- Download at the [NVIDIA driver page](https://www.geforce.com/drivers).
- Download and install the [Intel Extreme Tuning Utility](https://downloadcenter.intel.com/download/24075/Intel-Extreme-Tuning-Utility-Intel-XTU-).
  Open it and view the system info and temperatures.
- Overclock:
  Restart your computer, enter the BIOS, and open the overclocking settings.
  In general, you’ll want to overclock the memory to the XMP profile. For our typical motherboards
  and RAM, this meant a change from 2400 MHz to 3600 MHz. This was crucial for running some custom
  hardware. Overclock the CPU frequency and cache frequency a little bit at a time. After each
  marginal change, run the Intel tuning utility: Run multiple "benchmarks" and watch the
  temperature closely.
- Install the [CUDA toolkit](https://developer.nvidia.com/cuda-downloads?target_os=Windows&target_arch=x86_64&target_version=10&target_type=exelocal).

## Developer mode & config

First, update Windows to the newest feature release.
Then purge Windows’s horrifically unnecessary built‐in apps.
In an unmistakably irresponsible choice, Windows comes with Candy Crush.
Really, err on the side of assuming they’re useless and shouldn’t be there.
[Kill it with fire](https://tvtropes.org/pmwiki/pmwiki.php/Main/KillItWithFire)
([1](https://www.wired.com/2013/10/why-kill-it-with-fire-is-a-terrible-terrible-idea/)).

Then install the Windows Developer Mode.
Go to the start menu and type _features_. Navigate to
`Apps and Features → Manage optional features → add feature → Windows Developer Mode → install`.
Also disable unnecessary features – from what I found, almost all can be uninstalled.
Finally, install
[Ubuntu on a Linux subsystem](https://ubuntu.com/tutorials/install-ubuntu-on-wsl2-on-windows-11-with-gui-support#1-overview).

## Power & update settings

In the power settings, disable hibernation, automatic sleep mode, and USB connection suspending.
While these can save power, chances are too high that they will interfere with a long‐running job or backup.

In some cases, you will want to disable scanning in a drive. This can drop performance.
It can even cause issues because it can open file handles, temporarily preventing writes;
this case it to interfered with data collection on our custom hardware.

_Stop automatic updates by installing
[Win Update Stop](https://www.novirusthanks.org/products/win-update-stop)_.
Although I understand Microsoft’s rationale, it’s incredibly annoying that Windows forces a restart with short notice.
This is an enormous problem on a workstation that could be running an important job while you’re away ---
and you don’t respond in time to postpone the update.
Plus, eventually you can’t postpone further.
To update Windows, first open Win Update Stop and enable updates.
Disable them again when you’re done.

## Chocolatey

Install [Chocolatey](https://chocolatey.org/), a fantastic package manager.
Run `choco upgrade all`.
Install with `choco install`: `powershell-core`,
`choco install poshgit gh libressl openssh gnupg notepadplusplus ffmpeg 7zip vlc pandoc treesizefree rsync nodejs -Y`.
A few are not necessary.
You can install user applications via Chocolatey, such as VLC, Slack, Chrome, and Firefox.
Update them all with `choco upgrade all`.

### Outdated software

Install the most recent version of the [JDK](https://www.oracle.com/java/technologies/downloads/).
**Download JDK 20+ from Oracle. Do not use Java 8, java.com, or OpenJDK.**

Set powershell-core as your default shell.
Check the PowerShell version using: `Get-Host | Select-Object Version`. Make sure it’s 7+.

!!! note
    Although I’m used to shell scripting Linux, Powershell is actually quite good.
    Instead of needing to parse text from stdout when piping between commands, the data structures
    passed around in PowerShell are _tables_. It’s a much better approach, and I recommend
    [learning it](https://devblogs.microsoft.com/powershell/getting-started-with-powershell-core-on-windows-mac-and-linux/).
    You can install it in Linux and macOS.

## SSH & GPG

**Follow the [guide for Linux](https://dmyersturnbull.github.io/#-linux-setup)**,
which shows how to set up SSH and GPG keys, certificates, and aliases,
which should work for the Linux subsystem. The SSH key and config instructions should also work in
PowerShell because OpenSSH is installed. The GPG key instructions may need tweaking.
