#!/usr/bin/env bash

# static linking
flags="-Clink-self-contained=yes "

# mind the space between the [ and "
if [[ "$BUILDPLATFORM" != "$TARGETPLATFORM" ]]; then
    flags="$flags -Clinker=rust-lld"
fi

# replace - with _ in the Rust target
target_lower=${TARGET//-/_}

cc_var=CC_${target_lower}
declare -x "${cc_var}=clang"

ar_var=AR_${target_lower}
declare -x "${ar_var}=llvm-ar"

RUSTFLAGS=$flags cargo $@
