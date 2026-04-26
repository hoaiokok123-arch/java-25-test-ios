# java-25-test-ios

This repository is a working base for porting the PojavLauncher iOS OpenJDK
build from Java 21 to Java 25.

## Current state

- The build scripts now target `openjdk/jdk25u` by default.
- The GitHub Actions workflow is narrowed to a manual iOS Java 25 build job.
- A first-pass `patches/jre_25/ios/jdk25u_ios.diff` now exists.
- `./probe_jdk25_patch.sh` applies that patch cleanly to a fresh `openjdk/jdk25u` clone.
- A real Java 25 iOS runtime is still blocked by missing macOS/Xcode build validation.
- See [PORTING_STATUS.md](PORTING_STATUS.md) for the exact files that still need to be migrated from the Java 21 patch set.

## Requirements

- macOS with Xcode and the iPhoneOS SDK
- Homebrew packages used by the current flow:
  - `fontconfig`
  - `ldid`
  - `xquartz`
  - `autoconf`
- A Java 25 boot JDK visible to `/usr/libexec/java_home -v 25`

## Platform and architecture variables

<table>
  <thead>
    <tr>
      <th>Platform - Architecture</th>
      <th align="center">TARGET</th>
      <th align="center">TARGET_JDK</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>iOS/iPadOS - armv8/aarch64</td>
      <td align="center">aarch64-apple-ios</td>
      <td align="center">aarch64</td>
    </tr>
  </tbody>
</table>

## Local run

```bash
export BUILD_IOS=1
export TARGET_VERSION=25
export BUILD_FREETYPE_VERSION=2.10.0
export JDK_DEBUG_LEVEL=release
export JVM_VARIANTS=server

./3_getlibs.sh
./4_buildlibs.sh
./5_clonejdk.sh
./6_buildjdk.sh
./7_removejdkdebuginfo.sh
./8_tarjdk.sh
```

## Important

- This repository is not yet proven end-to-end on a real macOS builder.
- The patch port now exists; the next step is compiling it on macOS/Xcode and fixing any compile/runtime regressions.
- `probe_jdk25_patch.sh` is the quick local check that the patch still applies cleanly upstream.
