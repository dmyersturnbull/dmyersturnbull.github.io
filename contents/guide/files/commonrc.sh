# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

# This file is meant to be sourced.

# ------------------------------------------------------------------------------- #
# ::: Set environment variables :::

export JAVA_HOME
JAVA_HOME=/opt/jdk24
# JAVA_HOME=/opt/homebrew/opt/openjdk24 # macOS
export PATH
PATH="$PATH:/usr/sbin:/usr/local/sbin:$HOME/bin"
PATH="$PATH:$JAVA_HOME/bin"

# ------------------------------------------------------------------------------- #
# ::: Simple aliases and functions :::

# Allow user aliases to be used as the superuser via `sudo -E`.
# See https://unix.stackexchange.com/a/349290
alias sudo-e='sudo -E '

if [[ "$(uname)" == Linux ]]; then
  #
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
fi

# These are nice as navigation shorthands.
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'

alias git-root='git rev-parse --show-toplevel'

# Make a directory if it doesn't exist, then cd to it.
if [[ "$(uname)" == Linux ]]; then
  mkcd() {
    mkdir --parents -- "$1" || return $?
    cd -- "$1" || return $?
  }
else
  mkcd() {
    mkdir -p "$1" || return $?
    cd "$1" || return $?
  }
fi

# Run chown recursively
if [[ "$(uname)" == Linux ]]; then
  grab() {
    sudo "$SHELL" -c chown -R "$USER:$USER" -- "${1:-.}" || return $?
  }
else
  grab() {
    sudo "$SHELL" -c chown -R "$USER:$USER" "${1:-.}" || return $?
  }
fi

# ------------------------------------------------------------------------------- #
# ::: Aliases to show processes, memory, etc. :::

# Also remember 'dig' and 'lsof'

if command -v netstat; then
  alias ports='netstat --tcp --udp --listening --numeric --programs'
  alias strain='vmstat --active'
fi

if command -v free; then
  alias memory='free --human'
fi

if [[ -e '/proc$$' ]]; then
  alias file-handles='ls --long --all /proc/$$/fd'
fi

if command -v iotop; then
  alias thread-io='sudo iotop --only --batch --iter 1'
  alias process-io='sudo iotop --only --batch --iter 1 --processes'
fi

if command -v resolvectl; then
  alias resolve-dns='resolvectl dns'
fi

if [[ "$(uname)" == Linux ]]; then
  alias threads='ps --all --full --long --threads --sort=y --headers'
fi

if command -v ss; then
  alias sockets='sudo ss --listening --processes'
  alias tcp-sockets='sudo ss --listening --processes --tcp'
  alias udp-sockets='sudo ss --listening --processes --udp'
fi

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

# ------------------------------------------------------------------------------- #
# ::: Commands related to Git :::

__git_tag() {
  git tag --sign --message="$1" -- "$1" || return $?
}
alias git-tag=__git_tag

__git_retag() {
  git tag --force --sign --message="$1" -- "$1" || return $?
}
alias git-retag=__git_retag

__git_retag_and_force_push() {
  git tag --sign --message="$1" --force -- "$1" || return $?
  git push origin --force -- "$1" || return $?
}
alias git-retag-and-force-push=__git_retag_and_force_push

# ------------------------------------------------------------------------------- #
# ::: Misc. aliases  :::

if [[ "$(uname)" == Linux ]]; then
  update-system() {
    # Assume arguments are e.g. `--quiet` and `--yes`.
    sudo apt update "$@" || return $?
    sudo apt upgrade "$@" || return $?
    sudo apt dist-upgrade "$@" || return $?
    sudo snap refresh || return $?
  }
else
  update-system() {
    brew update || return $?
    brew upgrade || return $?
    brew cleanup || return $?
    softwareupdate -i -a || return $?
  }
fi
