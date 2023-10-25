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

#### Use Btrfs.
Btrfs is a copy-on-write option and is now much more robust than EXT4.

#### Use a swap paritition the same size as your RAM.

There's an adage that it's important for emergency memory – in case your main memory runs out.
Meanwhile, mavericks insist on skipping it altogether,
pointing out that using it for emergency memory would render a system excessively slow.
Linux uses swap space as a _complement_ to memory by swapping out infrequently used pages.
You should definitely use it, but it probably doesn't need to fit more than your memory.

#### For single-user systems, skip `/home` in favor of `/files`.

`/home` will probably fill with miscellaneous configuration
and even temp data that doesn't need to be backed up.
It's probably even best to discard such files when upgrading or installing a new distro.
So, leave `/home` in the root partition and use another mount point like `/data` or `/files` instead.

#### Skip the `/boot` partition.

It's not needed on a modern UEFI system.

#### For workstations, consider a separate `/tmp`.

Things like an inefficient SQL query can quickly take hundreds of gigabytes in `/tmp`.
If `/tmp` is in your root partition, this can brick your system,
and you might have to boot to a flash drive to clean up the system.
If `/tmp` is a separate partition, filling it up won't leave your system unbootable.
Of course, consider the tradeoff.

??? example "Example scheme 1 – small workstation"

    | mount point | size (GB) | filesystem | purpose        |
    |-------------|-----------|------------|----------------|
    | (efi)       |    0.5    | FAT32      |                |
    | (swap)      |   64      | swap       |                |
    | `/tmp`      |  256      | btrfs      |                |
    | `/`         |  512      | btrfs      |                |
    | `/data`     | 1168      | btrfs      | Data and files |

??? example "Example scheme 2 – multi-user workstation"

    Context: nvme0 and nvme1 are ultra-fast drives (CPU chipset and 4 PCIe lanes, respectively), while nvme2 and nvme3 are slower.

    | drive(s) | mount point | size (GB) | filesystem | purpose              |
    |----------|-------------|-----------|------------|----------------------|
    | nvme0    | (efi)       |    0.5    | FAT32      |                      |
    | nvme0    | (swap)      |  128      | swap       |                      |
    | nvme0    | `/tmp`      |  512      | btrfs      |                      |
    | nvme0    | `/`         | 1408      | btrfs      |                      |
    | nvme1    | `/scratch`  | 2048      | btrfs      | Ultra-fast scratch   |
    | nvme2    | `/lake`     | 2048      | btrfs      | Fast shared data     |
    | nvme3    | `/home`     | 2048      | btrfs      | User files           |
    | sda,sdb  | `/stock`    | 8192      | btrfs      | Frozen data (raid 0) |
    | sdc      | `/bakroot`  | 2048      | btrfs      | `dd` of `/`          |
    | sdd      | `/baklake`  | 2048      | btrfs      | `dd` of `/lake`      |
    | sde      | `/bakhome`  | 2048      | btrfs      | `dd` of `/home`      |

## Update & install packages

Open a terminal and enter the following commands to install the necessary packages:

=== "Ubuntu"

    First, enable the Universe repository:

	```bash
	sudo add-apt-repository universe -y
	```

    ```bash
    sudo apt update && upgrade
    sudo apt install -y git vim curl wget xz-utils brotli lzma zstd exa
	sudo apt install libncurses-dev
	sudo apt install -y build-essential cmake
    sudo apt install -y zsh
    ```

=== "Fedora"

    ```bash
    sudo dnf update && upgrade
    sudo dnf install -y git vim curl wget xz-utils brotli lzma zstd exa
	sudo dnf install -y ncurses-devel
	sudo dnf install -y make automake gcc gcc-c++ kernel-devel cmake
    sudo dnf install -y zsh
    ```

Install the GitHub CLI per the
[official GH Linux install instructions](https://github.com/cli/cli/blob/trunk/docs/install_linux.md).

## Drivers

=== "NVIDIA"

    Install [NVIDIA drivers](https://www.nvidia.com/download/index.aspx).
	Follow the instructions, which will include UEFI configuration.
	To test, run `nvidia-smi` on reboot.

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
