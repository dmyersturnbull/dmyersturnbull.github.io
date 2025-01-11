# Linux setup

<!--
SPDX-FileCopyrightText: Copyright 2017-2024, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

A setup guide for programmers, etc., on Linux and the Windows Linux Subsystem.
Alternatives for Ubuntu/Debian-like and Fedora/RedHat-like are shown.

!!! related

    [macOS setup guide](macos.md) and
    [Windows setup guide](windows.md)

## Start installation

Follow the instructions that show up to install.
In Ubuntu, select “Default installation”
and check “Install third-party software for graphics and Wi-Fi hardware”
and “Download and install support for additional media formats”.

If you need encryption, TPM-backed FDE is a potential option.
Support in Ubuntu and Fedora is experimental (as of October 2023).
I have not tested it.

??? bug "UEFI troubleshooting"

    If you get an error installing GRUB, try these steps:

    - Disable Fast Boot.
    - Disable Secure Boot. Also, check to see if CSM/Legacy options is disabled.
    - Manually install the bootloader (not recommended).
    - Read about [Linux and UEFI](https://www.rodsbooks.com/linux-uefi/) for more troubleshooting.

## Choose a partition scheme

### Use Btrfs.

Btrfs is a copy-on-write option and is now much more robust than ext4.
See the [btrfs documentation](https://btrfs.readthedocs.io/en/latest).

### Use a swap partition the same size as your RAM.

There’s an adage that it’s important for emergency memory – in case your main memory runs out.
Meanwhile, mavericks insist on skipping it altogether,
pointing out that using it for emergency memory would render a system excessively slow.
Linux uses swap space as a _complement_ to memory by swapping out infrequently used pages.
You should definitely use it, but it probably doesn’t need to fit more than your memory.

### For single-user systems, skip `/home` in favor of `/files`.

`/home` will probably fill with miscellaneous configuration
and even temp data that doesn’t need to be backed up.
It’s probably even best to discard such files when upgrading or installing a new distro.
So, leave `/home` in the root partition and use another mount point like `/data` or `/files` instead.

### Skip the `/boot` partition.

It’s not needed on a modern UEFI system.

### For workstations, consider separate `/tmp` and `/var/tmp`.

Things like an inefficient SQL query can quickly take hundreds of gigabytes in `/tmp`.
If `/tmp` is in your root partition, this can brick your system,
and you might have to boot to a flash drive to clean up the system.
If `/tmp` is a separate partition, filling it up won’t leave your system unbootable.
Of course, consider the tradeoff.
The same goes for `/var/tmp` (more or less).
If mounted as separate partitions, mount with `noexec`.

??? example "Example 1 – single 4 TB NVMe SSD"

    | drive(s) | mount point | size (GB) | format | purpose               |
    |----------|-------------|-----------|--------|-----------------------|
    | nvme0    | (efi)       | 2         | FAT32  |                       |
    | nvme0    | (swap)      | 54        | swap   |                       |
    | nvme0    | `/`         | 256       | btrfs  |                       |
    | nvme0    | `/tmp`      | 128       | btrfs  |                       |
    | nvme0    | `/var/tmp`  | 256       | btrfs  |                       |
    | nvme0    | `/data`     | 3 400     | btrfs  | Data and documents    |

??? example "Example 2 – two 4 TB NVMe SSDs"

    | drive(s) | mount point | size (GB) | format | purpose            |
    |----------|-------------|-----------|--------|--------------------|
    | nvme0    | (efi)       |     2     | FAT32  |                    |
    | nvme0    | (swap)      |    54     | swap   |                    |
    | nvme0    | `/`         |   256     | btrfs  |                    |
    | nvme0    | `/tmp`      |   128     | btrfs  |                    |
    | nvme0    | `/var/tmp`  |   256     | btrfs  |                    |
    | nvme0    | `/scratch`  | 3 400     | btrfs  | Working data       |
    | nvme1    | `/data`     | 4 096     | btrfs  | Data and document  |
    | sda1     | `/bak/root` |   256     | btrfs  | Image of root      |
    | sda2     | `/bak/data` | 5 888     | btrfs  | Backups of `/data` |

??? example "Example 3 – three 2 TB NVMe and two 4 TB SATA SSDs"

    | drive(s) | mount point  | size (GB) | format | purpose               |
    |----------|--------------|-----------|--------|-----------------------|
    | nvme0    | (efi)        |     1     | FAT32  |                       |
    | nvme0    | (swap)       |   128     | swap   |                       |
    | nvme0    | `/`          | 1 408     | btrfs  |                       |
    | nvme0    | `/tmp`       |   256     | btrfs  |                       |
    | nvme0    | `/var/tmp`   |   256     | btrfs  |                       |
    | nvme1    | `/scratch`   | 2 048     | btrfs  | Ultra-fast scratch    |
    | nvme2    | `/home`      | 2 048     | btrfs  | Fast user data        |
    | sda      | `/lake`      | 4 096     | btrfs  | Frozen data (raid 0)  |
    | sdb      | `/lake`      | 4 096     | btrfs  | Frozen data (raid 0)  |
    | sdc1     | `/bak/root`  | 1 408     | btrfs  | Image of root         |
    | sdc2     | `/bak/lake`  | 2 048     | btrfs  | Backups of `/home`    |
    | sdc3     | `/bak/home`  | 2 048     | btrfs  | Backups of `/lake`    |

### Enable kernel modules

First, update and reboot:

=== "Ubuntu"

    ```bash
    sudo apt update && reboot
    ```

=== "Fedora"

    ```bash
    sudo dnf update && reboot
    ```

Then, run

```bash
sudo modprobe sha256
```

## Set mount options

- Add `noatime` everywhere.
  Access timestamps (atime) are written using the default option, `relatime`.
  This makes a lot of otherwise-unnecessary writes, degrading performance.
- Add `noacl` everywhere.
  There’s probably no performance gain to disable ACL, but you almost definitely don’t need it.
- Add `noexec`, `nodev`, and `nosuid` to `/tmp` and `/var/tmp` (if they exist).

#### Consider compression.

btrfs can compress data at rest and in transit.
Whether to use lzo, zstd, or no compression depends primarily on the (uncompressed) throughput:
Use heavier compression to compensate for slow IO, and use lighter compression for fast IO.
Use no compression if the CPU is already the bottleneck.
See [benchmarks for btrfs compression](https://gist.github.com/braindevices/fde49c6a8f6b9aaf563fb977562aafec).
Here are my recommendations:

- `compression=off` for NVMe SSDs
- `compression=lzo` for SATA-connected SSDs
- `compression=zstd:3` for SATA-connected HDDs and USB-connected SSDs or HHDs

!!! bug "Compression failures"

    Sometimes filesystems cannot be mounted with `compress`.
    There are probably many likely reasons.

!!! warning

    Make sure to follow the steps below to verify that your `fstab` is valid and usable.

### Edit `fstab`

Following these rules, the `fstab` for “Example scheme 1 – single-user workstation” might look like this:

```fstab
# filesystem     mount      type   options                            d p
.../by-uuid/...  none       swap   sw                                 0 1
.../by-uuid/...  /boot/efi  vfat   defaults                           0 1
.../by-uuid/...  /tmp       btrfs  noatime,noacl,noexec,nodev,nosuid  0 1
.../by-uuid/...  /var/tmp   btrfs  noatime,noacl,noexec,nodev,nosuid  0 1
.../by-uuid/...  /          btrfs  noatime,noacl                      0 1
.../by-uuid/...  /data      btrfs  noatime,noacl,compress=lzo         0 1
.../by-uuid/...  /bak       btrfs  noatime,noacl,compress=zstd:3      0 1
```

Before rebooting, verify that your changes are probably ok by running

```bash
mount --fake --all --verbose
```

and

```bash
sudo systemctl daemon-reload
sudo findmnt --fstab --verify --verbose
```

Then reboot and see the results by running

```bash
cat /etc/mtab
```

## Post-installation

### Install packages

Open a terminal and enter the following commands to install the necessary packages:

=== "Ubuntu"

    ```bash
    sudo add-apt-repository universe -y
    sudo apt install -y git vim curl wget xz-utils brotli lzma zstd iotop
    sudo apt install -y eza  # (1)!
    sudo apt install -y libncurses-dev
    sudo apt install -y build-essential cmake
    sudo apt install -y zsh
    sudo apt install -y gnome-tweaks
    sudo apt install asdf  # (2)!
    sudo apt install -y flatpak  # (3)!
    ```

    1. `exa` is deprecated; use [`eza`](https://github.com/eza-community/eza) instead.
    2. [asdf](https://asdf-vm.com/) is a version manager for tools.
    3. [Flatpak](https://flatpak.org/) is a distro-independent package manager for Linux.

=== "Fedora"

    ```bash
    sudo dnf update && sudo dnf -y upgrade
    sudo dnf install -y git vim curl wget xz-utils brotli lzma zstd iotop
    sudo dnf install -y eza  # (1)!
    sudo dnf install -y ncurses-devel
    sudo dnf install -y make automake gcc gcc-c++ kernel-devel cmake
    sudo dnf install -y zsh
    sudo dnf install -y gnome-tweaks
    sudo dnf install -y asdf  # (2)!
    sudo dnf install -y flatpak  # (3)!
    ```

    1. `exa` is deprecated; use [`eza`](https://github.com/eza-community/eza) instead.
    2. [asdf](https://asdf-vm.com/) is a version manager for tools.
    3. [Flatpak](https://flatpak.org/) is a distro-independent package manager for Linux.

Install the GitHub CLI per the
[official GH Linux install instructions](https://github.com/cli/cli/blob/trunk/docs/install_linux.md).
After following the instructions, run `gh auth login`.

### Configure firewall

=== "Ubuntu"

    ```bash
    sudo ufw enable
    ```

=== "Fedora"

    Fedora should come with `firewalld` installed and enabled by default.

### Enable SSH logins

Install ssh to allow for remote logins.

```bash
sudo apt -y update
sudo apt -y install openssh-server
sudo ufw allow 22
```

### Sudoers

The easiest way is to run

```bash
su #(1)!
usermod -aG sudo $USER
```

1. This will require you to enter the root password.

See this
[sudoers guide](https://www.cyberciti.biz/faq/how-to-sudo-without-password-on-centos-linux/)
for more info.

### Configure your shell

**Follow: _[Shell setup :fontawesome-solid-terminal:](nix-shells.md)_.**

### Git, SSH, and GPG

**Follow: _[Shell setup :fontawesome-solid-shield-halved:](git-ssh-and-gpg.md)_.**

<!-- Toolkits; e.g. Java and Rust -->

{%
  include-markdown './files/_toolkits.md'
  heading-offset=2
%}

### Generate a certificate (if needed)

If you need a certificate, set a static IP address and generate a certificate with
[certbot](https://certbot.eff.org/). Choose “None of the above” for Software.
Then follow the instructions exactly, including the “Automating renewal” section.
This may not work through some company and university firewalls.

## Cosmetics and UI

### Eza icons and Nerd fonts

Download one or more [Nerd fonts](https://www.nerdfonts.com/font-downloads).
Then run

```bash
gh release download --dir nerd/ --repo ryanoasis/nerd-fonts/ -p '*.zip'
for f in 'nerd/*.zip'; do sudo unzip '$f' -d /usr/local/share/fonts; done
fc-cache
```

Set your terminal font to your preferred Nerd font.
(I personally recommend Source Code Pro, Noto, JetBrains Mono, Ubuntu Mono, or IBM Plex Mono.)
In [Tilix](https://gnunn1.github.io/), this is a per-profile setting called “Custom font”.
Now you can run

```Bash
eza --icons
```

!!! bug "Tilix warning"

    I have repeatedly encountered nondescript Tilix warnings on fresh OS installs.
    So far, I have not noticed any resulting issues.

### Gnome extensions and date/time

In GNOME’s settings, set the time format to 24-hour and make sure _Automatic Data and Time_ is selected.
Also install extensions:

=== "Ubuntu"

    ```bash
    sudo apt install gnome-browser-connector
    ```

=== "Fedora"

    ```bash
    sudo dnf install gnome-browser-connector
    ```

Then open https://extensions.gnome.org/ and install the browser extension.
I recommend installing:

- **Force Quit**
- **Panel Date Format**;
  After installing, run

  ```bash
  dconf write \
    /org/gnome/shell/extensions/panel-date-format/format \
    "'%Y-%m-%d %H:%M'"
  ```

### Nautilus favorites

To remove the favorites for Videos, Music, etc. that Nautilus forces on you, run this script:

???+ info "Script to remove built-in bookmarks"

    ```bash
    printf '%s\n' "
    # This file was created manually.

    # Keep these:
    XDG_DESKTOP_DIR="$HOME/Desktop"
    XDG_DOWNLOAD_DIR="$HOME/Downloads"

    # Exclude these:
    #XDG_DOCUMENTS_DIR="$HOME/Documents"
    #XDG_TEMPLATES_DIR="$HOME/Templates"
    #XDG_PUBLICSHARE_DIR="$HOME/Public"
    #XDG_MUSIC_DIR="$HOME/Music"
    #XDG_PICTURES_DIR="$HOME/Pictures"
    #XDG_VIDEOS_DIR="$HOME/Videos"
    " > ~/.config/user-dirs.dirs

    # Create a user-dirs.conf file to prevent automatic updates
    printf '%s\n' "
    # We created ~/.config/user-dirs.dirs manually
    # Prevent xdg-user-dirs-update from overwriting it
    enabled=False
    " > ~/.config/user-dirs.conf
    ```

??? bug "Workaround if this doesn’t work."

    This **might** work instead.

    ```bash
    printf '%s\n' "
    # This file was created manually.

    # Keep these:
    XDG_DESKTOP_DIR="$HOME/Desktop"
    XDG_DOWNLOAD_DIR="$HOME/Downloads"

    # Exclude these:
    #XDG_DOCUMENTS_DIR="$HOME/.junk/Documents"
    #XDG_TEMPLATES_DIR="$HOME/.junk/Templates"
    #XDG_PUBLICSHARE_DIR="$HOME/.junk/Public"
    #XDG_MUSIC_DIR="$HOME/.junk/Music"
    #XDG_PICTURES_DIR="$HOME/.junk/Pictures"
    #XDG_VIDEOS_DIR="$HOME/.junk/Videos"
    " > ~/.config/user-dirs.dirs

    # Create a user-dirs.conf file to prevent automatic updates
    printf '
    # We created ~/.config/user-dirs.dirs manually
    # Prevent xdg-user-dirs-update from overwriting it
    enabled=False
    ' > ~/.config/user-dirs.conf
    ```

For convenience, use
[`add-bookmarks.sh`](files/add-bookmarks.sh)
to add bookmarks.
Example: `~/bin/add-bookmarks.sh data=/data/ docs=/docs/`

After running it, restart Nautilus to apply the settings by running
`nautilus -q`.

_[LTS]: Long-Term Support
_[UEFI]: Unified Extensible Firmware Interface \*[JDK]: Java Development Kit
