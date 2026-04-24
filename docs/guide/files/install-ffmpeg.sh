#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2024, Contributors to dmyersturnbull.github.io
# SPDX-PackageHomePage: https://github.com/dmyersturnbull/dmyersturnbull.github.io
# SPDX-License-Identifier: Apache-2.0

set -o errexit -o nounset -o pipefail # "strict mode"

script_path="$(realpath -- "${BASH_SOURCE[0]}" || exit $?)"
declare -r script_name="${script_path##*/}"

if [[ "$(uname)" != Linux ]]; then
  printf "[ERROR] %s only supports Linux, not %s.\n" "$script_name" "$(uname)"
  exit 3
fi

# Define usage, help info, etc.

declare -r description="\
Description:
  Downloads, builds, and installs ffmpeg with plugins.
"

declare -r usage="\
Usage:
  $script_name --help
  $script_name <ffmpeg-version>

Arguments:
  <ffmpeg-version>   Example: 5.0.1

Options:
  -h, --help         Show this message and exit.
"

apprise() {
  printf >&2 "[%s] %s\n" "$1" "$2"
}

general_error() {
  apprise ERROR "$1"
  exit 1
}

# Parse arguments.

if (($# != 1)); then
  apprise ERROR "Incorrect usage." || true
  printf >&2 '%s\n' "$usage"
  exit 2
fi
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  printf '%s\n%s\n' "$description" "$usage"
  exit 0
fi
declare -r ffmpeg_vr="$1"

sudo apt-get install --quiet --yes \
  autoconf \
  automake \
  build-essential \
  cmake \
  git-core \
  libass-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  pkg-config \
  zlib1g-dev \
  libsvtav1-dev \
  libvpx-dev \
  libwebp-dev \
  libx265-dev \
  libaom-dev \
  nasm \
  yasm \
  xz-utils \
  || exit $?

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig"

declare -r dist_url="https://ffmpeg.org/releases/ffmpeg-$ffmpeg_vr.tar.xz"
declare -r repo_url=https://gitlab.com/AOMediaCodec/SVT-AV1.git
declare -r work_dir="ffmpeg-$ffmpeg_vr"
declare -r repo_dir="$work_dir/SVT-AV1"
curl ---location --fail --no-progress-meter "$dist_url" \
  | tar -x -f \
    > "ffmpeg-$ffmpeg_vr" \
  || exit $?

# Note: Must configure SSH keys with GitLab
# https://stackoverflow.com/a/12704727/4024340
tag_line=$(
  git -c 'versionsort.suffix=-' \
    ls-remote --exit-code --refs --sort='version:refname' --tags "$repo_url" '*.*.*' \
    | tail --lines=1 \
    || exit $?
)

latest_hash=$(echo "$tag_line" | awk '{print $1}') || exit $?
latest_tag=$(echo "$tag_line" | cut -d '/' -f 3) || exit $?

# get latest_hash and latest_tag
git clone --depth 1 "$repo_url" "$latest_hash" "$repo_dir" || exit $?
apprise INFO "Using latest tag $latest_tag (${latest_hash:0:12})."

# Previous solution:
# git clone --depth=1 "$repo_url" "$repo_dir" || exit $?
# git -C "$repo_dir" fetch --tags || exit $?
# latest_hash="$( git -C "$repo_dir" rev-list --tags --max-count=1 )" || exit $?
# latest_tag="$( git -C "$repo_dir" describe --tags "$latest_hash" )" || exit $?
# git -C "$ switch --detach "$"

n_cores="$(nproc --ignore 2 || echo 1)"

pushd Build
cmake .. -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
make -j "$n_cores" || exit $?
sudo make install || exit $?

./configure \
  --enable-libsvtav1 \
  --enable-libvpx \
  --enable-libwebp \
  --enable-libx265 \
  --enable-libaom \
  --enable-libopus \
  --enable-gpl \
  || exit $?

make -j "$n_cores" || exit $?

# If needed
sudo make install || exit $?

if ! ffmpeg -version; then
  general_error "ffmpeg command not found. Is it just not in PATH?"
fi

# Make sure this shows libsvtav1
if ! ffmpeg -version | grep libsvtav1 > /dev/null; then
  general_error "Expected library not found: libsvtav1."
fi
