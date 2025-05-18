#!/usr/bin/env bash

# static linking
flags="-Clink-self-contained=yes -Clinker=rust-lld"

# replace - with _ in the Rust target
target_lower=${TARGET//-/_}

cc_var=CC_${target_lower}
declare -x "${cc_var}=clang"

RUSTFLAGS=$flags cargo $@
