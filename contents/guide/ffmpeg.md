# FFmpeg setup

<!--
SPDX-FileCopyrightText: Copyright 2017-2024, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

## Compiling FFmpeg on Ubuntu

Configure hardware video encoding, if supported by your GPU.
QuickSync is one option; it should support AV1 eventually on Alder Lake and higher.

Then, compile ffmpeg with required options:

```bash
set -o errexit -o nounset -o pipefail

ffmpeg_vr="7.1"  # (1)!

sudo apt-get install --yes \
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
  xz-utils

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig"

declare -r dist_url="https://ffmpeg.org/releases/ffmpeg-$ffmpeg_vr.tar.xz"
declare -r repo_url=https://gitlab.com/AOMediaCodec/SVT-AV1.git
declare -r work_dir="ffmpeg-$ffmpeg_vr"
declare -r repo_dir="$work_dir/SVT-AV1"
curl ---location --max-redirs 3 --fail --no-progress-meter "$dist_url" \
  | tar -x -f \
  > "ffmpeg-$ffmpeg_vr"
  || exit $?

# Note: Must configure SSH keys with GitLab
# https://stackoverflow.com/a/12704727/4024340
declare -r repo_url=https://gitlab.com/AOMediaCodec/SVT-AV1.git
declare -r work_dir="ffmpeg-$ffmpeg_vr"
declare -r repo_dir="$work_dir/SVT-AV1"
tag_line=$(
  git -c 'versionsort.suffix=-' \
    ls-remote --exit-code --refs --sort='version:refname' --tags "$repo_url" '*.*.*' \
    | tail --lines=1 \
) || exit $?

latest_hash=$(echo "$tag_line" | awk '{print $1}')
latest_tag=$(echo "$tag_line" | cut -d '/' -f 3)

# get latest_hash and latest_tag
git clone --depth 1 "$repo_url" "$latest_hash" "$repo_dir"
>&2 printf 'Using latest tag %s (%s)\n' "$latest_tag" "${latest_hash:0:12}"

# Previous solution:
# git clone --depth=1 "$repo_url" "$repo_dir" || exit $?
# git -C "$repo_dir" fetch --tags || exit $?
# latest_hash="$( git -C "$repo_dir" rev-list --tags --max-count=1 )" || exit $?
# latest_tag="$( git -C "$repo_dir" describe --tags "$latest_hash" )" || exit $?
# >&2 printf 'Using latest tag %s (%s)\n' "$latest_tag" "${latest_hash:0:12}"\
# git -C "$ switch --detach "$"

cd Build
cmake .. -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
make -j $(( $(nproc) -1 ))
sudo make install

./configure \
  --enable-libsvtav1 \
  --enable-libvpx \
  --enable-libwebp \
  --enable-libx265 \
  --enable-libaom \
  --enable-libopus \
  --enable-gpl
make -j $(( $(nproc) -1 ))

# If needed
sudo make install

# Make sure this shows libsvtav1
if ! $( ffmpeg -version | grep libsvtav1 ) ; then
    >&2 printf "No libsvtav1\n"
fi
```

1. Set this to the most recent version

!!! thanks

    Thank you to Cole Helsell for drafting this guide with me.
