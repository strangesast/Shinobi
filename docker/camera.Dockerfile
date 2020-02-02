from debian:stretch as ffmpeg

workdir /ffmpeg

run apt-get update && \
  apt-get install -y software-properties-common && \
  add-apt-repository non-free && \
  apt-get update && \
  apt-get -y install \
    autoconf \
    automake \
    build-essential \
    checkinstall \
    cmake \
    git-core \
    libass-dev \
    libfreetype6-dev \
    libsdl2-dev \
    libtool \
    libva-dev \
    libvdpau-dev \
    libvorbis-dev \
    libxcb1-dev \
    libxcb-shm0-dev \
    libxcb-xfixes0-dev \
    pkg-config \
    texinfo \
    wget \
    nasm \
    yasm \
    libx264-dev \
    libx265-dev libnuma-dev \
    libfdk-aac-dev \
    libmp3lame-dev \
    libopus-dev \
    libvpx-dev \
    zlib1g-dev

run wget -O /tmp/ffmpeg-4.2.2.tar.bz2 https://ffmpeg.org/releases/ffmpeg-4.2.2.tar.bz2 && \
  tar -xf /tmp/ffmpeg-4.2.2.tar.bz2 -C /ffmpeg --strip-components=1

run mkdir -p /ffmpeg/build && ./configure \
  --pkg-config-flags="--static" \
  --extra-libs="-lpthread -lm" \
  --enable-gpl \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree && \
  make -j4

run checkinstall \
  --requires="libxcb-shape0,libxcb-xfixes0,libasound2,libsdl2-2.0-0,libxv-dev,libva-dev,libass-dev,libvpx-dev,libfdk-aac-dev,libmp3lame-dev,libopus-dev,libx264-dev,libx265-95,libvdpau-dev" \
  --fstrans=no \
  --install=no \
  -D make install && \
  mv ffmpeg*.deb ffmpeg.deb

from node:latest

workdir /app

copy --from=ffmpeg /ffmpeg/ffmpeg.deb /tmp
run apt-get update && \
  apt-get install -y software-properties-common && \
  add-apt-repository non-free && \
  apt-get update && \
  apt-get install -y /tmp/ffmpeg.deb && rm /tmp/ffmpeg.deb

copy package*.json .
run npm install
copy . .

cmd ["node", "camera.js"]
