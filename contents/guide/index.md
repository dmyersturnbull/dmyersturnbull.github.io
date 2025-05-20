# Setup guides

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

---

<strong class="index">OS setup guides</strong>

!!! abstract "How to use"

    Use these guide as **checklists** to avoid forgetting a step.
    They also include some less common recommendations that may be useful.

[:fontawesome-solid-laptop-code: **Linux**](linux.md):
Firmware issues, GRUB bugs, advanced partitioning, compression, workarounds, CUDA, …

[:fontawesome-solid-laptop-code: **macOS**](macos.md):
Security, settings, Brew, ZSH, …

[:fontawesome-solid-laptop-code: **Windows**](windows.md):
Package managers, services, updates, drivers, utils, WLS, …

[:fontawesome-solid-laptop-code: **Nix shells**](nix-shells.md):
ZSH, shell config, and dot files _(referenced by other guides)_

[:fontawesome-solid-laptop-code: **Git, SSH, and GPG**](git-ssh-and-gpg.md):
Git, GitHub, SSH, GPG, and signed commits _(referenced by other guides)_

---

<strong class="index">General</strong>

[:fontawesome-solid-flask: **Research projects**](research-projects.md):
Suggestions for organizing computational research projects

---

<strong class="index">Various software</strong>

[:fontawesome-solid-code: **Arduino**](arduino.md):
Bash scripts to download and install
[arduino](https://arduino.cc)

[:fontawesome-solid-code: **ffmpeg**](ffmpeg.md):
Bash scripts to download, build, and install
[ffmpeg](https://ffmpeg.org/)
with extensions

[:fontawesome-solid-code: **Mamba and Conda-Forge**](mamba-and-conda.md):
Instructions for
[MicroMamba](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html)
and
[Conda-Forge](https://conda-forge.org/)

[:fontawesome-solid-code: **MariaDB**](mariadb.md):
Advanced configuration for
[MariaDB](https://mariadb.org/),
and installing it as non-root

---

<strong class="index">Scripts referenced in OS setup guides</strong>

[:fontawesome-solid-laptop-code: **`commonrc-config.sh`**](files/commonrc-config.sh):
Script to manage your `.commonrc`

[:fontawesome-solid-laptop-code: **`commonrc.sh`**](files/commonrc.sh):
Example `.commonrc` file

[:fontawesome-solid-laptop-code: **`add-bookmarks.sh`**](files/add-bookmarks.sh):
Add GNOME Files bookmarks

[:fontawesome-solid-laptop-code: **`gh-aliases.sh`**](files/git-aliases.sh):
Defines Git aliases

[:fontawesome-solid-gear: **`apprise.sh`**](../scripts/apprise.sh):
Tiny logging library for shell scripts (required)

---

<strong class="index">Scripts referenced in other guides</strong>

- [:fontawesome-solid-code: **`install-ffmpeg.sh`**](files/install-ffmpeg.sh)
  Builds ffmpeg with plugins
- [:fontawesome-solid-code: **`find-crontab.sh`**](../scripts/find-crontab.sh)
  Lists crontab file paths in any OS
- [:fontawesome-solid-code: **`install-mariadb-non-root.sh`**](files/install-mariadb-non-root.sh)
  Set up MariaDB without sudo
- [:fontawesome-solid-code: **`back-up-mariadb.sh`**](../scripts/back-up-mariadb.sh)
  Export robust `.sql.zst` files
- [:fontawesome-solid-code: **`write-mariadb-schema.sh`**](../scripts/write-mariadb-schema.sh):
  Write `.sql` schema files
- [:fontawesome-solid-gear: **`apprise.sh`**](../scripts/apprise.sh):
  Tiny logging library for shell scripts (required)

---

<strong class="index">Other scripts</strong>

- [:fontawesome-solid-terminal: **`extract.sh`**](../scripts/extract.sh):
  A script to extract compressed files and archives
- [:fontawesome-solid-terminal: **`todos.sh`**](../scripts/todos.sh):
  Finds `TODO` and `FIXME` comments
- [:fontawesome-solid-terminal: **`gh-log.sh`**](../scripts/gh-log.sh):
  Git log with GitHub commit URLs
- [:fontawesome-solid-terminal: **`copy.sh`**](../scripts/copy.sh):
  `rsync` pretending to be `cp` **(EXPERIMENTAL)**
- [:fontawesome-solid-terminal: **`create-btrfs-backup.sh`**](../scripts/create-btrfs-backup.sh):
  Btrfs-specific backups **(EXPERIMENTAL)**
