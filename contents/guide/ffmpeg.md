# FFmpeg setup

## Compiling FFmpeg on Ubuntu

Configure hardware video encoding, if supported by your GPU.
QuickSync is one option; it should support AV1 eventually on Alder Lake and higher.

Then, compile ffmpeg with required options:

```bash
set -euo pipefail
IFS=$'\n\t'

ffmpeg_vr="6.0"  # (1)!

sudo apt install \
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

export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/lib"
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:/usr/local/lib/pkgconfig"

curl -L -s https://ffmpeg.org/releases/ffmpeg-${ffmpeg_vr}.tar.xz \
    | tar -xf \
    > "ffmpeg-${ffmpeg_vr}"
cd "ffmpeg-${ffmpeg_vr}"

# Need to configure SSH keys with GitLab
git clone --depth=1 https://gitlab.com/AOMediaCodec/SVT-AV1.git
cd SVT-AV1
git fetch --tags
git checkout $( git describe --tags $( git rev-list --tags --max-count=1 ) )
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
    >&2 echo "No libsvtav1"
fi
```

1. Set this to the most recent version

!!! note "Thanks"
    Thank you to Cole Helsell for drafting this guide with me.
