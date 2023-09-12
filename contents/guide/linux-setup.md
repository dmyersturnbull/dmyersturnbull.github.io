# Linux setup

A setup guide for programmers, etc., on Linux and the Windows Linux Subsystem.
Alternatives for Ubuntu/Debian-like and Fedora/RedHat-like are shown.

!!! note "See also"
    [macOS setup guide](macos-setup.md) and
    [Windows setup guide](windows-setup.md)

## Install

Install the most recent version or most recent LTS version.

Change the UEFI settings so that you boot from the drive.
Follow the instructions that show up to install.

??? bug "UEFI bug"

    I faced this issue when installing the Linux OS onto Samsung SSD drives:
    > Unable to install GRUB

    Try the following things in the UEFI interface to resolve this issue:

    - Make sure Fast Boot is Disabled.
    - Make sure Secure Boot is Disabled. Also, check to see if CSM/Legacy options is disabled.
    - Manually install the bootloader (not recommended).
    - Read about [Linux and UEFI](https://www.rodsbooks.com/linux-uefi/) for troubleshooting.

### Choose a partition scheme

I **strongly** recommend using Btrfs.
Btrfs is a copy-on-write option and is much more robust than EXT4 at this point.

For multi-user systems, consider keeping `/home` separate.
For single-user systems, also consider other mount points (such as `/files` or `/data`)

??? example "Example scheme 1 – small workstation"

    | mount point | size (GB) | filesystem | purpose        |
    |-------------|-----------|------------|----------------|
    | (efi)       | 0.5       | FAT32      |                |
    | (swap)      | 64        | swap       |                |
    | `/tmp`      | 96        | btrfs      |                |
    | `/`         | 160       | btrfs      |                |
    | `/data`     | 624       | btrfs      | Large datasets |

??? example "Example scheme 2 – personal laptop"

    | mount point | size (GB) | filesystem | purpose                       |
    |-------------|-----------|------------|-------------------------------|
    | (efi)       | 0.5       | FAT32      |                               |
    | (swap)      | 64        | swap       |                               |
    | `/`         | 200       | btrfs      |                               |
    | `/files`    | 380       | btrfs      | Data backed up with snapshots |
    | `/movies`   | 380       | btrfs      | Data backed up in-place       |

??? example "Example scheme – multi-user workstation"

      | disk | mount point  | size (GB) | filesystem | purpose                   |
      |------|--------------|-----------|------------|---------------------------|
      | 1    | (efi)        | 1         | FAT32      |                           |
      | 1    | (swap)       | 64        | swap       |                           |
      | 1    | `/tmp`       | 256       | btrfs      |                           |
      | 1    | `/`          | 703       | btrfs      |                           |
      | 1    | `/blaze`     | 1024      | btrfs      | Ultra-fast scratch        |
      | 2    | `/home`      | 1024      | btrfs      | User files                |
      | 2    | `/usr/share` | 1024      | btrfs      | Shared processed data     |
      | 3–4  | `/lake`      | 4096      | btrfs      | Main shared data (raid 0) |
      | 5–6  | `/scratch`   | 4096      | btrfs      | Replaceable data (raid 0) |

## Update & install packages

Open a terminal and enter the following commands to install the necessary packages:

=== "Ubuntu"

    ```bash
    sudo apt update && upgrade
    sudo apt install git vim wget xz-utils brotli lzma zstd exa
    sudo apt install zsh
    ```

=== "Fedora"

    ```bash
    sudo dnf update && upgrade
    sudo dnf install git vim wget xz-utils brotli lzma zstd exa
    sudo dnf install zsh
    ```

Install the GitHub CLI per the
[official GH Linux install instructions](https://github.com/cli/cli/blob/trunk/docs/install_linux.md).

## Set up firewall

=== "Ubuntu"

    ```bash
    sudo ufw enable
    ```

=== "Fedora"

    Fedora should come with `firewalld` installed and enabled by default.

{!guide/_common-setup.md!}

!!! note "Thanks"
    Thank you to Cole Helsell for drafting this guide with me.
