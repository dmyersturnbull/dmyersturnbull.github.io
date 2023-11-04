# Linux setup

A setup guide for programmers, etc., on Linux and the Windows Linux Subsystem.
Alternatives for Ubuntu/Debian-like and Fedora/RedHat-like are shown.

!!! note "See also"
    [macOS setup guide](macos-setup.md) and
    [Windows setup guide](windows-setup.md)

## Install

Follow the instructions that show up to install.
In Ubuntu, select "Default installation" and check "Install third-party software for graphics and Wi-Fi hardware" and "Download and install support for additional media formats".

If you need encryption, TPM-backed FDE is a potential option.
Support in Ubuntu and Fedora is experimental (as of October 2023).
I have not tested it.

??? bug "UEFI troubleshooting"

	If you get an error installing GRUB, try these steps:

    - Disable Fast Boot.
    - Disable Secure Boot. Also, check to see if CSM/Legacy options is disabled.
    - Manually install the bootloader (not recommended).
    - Read about [Linux and UEFI](https://www.rodsbooks.com/linux-uefi/) for more troubleshooting.

### Choose a partition scheme

#### Use Btrfs.
Btrfs is a copy-on-write option and is now much more robust than ext4.
See the [btrfs documentation](https://btrfs.readthedocs.io/en/latest).

#### Use a swap partition the same size as your RAM.

There’s an adage that it’s important for emergency memory – in case your main memory runs out.
Meanwhile, mavericks insist on skipping it altogether,
pointing out that using it for emergency memory would render a system excessively slow.
Linux uses swap space as a _complement_ to memory by swapping out infrequently used pages.
You should definitely use it, but it probably doesn’t need to fit more than your memory.

#### For single-user systems, skip `/home` in favor of `/files`.

`/home` will probably fill with miscellaneous configuration
and even temp data that doesn’t need to be backed up.
It’s probably even best to discard such files when upgrading or installing a new distro.
So, leave `/home` in the root partition and use another mount point like `/data` or `/files` instead.

#### Skip the `/boot` partition.

It’s not needed on a modern UEFI system.

#### For workstations, consider separate `/tmp` and `/var/tmp`.

Things like an inefficient SQL query can quickly take hundreds of gigabytes in `/tmp`.
If `/tmp` is in your root partition, this can brick your system,
and you might have to boot to a flash drive to clean up the system.
If `/tmp` is a separate partition, filling it up won’t leave your system unbootable.
Of course, consider the tradeoff.
The same goes for `/var/tmp` (more or less).
If mounted as separate partitions, mount with `noexec`.

??? example "Example scheme 1 – single-user workstation"

    | drive(s) | mount point | size (GB) | filesystem | purpose               |
    | nvme0    |-------------|-----------|------------|-----------------------|
    | nvme0    | (efi)       |    1      | FAT32      |                       |
    | nvme0    | (swap)      |   64      | swap       |                       |
    | nvme0    | `/`         |  256      | btrfs      |                       |
    | nvme0    | `/tmp`      |  128      | btrfs      |                       |
    | nvme0    | `/var/tmp`  |  256      | btrfs      |                       |
    | nvme0    | `/data`     | 1308      | btrfs      | Working data          |
    | nvme1    | `/docs`     | 1024      | btrfs      | Documents             |
    | sda      | `/bak`      | 4096      | btrfs      | External backup (HDD) |

??? example "Example scheme 2 – multi-user server"

    Context: nvme0 and nvme1 are ultra-fast drives (CPU chipset and 4 PCIe lanes, respectively), while nvme2 and nvme3 are slower. `sda` and `sdb` are SATA SSDs, and `sdc` is a spinning disk.

    | drive(s) | mount point | size (GB) | filesystem | purpose                |
    |----------|-------------|-----------|------------|------------------------|
    | nvme0    | (efi)       |    1      | FAT32      |                        |
    | nvme0    | (swap)      |  128      | swap       |                        |
    | nvme0    | `/`         | 1408      | btrfs      |                        |
    | nvme0    | `/tmp`      |  256      | btrfs      |                        |
    | nvme0    | `/var/tmp`  |  256      | btrfs      | Only system temp files |
    | nvme1    | `/scratch`  | 2048      | btrfs      | Ultra-fast scratch     |
    | nvme2    | `/lake`     | 2048      | btrfs      | Fast shared data       |
    | nvme3    | `/home`     | 2048      | btrfs      | User files             |
    | sda,sdb  | `/stock`    | 8192      | btrfs      | Frozen data (raid 0)   |
    | sdc1     | `/bakroot`  | 2048      | btrfs      | `dd` of `/`            |
    | sdc2     | `/baklake`  | 2048      | btrfs      | `dd` of `/lake`        |
    | sdc3     | `/bakhome`  | 2048      | btrfs      | `dd` of `/home`        |

## Update and reboot

=== "Ubuntu"

    ```bash
    sudo apt update && reboot
	```

=== "Fedora"

    ```bash
    sudo dnf update && reboot
	```

## Enable kernel modules

Run

```bash
sudo modprobe sha256
```

## Set mount options

- Add `noatime` everywhere.
  Access timestamps (atime) are written using the default option, `relatime`.
  This makes a lot of otherwise-unnecessary writes, degrading performance.
- Add `noacl` everywhere.
  There’s probably no performance gain to disable ACL, but you almost definitely don’t need it.
-  Add `noexec`, `nodev`, and `nosuid` to `/tmp` and `/var/tmp` (if they exist).

### Consider compression.

btrfs can compress data at rest and in transit.
Whether to use lzo, zstd, or no compression depends primarily on the (uncompressed) throughput:
Use heavier compression to compensate for slow IO, and use lighter compression for fast IO. Use no compression if the CPU is already the bottleneck.
See [benchmarks for btrfs compression](https://gist.github.com/braindevices/fde49c6a8f6b9aaf563fb977562aafec).
Here are my recommendations:

- `compression=off` for NVMe 2.0 drives connected directly to CPU lanes.
- `compression=lzo` for all other NVMe drives.
- `compression=lzo` for SATA-connected SSDs.
- `compression=zstd:3` for SATA-connected HDDs.
- `compression=zstd:3` for USB-connected drives.

!!! bug

    Sometimes filesystems cannot be mounted with `compress`,
    presumably for any number of reasons.

!!! warning

    Make sure to follow the steps below to verify that your `fstab` is valid and useable.

### Edit `fstab`

Following these rules, the `fstab` for “Example scheme 1 – single-user workstation” might look like this:

```fstab
# filesystem     mount      type   options                            d p
.../by-uuid/...  none       swap   sw                                 0 1
.../by-uuid/...  /boot/efi  vfat   defaults                           0 1
.../by-uuid/...  /tmp       btrfs  noatime,noacl,noexec,nodev,nosuid  0 1
.../by-uuid/...  /var/tmp   btrfs  noatime,noacl,noexec,nodev,nosuid  0 1
.../by-uuid/...  /          btrfs  noatime,noacl                      0 1
.../by-uuid/...  /data      btrfs  noatime,noacl                      0 1
.../by-uuid/...  /docs      btrfs  noatime,noacl,compress=lzo         0 1
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

## Install packages

Open a terminal and enter the following commands to install the necessary packages:

=== "Ubuntu"

    First, enable the Universe repository:

	```bash
	sudo add-apt-repository universe -y
	```

    ```bash
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


## Set up firewall

=== "Ubuntu"

    ```bash
    sudo ufw enable
    ```

=== "Fedora"

    Fedora should come with `firewalld` installed and enabled by default.

## Cosmetics/UI

In GNOME’s settings, set the time format to 24-hour and make sure <i>Automatic Data and Time</i> is selected.

### GNOME extensions

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

- <i>Force Quit</i>
- <i>Panel Date Format</i>
  After installing, run
  ```bash
  dconf write /org/gnome/shell/extensions/panel-date-format/format "'%Y-%m-%d %H:%M'"
  ```

{!guide/_common-setup.md!}

!!! note "Thanks"
    Thank you to Cole Helsell for drafting this guide with me.
