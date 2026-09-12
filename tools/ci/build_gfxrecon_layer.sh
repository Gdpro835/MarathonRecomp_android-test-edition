#!/usr/bin/env bash
# Builds the GFXReconstruct capture layer for Android and copies it next to the
# app's native libraries, where the CI packaging step picks up every *.so and
# drops it into the APK's jniLibs. The layer is diagnostic-only: it stays
# completely idle unless an empty driver_import/gfxrecon_capture.txt marker
# file exists on the device (see ApplyGfxreconstructCapture in
# MarathonRecomp/os/android/vulkan_driver_android.cpp and README-ANDROID.md).
#
# Usage: build_gfxrecon_layer.sh <src-dir> <build-dir> <ndk-dir> <abi> <out-dir>
set -euo pipefail

SRC_DIR="$1"
BUILD_DIR="$2"
NDK="$3"
ABI="$4"
OUT_DIR="$5"

# Pinned upstream commit the layer is built from. Update deliberately: capture
# files are replayed with the gfxrecon tools, and newer replays read older
# captures, but an untested jump could break the packaging step silently.
GFXR_URL="https://github.com/LunarG/gfxreconstruct.git"
GFXR_REF="6164e4a484235ffa0b93d7755c180e93888fcf67"

mkdir -p "$SRC_DIR" "$BUILD_DIR" "$OUT_DIR"

if [ ! -d "$SRC_DIR/.git" ]; then
    git clone --depth 1 "$GFXR_URL" "$SRC_DIR"
    git -C "$SRC_DIR" fetch --depth 1 origin "$GFXR_REF"
    git -C "$SRC_DIR" checkout --detach "$GFXR_REF"
    git -C "$SRC_DIR" submodule update --init --depth 1 --recursive
fi

cmake -S "$SRC_DIR" -B "$BUILD_DIR" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ABI" \
    -DANDROID_PLATFORM=android-29 \
    -DANDROID_STL=c++_static

cmake --build "$BUILD_DIR" --target VkLayer_gfxreconstruct --parallel 2

# Place the layer where the "Copy native libs into jniLibs" CI step collects
# every *.so from the MarathonRecomp build output directory.
cp "$BUILD_DIR/layer/libVkLayer_gfxreconstruct.so" "$OUT_DIR/libVkLayer_gfxreconstruct.so"
echo "GFXReconstruct capture layer built: $OUT_DIR/libVkLayer_gfxreconstruct.so"
