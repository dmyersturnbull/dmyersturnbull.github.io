# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

# This file is meant to be sourced.

# ------------------------------------------------------------------------------- #
# ::: Set environment variables :::

export JAVA_HOME=/opt/temurin21

export PATH
PATH="$PATH:/usr/sbin:/usr/local/sbin:$HOME/bin"
PATH="$PATH:$JAVA_HOME/bin"

# ------------------------------------------------------------------------------- #
# ::: Simple aliases and functions :::

# Allow user aliases to be used as the superuser via `sudo -E`.
# See https://unix.stackexchange.com/a/349290
alias sudo-e='sudo -E '

# Prevent accidentally bricking a system with e.g. `chown -R . /` instead of `chown -R ./`.
# `rm -rf . /` would require `--no-preserve-root`, but `chown`, `chmod`, and `chgrp` don't.
# Making a mistake can render a system non-bootable.
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# Use color in grep by default.
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# These are nice as navigation shorthands.
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'

alias git-root='git rev-parse --show-toplevel'

# Make a directory if it doesn't exist, then cd to it.
mkcd() {
  mkdir -p -- "$1" || return $?
  cd -- "$1" || return $?
}

# Run chown recursively
grab() {
  sudo "$SHELL" -c chown -R "$USER:$USER" "${1:-.}" || return $?
}

# ------------------------------------------------------------------------------- #
# ::: Aliases to show processes, memory, etc. :::

# Also remember 'dig' and 'lsof'

alias ports='netstat \
  --tcp \
  --udp \
  --listening \
  --numeric \
  --programs'

alias strain='vmstat \
  --active'

alias memory='free \
  --human'

alias file-handles='ls \
  --long \
  --all \
  /proc/$$/fd'

alias thread-io='sudo iotop \
  --only \
  --batch \
  --iter 1'

alias process-io='sudo iotop \
  --only \
  --batch \
  --iter 1 \
  --processes'

alias resolve-dns='resolvectl \
  dns'

alias threads='ps \
  --all \
  --full \
  --long \
  --threads \
  --sort=y \
  --headers'

alias sockets='sudo ss \
  --listening \
  --processes'

alias tcp-sockets='sudo ss \
  --listening \
  --processes \
  --tcp'

alias udp-sockets='sudo ss \
  --listening \
  --processes \
  --udp'

# ------------------------------------------------------------------------------- #
# ::: Aliases for eza  :::

# Single-line eza (read: "EZa").
alias ez='eza \
  --all \
  --sort=name \
  --group-directories-first \
  --icons \
  --created \
  --modified \
  --git'

# Eza in a list (read: "EZZa").
alias ezz='eza \
  --all \
  --sort=name \
  --group-directories-first \
  --icons \
  --git \
  --long'

# Eza with a full list (read: "EZZZa").
alias ezzza='eza \
  --header \
  --all \
  --sort=name \
  --group-directories-first \
  --icons \
  --created \
  --modified \
  --git \
  --long \
  --octal-permissions'

# Eza with a grid (read: "EZa Grid").
alias ezg='eza \
  --header \
  --all \
  --sort=name \
  --group-directories-first \
  --icons \
  --created \
  --modified \
  --git \
  --long \
  --grid'

# Eza for permissions (read: "EZa (X)permissions").
alias ezx='eza \
  --all \
  --sort=name \
  --group-directories-first \
  --long \
  --grid \
  --no-time \
  --smart-group \
  --octal-permissions'

update-system() {
  # assume arguments like --quiet and --yes are being delegated
  sudo apt update "$@" || return $?
  sudo apt upgrade "$@" || return $?
  sudo apt dist-upgrade "$@" || return $?
  sudo snap refresh || return $?
}
