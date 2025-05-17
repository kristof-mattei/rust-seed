#!/usr/bin/env bash

# sane defaults
compiler="gcc"
# static linking
flags="-Clink-self-contained=yes -Clinker=rust-lld"

# mind the space between the [ and "
if [[ "$BUILDPLATFORM" != "$TARGETPLATFORM" ]]; then
    if [[ "$TARGETARCH" == "arm64" ]]; then
        compiler="aarch64-linux-gnu-gcc"
    fi
    # add amd64
fi

# replace - with _ in the Rust target
target_lower=${TARGET//-/_}
cc_var=CC_${target_lower}
declare -x "${cc_var}=${compiler}"

RUSTFLAGS=$flags cargo $@
