#!/bin/bash
set -euo pipefail

. setdevkitpath.sh

AUTOCONF_EXTRA_ARGS="${AUTOCONF_EXTRA_ARGS:-}"
devkit_arg=""

export FREETYPE_DIR="$PWD/freetype-$BUILD_FREETYPE_VERSION/build_android-$TARGET_SHORT"
export CUPS_DIR="$PWD/cups-2.2.4"
export CFLAGS+=" -DLE_STANDALONE"

if [[ "${TARGET_JDK}" == "arm" ]]; then
  export CFLAGS+=" -O3 -D__thumb__"
elif [[ "${TARGET_JDK}" == "x86" ]]; then
  export CFLAGS+=" -O3 -mstackrealign"
else
  export CFLAGS+=" -O3"
fi

if [[ "${BUILD_IOS:-0}" != "1" ]]; then
  chmod +x android-wrapped-clang android-wrapped-clang++
  ln -s -f /usr/include/X11 "$ANDROID_INCLUDE/"
  ln -s -f /usr/include/fontconfig "$ANDROID_INCLUDE/"

  platform_args="--with-toolchain-type=gcc \
--with-freetype-include=$FREETYPE_DIR/include/freetype2 \
--with-freetype-lib=$FREETYPE_DIR/lib \
OBJCOPY=${OBJCOPY} \
RANLIB=${RANLIB} \
AR=${AR} \
STRIP=${STRIP}"
  devkit_arg="--with-devkit=$TOOLCHAIN"

  if [[ "${TARGET_VERSION}" -eq 21 ]]; then
    platform_args="--build=x86_64-unknown-linux-gnu ${platform_args}"
  fi

  AUTOCONF_x11arg="--x-includes=$ANDROID_INCLUDE/X11"
  export CFLAGS+=" -mllvm -polly -DANDROID -Wno-error=implicit-function-declaration -Wno-error=int-conversion"
  export LDFLAGS+=" -L$PWD/dummy_libs -Wl,--undefined-version"

  mkdir -p dummy_libs
  ar cru dummy_libs/libpthread.a
  ar cru dummy_libs/librt.a
  ar cru dummy_libs/libthread_db.a
else
  ln -s -f /opt/X11/include/X11 "$ANDROID_INCLUDE/"
  ln -sfn "$themacsysroot/System/Library/Frameworks/CoreAudio.framework/Headers" "$ANDROID_INCLUDE/CoreAudio"
  ln -sfn "$themacsysroot/System/Library/Frameworks/IOKit.framework/Headers" "$ANDROID_INCLUDE/IOKit"

  if [[ "$(uname -p)" == "arm" ]]; then
    ln -s -f /opt/homebrew/include/fontconfig "$ANDROID_INCLUDE/"
  else
    ln -s -f /usr/local/include/fontconfig "$ANDROID_INCLUDE/"
  fi

  platform_args="--with-toolchain-type=clang \
--with-sysroot=$(xcrun --sdk iphoneos --show-sdk-path) \
--with-boot-jdk=$(/usr/libexec/java_home -v $TARGET_VERSION) \
--with-freetype=bundled"
  AUTOCONF_x11arg="--with-x=/opt/X11/include/X11 --prefix=/usr/lib"
  export CFLAGS+=" -arch arm64 -DHEADLESS=1 -I$PWD/ios-missing-include -Wno-implicit-function-declaration -DTARGET_OS_OSX"
  export LDFLAGS+="-arch arm64"
  export BUILD_SYSROOT_CFLAGS="-isysroot ${themacsysroot}"

  HOMEBREW_NO_AUTO_UPDATE=1 brew install fontconfig ldid xquartz autoconf
fi

ln -s -f "$CUPS_DIR/cups" "$ANDROID_INCLUDE/"

cd "openjdk-${TARGET_VERSION}"
git reset --hard

if [[ "${BUILD_IOS:-0}" != "1" ]]; then
  find "../patches/jre_${TARGET_VERSION}/android" -name "*.diff" -print0 | \
    xargs -0 -I {} sh -c 'echo "Applying {}" && git apply --reject --whitespace=fix "{}" || (echo "git apply failed (Android patch set)" && exit 1)'
else
  if [[ ! -d "../patches/jre_${TARGET_VERSION}/ios" ]]; then
    echo "Missing patch directory: patches/jre_${TARGET_VERSION}/ios"
    echo "For Java ${TARGET_VERSION} on iOS, the OpenJDK iOS patch set must be ported first."
    exit 2
  fi

  if ! find "../patches/jre_${TARGET_VERSION}/ios" -name "*.diff" | grep -q .; then
    echo "No iOS patch files found in patches/jre_${TARGET_VERSION}/ios"
    echo "For Java ${TARGET_VERSION} on iOS, add a ported jdk${TARGET_VERSION}u_ios.diff first."
    exit 2
  fi

  find "../patches/jre_${TARGET_VERSION}/ios" -name "*.diff" -print0 | \
    xargs -0 -I {} sh -c 'echo "Applying {}" && git apply --reject --whitespace=fix "{}" || (echo "git apply failed (iOS patch set)" && exit 1)'

  desktop_mac="src/java.desktop/macosx"
  mv "${desktop_mac}" "${desktop_mac}_NOTIOS"
  mkdir -p "${desktop_mac}/native"
  mv "${desktop_mac}_NOTIOS/native/libjsound" "${desktop_mac}/native/"
fi

if ! bash ./configure \
  --openjdk-target="$TARGET" \
  --with-extra-cflags="$CFLAGS" \
  --with-extra-cxxflags="$CFLAGS" \
  --with-extra-ldflags="$LDFLAGS" \
  --disable-precompiled-headers \
  --disable-warnings-as-errors \
  --enable-option-checking=fatal \
  --enable-headless-only=yes \
  --with-jvm-variants="$JVM_VARIANTS" \
  --with-jvm-features=-dtrace,-zero,-vm-structs,-epsilongc \
  --with-cups-include="$CUPS_DIR" \
  $devkit_arg \
  --with-native-debug-symbols=external \
  --with-debug-level="$JDK_DEBUG_LEVEL" \
  --with-fontconfig-include="$ANDROID_INCLUDE" \
  $AUTOCONF_x11arg $AUTOCONF_EXTRA_ARGS \
  --x-libraries=/usr/lib \
  $platform_args; then
  error_code=$?
  echo "\n\nCONFIGURE ERROR ${error_code}, config.log:"
  cat config.log
  exit "${error_code}"
fi

if [[ "${BUILD_IOS:-0}" == "1" ]]; then
  jobs="$(sysctl -n hw.ncpu)"
else
  jobs="$(nproc)"
fi

echo "Running ${jobs} jobs to build the jdk"

cd "build/${JVM_PLATFORM}-${TARGET_JDK}-${JVM_VARIANTS}-${JDK_DEBUG_LEVEL}"
if ! make JOBS="$jobs" images; then
  error_code=$?
  echo "Build failure, exited with code ${error_code}. Trying again."
  make JOBS="$jobs" images
fi
