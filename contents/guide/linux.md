# Linux setup

A setup guide for programmers, etc., on Linux and the Windows Linux Subsystem.
Alternatives for Ubuntu/Debian-like and Fedora/RedHat-like are shown.

!!! note "See also"
    [macOS setup guide](macos.md) and
    [Windows setup guide](windows.md)

## Install

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
- Add `noexec`, `nodev`, and `nosuid` to `/tmp` and `/var/tmp` (if they exist).

### Consider compression.

btrfs can compress data at rest and in transit.
Whether to use lzo, zstd, or no compression depends primarily on the (uncompressed) throughput:
Use heavier compression to compensate for slow IO, and use lighter compression for fast IO.
Use no compression if the CPU is already the bottleneck.
See [benchmarks for btrfs compression](https://gist.github.com/braindevices/fde49c6a8f6b9aaf563fb977562aafec).
Here are my recommendations:

- `compression=off` for NVMe SSDs
- `compression=lzo` for SATA-connected SSDs
- `compression=zstd:3` for SATA-connected HDDs and USB-connected SSDs or HHDs

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

## Install packages

Open a terminal and enter the following commands to install the necessary packages:

=== "Ubuntu"

    First, enable the Universe repository:

    ```bash
    sudo add-apt-repository universe -y
    ```

    ```bash
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

## Set up firewall

=== "Ubuntu"

    ```bash
    sudo ufw enable
    ```

=== "Fedora"

    Fedora should come with `firewalld` installed and enabled by default.

## Allow SSH login

Install ssh to allow for remote logins.

```
sudo apt update
sudo apt install openssh-server
sudo ufw allow 22
```

## Consider using dotfiles

I recommend [chezmoi](https://www.chezmoi.io/) for managing dotfiles
and installing it via apt/dnf or asdf.
After installing, follow the [quick start guide](https://www.chezmoi.io/docs/quick-start/).
Use `~/.commonrc` for all chezmoi commands; e.g. `chezmoi add ~/.commonrc`.

## Cosmetics/UI

### Eza and Nerd fonts

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

In GNOME’s settings, set the time format to 24-hour and make sure <i>Automatic Data and Time</i> is selected.
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

- <i>Force Quit</i>
- <i>Panel Date Format</i>
  After installing, run
  ```bash
  dconf write /org/gnome/shell/extensions/panel-date-format/format "'%Y-%m-%d %H:%M'"
  ```

### Nautilus favorites

To remove the favorites for Videos, Music, etc. that Nautilus forces on you, run this script:

```bash
echo '
# This file was created manually.

# Keep these:
XDG_DESKTOP_DIR="$HOME/Desktop"
XDG_DOWNLOAD_DIR="$HOME/Desktop" # (1)!

# Exclude these:
#XDG_DOCUMENTS_DIR="$HOME/Documents"
#XDG_TEMPLATES_DIR="$HOME/Templates"
#XDG_PUBLICSHARE_DIR="$HOME/Public"
#XDG_MUSIC_DIR="$HOME/Music"
#XDG_PICTURES_DIR="$HOME/Pictures"
#XDG_VIDEOS_DIR="$HOME/Videos"
' > ~/.config/user-dirs.dirs

# Create a user-dirs.conf file to prevent automatic updates
echo '
# We created ~/.config/user-dirs.dirs manually
# Prevent xdg-user-dirs-update from overwriting it
enabled=False
' > ~/.config/user-dirs.conf
```

1. Change back to `XDG_DOWNLOAD_DIR="$HOME/Downloads"` if you want downloads separate.

??? bug "Workaround if this doesn’t work."

    This **might** work instead.

    ```bash
    echo '
    # This file was created manually.

    # Keep these:
    XDG_DESKTOP_DIR="$HOME/Desktop"
    XDG_DOWNLOAD_DIR="$HOME/Desktop"

    # Exclude these:
    XDG_DOCUMENTS_DIR="$HOME/.junk/Documents"
    XDG_TEMPLATES_DIR="$HOME/.junk/Templates"
    XDG_PUBLICSHARE_DIR="$HOME/.junk/Public"
    XDG_MUSIC_DIR="$HOME/.junk/Music"
    XDG_PICTURES_DIR="$HOME/.junk/Pictures"
    XDG_VIDEOS_DIR="$HOME/.junk/Videos"
    ' > ~/.config/user-dirs.dirs

    # Create a user-dirs.conf file to prevent automatic updates
    echo '
    # We created ~/.config/user-dirs.dirs manually
    # Prevent xdg-user-dirs-update from overwriting it
    enabled=False
    ' > ~/.config/user-dirs.conf
    ```

The following script will add bookmarks (though you can also do this in Nautilus).
Example usage: `~/bin/add-bookmarks.sh data=/data/ docs=/docs/`

??? details

    ```bash
    #!/usr/bin/env bash
    set -euo pipefail

    bookmark_file="${HOME}/.config/gtk-3.0/bookmarks"
    _desc="Add Nautilus bookmarks."
    _usage="Usage: $0 <name1>=<path1> [...]"

    bookmarks::help() {
        printf "${_desc}\n${_usage}\n"
        exit 0
    }

    bookmarks::usage() {
      >&2 printf "${_desc}\n${_usage}\n"
      exit 2
    }

    # Function to add a bookmark
    bookmarks::add() {
        local path="$1"
        local name="$2"
        local bookmark_entry="file://${path} ${name}"

        # Add only if it doesn't already exist
        if ! grep -q "${bookmark_entry}" "${bookmark_file}"; then
            echo "${bookmark_entry}" >> "${bookmark_file}"
            >&2 echo "Added bookmark ${name} → ${path}."
        else
            >&2 echo "Bookmark ${name} → ${path} already exists."
        fi
    }

    (( $# == 1 )) && [[ "$1" == "--help" ]] && bookmarks::help
    (( $# == 0 )) && bookmarks::usage

    for arg in "$@"; do
        IFS='=' read -r name path <<< "${arg}"
        [[ -z "${name}" || -z "${path}" ]] && bookmarks::usage
        bookmarks::add "${name}" "${path}"
    done
    >&2 echo "Finished adding bookmarks."
    ```

Then, restart Nautilus to apply the settings:

```bash
nautilus -q
```

## Install [Oh My Zsh](https://ohmyz.sh/)

You’ll thank me later. (You’ll need ZSH installed for this to work.)

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

You should be prompted to change your shell.
If you are not, run

```bash
chsh -s $(which zsh)
```

Make sure it is set by running

```bash
sudo cat /etc/passwd | grep ${USER}
```

You may need to reboot for the change to your login shell to take effect.
You should now have a colorful shell, complete with a plugin for Git.

## `.commonrc` file

To keep the config for ZSH and Bash consistent, add a file called `.commonrc` in your home directory:

```bash
echo 'export PATH=/usr/local/sbin:$PATH\n' > ~/.commonrc
echo 'source ~/.commonrc\n' >> ~/.zshrc
echo 'source ~/.commonrc\n' >> ~/.bashrc
```

From here on, only modify `.commonrc` so that both Bash and ZSH have the same environment.

## Git, SSH, and GPG

**See [this guide](git-ssh-and-gpg.md).**

## Install Java and Rust

First, [Install the Rust toolchain](https://rustup.rs/).

Then, download [JDK 21 from Temurin](https://adoptium.net/temurin/releases/).
Do not use Java 8, java.com, or OpenJDK.
Make sure it’s on your `$PATH` by running `java --version` in a new shell.

## Generate a certificate

If you need a certificate, set a static IP address and generate a certificate with
[certbot](https://certbot.eff.org/). Choose “None of the above” for Software.
Then follow the instructions exactly, including the “Automating renewal” section.
This may not work through some company and university firewalls.

## Sudoers

The easiest way is to run

```bash
su  #(1)!
usermod -aG sudo $USER
```

1. This will require you to enter the root password.

See this [sudoers guide](https://www.cyberciti.biz/faq/how-to-sudo-without-password-on-centos-linux/) for more info.

## Dotfiles

See [awesome-dotfiles](https://github.com/webpro/awesome-dotfiles). Here are some I used:

```bash
# xdg-open occasionally assumed in scripts,
# so aliasing it to macOS's `open` is a good idea
# alias xdg-open=open

# These improve safety
# Accidentally running `chown -R xx . /` (on root) can brick your system
# The same goes for chmod and chgrp
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

alias wgetc='wget -c'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# list open file handles for the current shell session (also see lsof)
alias handles='ls -la /proc/$$/fd'

# Check free memory
alias fre='free --human'

# Check CPU, memory, and swap usage
alias usg='vmstat --active'

# Check IO usage
alias iousg='sudo iotop --only --batch'

# List listening sockets
alias lssockets='sudo --listening --processes'
alias lstcp='sudo --listening --processes --tcp'
alias lsudp='sudo --listening --processes --udp'

# List threads
# -A == all processes
# -f == full listing (show args)
# -L == show threads
# -l == long format
# -y == Hide flags and show resident set size (RSS; memory used) instead of addr
# --headers == repeat header line once per page
# In the output:
# - NLWP is # of threads
# - LWP is "light-weight process"
alias threads='ps -A -f -L -l -y -S --headers'

# Normal grid exa (--created, --modified, and --git have no effect unless we pass --list)
alias e='exa --all --sort=name --group-directories-first --icons --created --modified --git'
# Detailed view with --list
alias el='exa --all --sort=name --group-directories-first --icons --created --modified --git --list'
# Detailed view in a grid (for wide monitors)
alias elg='exa --all --sort=name --group-directories-first --icons --created --modified --git --list --grid'

# These are nice as navigation shorthands
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'

# make a dir and cd to it
function mkcd {
    mkdir "$1" && cd "$1"
}

# This one chowns recursively for you
function grab() {
	sudo chown -R ${USER}:${USER} ${1:-.}
}

# This one's modified from https://serverfault.com/questions/3743/what-useful-things-can-one-add-to-ones-bashrc
function extract () {
   if [[ ! -f "$1" ]] ; then
       >&2 echo "'$1' is not a file"
       exit 2
   fi
   case "$1" in
       *.tar.bz2)   tar xvjf "$1"    ;;
       *.tar.gz)    tar xvzf "$1"    ;;
       *.bz2)       bunzip2 "$1"     ;;
       *.rar)       unrar x "$1"     ;;
       *.gz)        gunzip "$1"      ;;
       *.tar)       tar xvf "$1"     ;;
       *.tbz2)      tar xvjf "$1"    ;;
       *.tgz)       tar xvzf "$1"    ;;
       *.zip)       unzip "$1"       ;;
       *.Z)         uncompress "$1"  ;;
       *.snappy)    snunzip "$1"     ;;
       *.sz)        snunzip "$1"     ;;
       *.br)        brotli -d "$1"   ;;
       *.xz)        unxz "$1"        ;;
       *.lz4)       unlz4 "$1"       ;;
       *.lzma)      unlzma  "$1"     ;;
       *.zst)       unzstd "$1"      ;;
       *.7z)        7z x "$1"        ;;
       *)           >&2 echo "I don't know how to extract '$1'"; exit 1 ;;
   esac
 }
```

*[LTS]: Long-Term Support
*[UEFI]: Unified Extensible Firmware Interface
*[JDK]: Java Development Kit

!!! note "Thanks"
    Thank you to Cole Helsell for drafting this guide with me.
