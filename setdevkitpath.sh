#!/bin/bash

# Description: Set the environment variables for the build scripts.
export NDK_VERSION=r27b

# Target version defaults to 25. 17 and 21 remain useful as known-good
# references when porting the iOS patch set forward.
if [[ -z "${TARGET_VERSION:-}" ]]; then
  export TARGET_VERSION=25
fi

# Set custom java version as the default JDK depending on the target version.
# Local build with docker only.
if [[ -z "${CI:-}" ]]; then
  if command -v update-java-alternatives >/dev/null 2>&1; then
    update-java-alternatives -s java-1.${TARGET_VERSION}\* || true
  fi
fi

if [[ -z "${BUILD_FREETYPE_VERSION:-}" ]]; then
  export BUILD_FREETYPE_VERSION="2.10.0"
fi

if [[ -z "${JDK_DEBUG_LEVEL:-}" ]]; then
  export JDK_DEBUG_LEVEL=release
fi

if [[ "${TARGET_JDK:-}" == "aarch64" ]]; then
  export TARGET_SHORT=arm64
else
  export TARGET_SHORT="${TARGET_JDK:-}"
fi

if [[ -z "${JVM_VARIANTS:-}" ]]; then
  export JVM_VARIANTS=server
fi

if [[ "${BUILD_IOS:-0}" == "1" ]]; then
  export JVM_PLATFORM=macosx

  export thecc="$(xcrun -find -sdk iphoneos clang)"
  export thecxx="$(xcrun -find -sdk iphoneos clang++)"
  export thesysroot="$(xcrun --sdk iphoneos --show-sdk-path)"
  export themacsysroot="$(xcrun --sdk macosx --show-sdk-path)"

  export thehostcxx="$PWD/macos-host-cc"
  export CC="$PWD/ios-arm64-clang"
  export CXX="$PWD/ios-arm64-clang++"
  export CXXCPP="$CXX -E"
  export LD="$(xcrun -find -sdk iphoneos ld)"

  export HOTSPOT_DISABLE_DTRACE_PROBES=1
  export ANDROID_INCLUDE="$PWD/ios-missing-include"
else
  export JVM_PLATFORM=linux
  export API=21

  if [[ -z "${ANDROID_NDK_HOME:-}" ]]; then
    export ANDROID_NDK_HOME="$PWD/android-ndk-$NDK_VERSION"
  fi

  export TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"
  export ANDROID_INCLUDE="$TOOLCHAIN/sysroot/usr/include"

  export CPPFLAGS=""
  export LDFLAGS=""

  export thecc="$TOOLCHAIN/bin/${TARGET}${API}-clang"
  export thecxx="$TOOLCHAIN/bin/${TARGET}${API}-clang++"

  export AR="$TOOLCHAIN/bin/llvm-ar"
  export AS="$TOOLCHAIN/bin/llvm-as"
  export CC="$PWD/android-wrapped-clang"
  export CXX="$PWD/android-wrapped-clang++"
  export LD="$TOOLCHAIN/bin/ld"
  export OBJCOPY="$TOOLCHAIN/bin/llvm-objcopy"
  export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
  export STRIP="$TOOLCHAIN/bin/llvm-strip"
fi
