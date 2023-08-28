# Linux setup

This documents best practice setup for shell profiles, security, SSH, and GPG
that work in Linux, macOS, and the Windows subsystem.

!!! note "See also"
    [macOS setup guide](macos-setup.md) and
    [Windows setup guide](windows-setup.md)

## Install Ubuntu

Install the most recent version or most recent LTS version of Ubuntu.
Change the UEFI settings so that you boot from the drive. Follow the instructions that show up
to install Linux.

!!! tip
    I faced this issue when installing the Linux OS onto Samsung SSD drives:
    `Unable to install GRUB`
    Try the following things in the UEFI interface to resolve this issue:
    - Make sure Fast Boot is Disabled.
    - Make sure Secure Boot is Disabled. Also, check to see if CSM/Legacy options is disabled.
    - Manually install the bootloader (not recommended).
    - Read about [Linux and UEFI](https://www.rodsbooks.com/linux-uefi/) for troubleshooting.

## Update & install packages

Open a terminal and enter the following commands to install the necessary packages:

```bash
sudo apt update && upgrade
sudo apt install python3 git vim wget xz-utils brotli lzma zstd exa
sudo apt install zsh
```

{!guide/_common-setup.md!}

!!! note "Thanks"
    Thank you to Cole Helsell for drafting this guide with me.
