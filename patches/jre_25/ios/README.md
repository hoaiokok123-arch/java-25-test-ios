This directory now contains `jdk25u_ios.diff`, a first-pass port of the Java 21
iOS patch set to `openjdk/jdk25u`.

Use `../../../probe_jdk25_patch.sh` to verify that the patch still applies
cleanly to a fresh upstream checkout.

The next step is validating an actual macOS/iPhoneOS build, not recreating the
patch file from scratch.
