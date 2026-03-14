#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
BUILD_DIR="$PROJECT_DIR/build"
TARGET="$PROJECT_DIR/testbed"

MODE="debug"

if [ "$1" = "release" ]; then
    MODE="release"
elif [ -n "$1" ]; then
    echo "Unknown build mode: $1"
    echo "Usage: ./build.sh [release]"
    exit 1
fi

if [ ! -d "$BUILD_DIR" ]; then
    echo "Creating bin/ drectory..."
    mkdir -p "$BUILD_DIR"
fi

echo "Building testbed in $MODE mode..."
echo "Project directory: $PROJECT_DIR"

if [ "$MODE" = "debug" ]; then
    odin build "$TARGET" \
        -debug \
        -show-timings \
        -out:"$BUILD_DIR/testbed"
else
    odin build "$TARGET" \
        -show-timings \
        -out:"$BUILD_DIR/testbed"
fi
