# Setup guides

<!--
SPDX-FileCopyrightText: Copyright 2017-2026, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

!!! abstract "How to use"

    Use these guide as **checklists** to avoid forgetting a step.
    They also include some less common recommendations that may be useful.

## OS setup guides

[:fontawesome-solid-laptop-code: **Linux**](linux.md):
Issues, bugs, partitions, workarounds, CUDA, etc.

[:fontawesome-solid-laptop-code: **macOS**](macos.md):
Security, settings, Brew, ZSH, etc.

[:fontawesome-solid-laptop-code: **Windows**](windows.md):
Packages, services, updates, drivers, utils, WSL, etc.

### Partial guides

[:fontawesome-solid-terminal: **Nix shells**](nix-shells.md):
ZSH, shell config, and dot files

[:fontawesome-solid-code-branch: **Git, SSH, and GPG**](git-ssh-and-gpg.md):
Git, GitHub, SSH, GPG, and signed commits

[:fontawesome-solid-desktop: **GNOME**](gnome.md):
GNOME (desktop environment)

[:fontawesome-solid-desktop: **KDE**](kde.md):
KDE (desktop environment)

[:fontawesome-solid-toolbox: **Toolkits**](toolkits.md):
Language toolkits

### Linked scripts

[:fontawesome-solid-gear: **`commonrc-config.sh`**](files/commonrc-config.sh):
Script to manage your `.commonrc`

[:fontawesome-solid-tent: **`commonrc.sh`**](files/commonrc.sh):
Example `.commonrc` file

[:fontawesome-solid-laptop-code: **`add-bookmarks.sh`**](files/add-bookmarks.sh):
Add GNOME Files bookmarks

[:fontawesome-solid-code-branch: **`gh-aliases.sh`**](files/git-aliases.sh):
Defines Git aliases

## Software setup guides

[:fontawesome-solid-microchip: **Arduino**](arduino.md):
Bash scripts to download and install
[arduino](https://arduino.cc)

[:fontawesome-solid-film: **ffmpeg**](ffmpeg.md):
Bash scripts to download, build, and install
[ffmpeg](https://ffmpeg.org/)
with extensions

[:fontawesome-solid-worm: **Mamba and Conda-Forge**](mamba-and-conda.md):
Instructions for
[MicroMamba](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html)
and
[Conda-Forge](https://conda-forge.org/)

[:fontawesome-solid-database: **MariaDB**](mariadb.md):
Advanced configuration and rootless install of
[MariaDB](https://mariadb.org/)

### Linked scripts

[:fontawesome-solid-clapperboard: **`install-ffmpeg.sh`**](files/install-ffmpeg.sh)
Builds ffmpeg with plugins

[:fontawesome-solid-hard-drive: **`find-crontab.sh`**](../scripts/find-crontab.sh)
Lists crontab file paths in any OS

[:fontawesome-solid-carrot: **`install-mariadb-non-root.sh`**](files/install-mariadb-non-root.sh)
Set up MariaDB without sudo

[:fontawesome-solid-box-archive: **`back-up-mariadb.sh`**](../scripts/back-up-mariadb.sh)
Export robust `.sql.zst` files

[:fontawesome-solid-copy: **`write-mariadb-schema.sh`**](../scripts/write-mariadb-schema.sh):
Write `.sql` schema files

## Standalone scripts

These are miscellaneous standalone scripts.

[:fontawesome-solid-message: **`apprise.sh`**](../scripts/apprise.sh):
Tiny logging library for shell scripts

[:fontawesome-solid-file-zipper: **`extract.sh`**](../scripts/extract.sh):
A script to extract compressed files and archives

[:fontawesome-solid-clipboard-check: **`todos.sh`**](../scripts/todos.sh):
Finds `TODO` and `FIXME` comments

[:fontawesome-solid-scroll: **`gh-log.sh`**](../scripts/gh-log.sh):
Git log with GitHub commit URLs

[:fontawesome-solid-terminal: **`copy.sh`**](../scripts/copy.sh):
`rsync` pretending to be `cp`
<span class="experimental">
:fontawesome-solid-triangle-exclamation: experimental
</span>

[:fontawesome-solid-feather: **`create-btrfs-backup.sh`**](../scripts/create-btrfs-backup.sh):
Backups using Btrfs snapshots
<span class="experimental">
:fontawesome-solid-triangle-exclamation: experimental
</span>

