#!/bin/bash
set -e
. setdevkitpath.sh

export JDK_DEBUG_LEVEL=release

if [[ "$BUILD_IOS" != "1" ]]; then
  if [[ -d "$ANDROID_NDK_HOME" ]]; then
    echo "NDK already exists: $ANDROID_NDK_HOME"
  else
    echo "Downloading NDK"
    wget -nc -nv -O android-ndk-$NDK_VERSION-linux-x86_64.zip "https://dl.google.com/android/repository/android-ndk-$NDK_VERSION-linux.zip"
    unzip -q android-ndk-$NDK_VERSION-linux-x86_64.zip
  fi
  cp devkit.info.${TARGET_SHORT} ${TOOLCHAIN}
else
  chmod +x ios-arm64-clang
  chmod +x ios-arm64-clang++
  chmod +x macos-host-cc
fi

# Some modifies to NDK to fix

# Only build the sources if they are not already present
if [ ! -d "cups-2.2.4" ]; then
  ./3_getlibs.sh
  ./4_buildlibs.sh
fi
./5_clonejdk.sh
./6_buildjdk.sh
./7_removejdkdebuginfo.sh
./8_tarjdk.sh
