#!/bin/bash

set -eu -o pipefail

cargo_features="${CARGO_FEATURES:---all-features}"
grcov_output_types="${GRCOV_OUTPUT_TYPES:-lcov,html,markdown}"

export RUSTFLAGS="--allow=warnings -Cinstrument-coverage"

build() {
    # build-* ones are not parsed by grcov
    LLVM_PROFILE_FILE="profiling/build-%p-%m.profraw" \
        cargo build ${cargo_features} --all-targets --locked --workspace
}

run_tests() {
    # cleanup old values
    find . -name '*.profraw' -print0 | xargs --null --no-run-if-empty rm

    # different from the `cargo build` ones
    LLVM_PROFILE_FILE="profiling/profile-%p-%m.profraw" \
        cargo nextest run --profile ci --no-fail-fast ${cargo_features} --all-targets --workspace
}

report() {
    mapfile -t profraw_files < <(find . -name "profile-*.profraw" -print)

    grcov "${profraw_files[@]}" \
        --binary-path ./target/debug/ \
        --branch \
        --excl-br-line "^\s*((debug_)?assert(_eq|_ne)?!)" \
        --excl-br-start "mod tests \{" \
        --excl-line "(#\\[derive\\()|(^\s*.await[;,]?$)" \
        --excl-start "mod tests \{" \
        --ignore-not-existing \
        --keep-only "crates/**" \
        --llvm \
        --output-path ./reports/ \
        --output-type "${grcov_output_types}" \
        --source-dir .
}

case "${1:-all}" in
    build)
        build
        ;;
    test)
        run_tests
        ;;
    report)
        report
        ;;
    all)
        build

        test_exit_code=0
        run_tests || test_exit_code=$?

        report

        exit "${test_exit_code}"
        ;;
    *)
        echo "usage: $0 [build|test|report]" >&2
        exit 1
        ;;
esac
