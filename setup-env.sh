#!/usr/bin/env bash

dpkg_add_arch() {
    dpkg --add-architecture $1
    apt-get update
    apt-get --no-install-recommends install --yes \
        gcc-12-multilib-$2-linux-gnu \
        gcc-$2-linux-gnu
}

# mind the space between the [ and "
if [[ "$BUILDPLATFORM" != "$TARGETPLATFORM" ]]; then
    case $TARGET in
        x86_64-unknown-linux-musl)
            dpkg_add_arch "amd64" "i686"
            ;;
        aarch64-unknown-linux-musl)
            dpkg_add_arch "arm64" "aarch64"
            ;;
        *)
            echo "INVALID CONFIGURATION"
            exit 1
            ;;
    esac
fi

