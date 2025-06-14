#!/usr/bin/env bash
set -eu

# This script creates an optimized release build.

OUT_DIR="build/release"
mkdir -p "$OUT_DIR"
odin build . -define="VERSION=$(cat VERSION)" -o:speed -out:$OUT_DIR -strict-style -vet -no-bounds-check
echo "Release build created in $OUT_DIR"
