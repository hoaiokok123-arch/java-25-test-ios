#!/bin/bash
set -e

case "${TARGET_VERSION}" in
  17)
    git clone --depth 1 https://github.com/openjdk/jdk17u openjdk-17
    ;;
  21)
    git clone --branch jdk21.0.1 --depth 1 https://github.com/openjdk/jdk21u openjdk-21
    ;;
  25)
    git clone --depth 1 https://github.com/openjdk/jdk25u openjdk-25
    ;;
  *)
    echo "Unsupported TARGET_VERSION=${TARGET_VERSION}. Expected 17, 21, or 25."
    exit 1
    ;;
esac
