#!/bin/bash
# https://github.com/termux/termux-packages/blob/master/disabled-packages/openjdk-9-jre-headless/build.sh
set -e

. setdevkitpath.sh

download() {
  local url="$1"
  local out="$2"
  if command -v wget >/dev/null 2>&1; then
    wget -O "$out" "$url"
  else
    curl -L "$url" -o "$out"
  fi
}

download "https://downloads.sourceforge.net/project/freetype/freetype2/$BUILD_FREETYPE_VERSION/freetype-$BUILD_FREETYPE_VERSION.tar.gz" \
  "freetype-$BUILD_FREETYPE_VERSION.tar.gz"
tar xf freetype-$BUILD_FREETYPE_VERSION.tar.gz
download "https://github.com/apple/cups/releases/download/v2.2.4/cups-2.2.4-source.tar.gz" \
  "cups-2.2.4-source.tar.gz"
tar xf cups-2.2.4-source.tar.gz
rm cups-2.2.4-source.tar.gz freetype-$BUILD_FREETYPE_VERSION.tar.gz
