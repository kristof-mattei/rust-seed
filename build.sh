#!/bin/sh

# static linking
flags="-Clink-self-contained=yes "

# mind the space between the [ and "
if [ "$BUILDPLATFORM" = "$TARGETPLATFORM" ]; then
    # default
    cargo $@
else
    flags="$flags -Clinker=rust-lld"

    CC_aarch64_unknown_linux_musl="clang" AR_aarch64_unknown_linux_musl="llvm-ar" RUSTFLAGS=$flags cargo $@
fi
