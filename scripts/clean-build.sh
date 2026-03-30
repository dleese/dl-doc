#!/usr/bin/env bash
# Remove the CMake build directory (default: <repo>/build).
# Usage: ./scripts/clean-build.sh [path-to-build-dir]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${1:-$ROOT/build}"
if [[ ! -e "$BUILD_DIR" ]]; then
  echo "Nothing to remove: $BUILD_DIR"
  exit 0
fi
rm -rf "$BUILD_DIR"
echo "Removed: $BUILD_DIR"
