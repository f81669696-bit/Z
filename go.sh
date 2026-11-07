#!/bin/bash
set -e
cd ~/cube
git fetch origin
git reset --hard origin/main
export PATH=$PATH:$HOME/.local/zig
zig build 2>&1 | head -80