# Java 25 iOS Porting Status

This repository now contains a first-pass `jdk25u` iOS patch set and can check
that patch against a fresh `openjdk/jdk25u` checkout.

## Current blocker

The remaining blocker is a real macOS/Xcode build and runtime validation. This
Windows workspace can port and verify patches, but it cannot produce the final
iOS OpenJDK artifact locally.

## What was verified

- Base repository used: PojavLauncherTeam `buildjre17-21`
- Upstream source tested against: `openjdk/jdk25u`
- Result: the Java 21 iOS patch does not apply cleanly to Java 25
- Result: `patches/jre_25/ios/jdk25u_ios.diff` now exists
- Result: `./probe_jdk25_patch.sh` applies that patch cleanly to a fresh `jdk25u` clone

## Files that already map cleanly as new additions

- `src/hotspot/os_cpu/bsd_aarch64/tcg-apple-jit.h`
- `src/java.base/macosx/native/libjava/OSXSCSchemaDefinitions.h`
- `src/java.desktop/macosx/native/libjsound/PLATFORM_API_iPhoneOS_Permission.m`
- `src/java.desktop/unix/native/common/java2d/opengl/sun_java2d_opengl_GLXGraphicsConfig.h`

## Files ported into `jdk25u_ios.diff`

- `make/autoconf/buildjdk-spec.gmk.template`
- `make/autoconf/flags-cflags.m4`
- `make/autoconf/flags-ldflags.m4`
- `make/autoconf/flags-other.m4`
- `make/autoconf/platform.m4`
- `make/common/modules/LauncherCommon.gmk`
- `make/modules/java.base/Lib.gmk`
- `make/modules/java.base/lib/CoreLibraries.gmk`
- `make/modules/java.desktop/Gensrc.gmk`
- `make/modules/java.desktop/Java.gmk`
- `make/modules/java.desktop/Lib.gmk`
- `make/modules/java.desktop/gensrc/GensrcIcons.gmk`
- `make/modules/java.instrument/Lib.gmk`
- `make/modules/java.security.jgss/Lib.gmk`
- `make/modules/jdk.hotspot.agent/Gensrc.gmk`
- `make/modules/jdk.hotspot.agent/Lib.gmk`
- `make/modules/jdk.jpackage/Lib.gmk`
- `src/hotspot/os/bsd/gc/z/zPhysicalMemoryBacking_bsd.cpp`
- `src/hotspot/os/bsd/os_bsd.cpp`
- `src/hotspot/os/bsd/os_bsd.hpp`
- `src/hotspot/os/posix/signals_posix.cpp`
- `src/hotspot/os_cpu/bsd_aarch64/icache_bsd_aarch64.hpp`
- `src/hotspot/os_cpu/bsd_aarch64/os_bsd_aarch64.cpp`
- `src/java.base/macosx/native/libjava/java_props_macosx.c`
- `src/java.base/macosx/native/libnet/DefaultProxySelector.c`
- `src/java.desktop/macosx/native/libjawt/jawt.m`
- `src/java.desktop/macosx/native/libjsound/PLATFORM_API_MacOSX_PCM.cpp`
- `src/java.desktop/unix/native/common/awt/fontpath.c`
- `src/java.desktop/unix/native/libawt/awt/awt_LoadLibrary.c`

## Upstream layout changes seen in Java 25

- `make/autoconf/buildjdk-spec.gmk.in` became `make/autoconf/buildjdk-spec.gmk.template`
- `make/modules/java.desktop/lib/Awt2dLibraries.gmk` is no longer present at the old path
- `src/hotspot/os/bsd/gc/x/xPhysicalMemoryBacking_bsd.cpp` is no longer present at the old path

## Remaining risk

The patch now applies cleanly, but it has not yet been compiled or smoke-tested
on macOS with Xcode and the iPhoneOS SDK.
