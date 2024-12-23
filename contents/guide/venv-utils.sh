#!/usr/bin/env bash

# =============================================== #
#                                                 #
#                WARNING: DEPRECATED              #
#                                                 #
# Use uv <https://docs.astral.sh/uv/> instead.    #
#                                                 #
# Uv has advanced since I wrote these scripts     #
# and now supports managing Python installations: #
# https://docs.astral.sh/uv/#python-management    #
#                                                 #
# =============================================== #


# First, install latest python via deadsnakes
# Then create a 'global' venv as root:
# sudo python3.13 -m venv /opt/venv/global/3.13
# Install **minimal** tools, including:
# sudo /opt/venv/global/3.13/bin/pip install uv hatch --only-binary :all
# Symlink to it:
# sudo ln -s /opt/venv/global/3.13 /opt/venv/global/latest
# Now define python-latest, uv-pip-latest (aka pip-latest), and true-pip-latest
alias python-latest=/opt/venv/global/latest/bin/python
alias true-pip-latest=/opt/venv/global/latest/bin/pip
uv-pip-latest() {
  python-latest -m uv pip "$@" || return $?
}
alias pip-latest=uv-pip-latest

create-venv() {
  if (( $# == 0 )); then
    >&2 echo "Usage: $0 path"
    return 2
  fi
  python-latest -m venv "$1" --system-site-packages --upgrade-deps "${@:2}" || return $?
  "$1/bin/pip" install uv || return $?
}

venv-new.() {
  local venv_path=./venv
  if [[ ! -e "$venv_path" ]]; then
    >&2 echo "venv already exists at $venv_path"
    return 1;
  fi
  create-env "$venv_path" "$@" || return $?
}

venv-new() {
  local repo_path
  repo_path=$(git-root) || return $?
  local venv_path="$repo_path/venv/"
  if [[ ! -e "$venv_path" ]]; then
    >&2 echo "venv already exists at $venv_path"
    return 1
  fi
  create-env "$venv_path" "$@" || return $?
}

_get_venv_path() {
  if (( $# != 1 )); then
    >&2 echo "error: $0 must be called as '$0 venv-path'"
    return 2
  fi
  local venv_path="$1/venv/"
  if [[ ! -e "$venv_path" ]]; then
    >&2 echo "No venv at $venv_path"
    return 1
  fi
  if [[ ! -e "$venv_path/bin/python" ]]; then
    >&2 echo "No python executable inside venv at $venv_path!"
    return 1
  fi
  if [[ ! -e "$venv_path/bin/pip" ]]; then
    >&2 echo "No pip executable inside venv at $venv_path!"
    return 1
  fi
  "$venv_path/bin/python -m uv --help" > /dev/null 2> /dev/null
  if ! $? ; then
    >&2 echo "uv is not installed in venv at $venv_path"
    return 1
  fi
  echo "$venv_path"
}

vpy() {
  local repo_path
  repo_path=$(git-root) || return $?
  local venv_path
  venv_path=$( _get_venv_path "$repo_path" ) || return $?
  "$venv_path/bin/python" "$@" || return $?
}

vpy.() {
  local venv_path
  venv_path=$( _get_venv_path . ) || return $?
  "$venv_path/bin/python" "$@" || return $?
}

vuv() {
  local repo_path
  repo_path=$(git-root) || return $?
  local venv_path
  venv_path=$( _get_venv_path "$repo_path" ) || return $?
  "$venv_path/bin/python" -m uv "$@" || return $?
}

vuv.() {
  local venv_path
  venv_path=$( _get_venv_path . ) || return $?
  "$venv_path/bin/python" -m uv "$@" || return $?
}

vpip() {
  local repo_path
  repo_path=$(git-root) || return $?
  local venv_path
  venv_path=$( _get_venv_path "$repo_path" ) || return $?
  "$venv_path/bin/python" -m uv pip "$@" || return $?
}

vpip.() {
  local venv_path
  venv_path=$( _get_venv_path . ) || return $?
  "$venv_path/bin/python" -m uv pip "$@" || return $?
}
