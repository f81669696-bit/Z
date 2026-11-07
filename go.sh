#!/bin/bash
cd ~/cube
git fetch origin
git reset --hard origin/main
export PATH=$PATH:$HOME/.local/zig
zig build 2>&1