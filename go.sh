#!/bin/bash
set -e
cd ~/cube
git fetch origin
git reset --hard origin/main
export PATH=$PATH:$HOME/.local/zig

# install SDL3 if not present
if ! ldconfig -p 2>/dev/null | grep -q libSDL3; then
    echo "installing SDL3..."
    sudo apt-get update -qq
    sudo apt-get install -y cmake build-essential
    cd /tmp
    rm -rf sdl3_build
    mkdir sdl3_build && cd sdl3_build
    # build from source in repo
    unzip -q ~/cube/SDL3-3.4.20.zip -d .
    cmake SDL3-3.4.20 -DSDL_TESTS=OFF -DSDL_EXAMPLES=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local > /dev/null
    make -j$(nproc) > /dev/null
    sudo make install > /dev/null
    sudo ldconfig
    cd ~/cube
    echo "SDL3 installed"
fi

zig build 2>&1
