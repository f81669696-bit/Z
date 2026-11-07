#!/bin/bash
set -e
cd ~/cube
git fetch origin
git reset --hard origin/main
export PATH=$PATH:$HOME/.local/zig

# install SDL3 via apt or build from github
if ! ldconfig -p 2>/dev/null | grep -q libSDL3; then
    echo "installing SDL3 from apt..."
    sudo apt-get update -qq
    sudo apt-get install -y libsdl3-dev 2>/dev/null || {
        echo "apt SDL3 not found, building from source..."
        sudo apt-get install -y cmake build-essential git
        cd /tmp
        rm -rf SDL
        git clone --depth=1 --branch release-3.2.10 https://github.com/libsdl-org/SDL.git
        cmake -S SDL -B SDL/build -DSDL_TESTS=OFF -DSDL_EXAMPLES=OFF -DCMAKE_BUILD_TYPE=Release
        cmake --build SDL/build -j$(nproc)
        sudo cmake --install SDL/build
        sudo ldconfig
    }
    cd ~/cube
    echo "SDL3 ready"
fi

zig build 2>&1
