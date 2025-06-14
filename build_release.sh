#!/usr/bin/env bash
set -eu

APP_NAME="ox"
OUT_DIR="build/release"

mkdir -p "$OUT_DIR"
odin build . -define="VERSION=$(cat VERSION)" -o:speed -out:$OUT_DIR/$APP_NAME # -strict-style -vet -no-bounds-check
echo "Release build created in $OUT_DIR"
