FROM --platform=${BUILDPLATFORM} rust:1.87.0-alpine AS rust-base

ARG APPLICATION_NAME

# note that we don't do `--no-cache`. We want to keep the caches, as we do multi-stage build
RUN apk update && apk add make clang llvm perl

FROM rust-base AS rust-linux-amd64
ARG TARGET=x86_64-unknown-linux-musl

FROM rust-base AS rust-linux-arm64
ARG TARGET=aarch64-unknown-linux-musl

ENV CC_aarch64_unknown_linux_musl="clang"
ENV AR_aarch64_unknown_linux_musl="llvm-ar"

FROM rust-${TARGETPLATFORM//\//-} AS rust-cargo-build

RUN rustup target add ${TARGET}

# The following block
# creates an empty app, and we copy in Cargo.toml and Cargo.lock as they represent our dependencies
# This allows us to copy in the source in a different layer which in turn allows us to leverage Docker's layer caching
# That means that if our dependencies don't change rebuilding is much faster
WORKDIR /build
RUN cargo new ${APPLICATION_NAME}
WORKDIR /build/${APPLICATION_NAME}
COPY .cargo ./.cargo
COPY Cargo.toml Cargo.lock ./

RUN --mount=type=cache,target=/build/${APPLICATION_NAME}/target \
    --mount=type=cache,id=cargo-git,target=/usr/local/cargo/git/db,sharing=locked \
    --mount=type=cache,id=cargo-registery,target=/usr/local/cargo/registry/,sharing=locked \
    cargo build --release --target ${TARGET}

FROM rust-cargo-build AS rust-build

WORKDIR /build/${APPLICATION_NAME}

# now we copy in the source which is more prone to changes and build it
COPY src ./src

# ensure cargo picks up on the change
RUN touch ./src/main.rs

# --release not needed, it is implied with install
RUN --mount=type=cache,target=/build/${APPLICATION_NAME}/target \
    --mount=type=cache,id=cargo-git,target=/usr/local/cargo/git/db,sharing=locked \
    --mount=type=cache,id=cargo-registery,target=/usr/local/cargo/registry/,sharing=locked \
    cargo install --path . --target ${TARGET} --root /output

FROM --platform=${BUILDPLATFORM} alpine:3.21.3@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c AS passwd-build

# setting `--system` prevents prompting for a password
RUN addgroup --gid 900 appgroup \
    && adduser --ingroup appgroup --uid 900 --system --shell /bin/false appuser

RUN cat /etc/group | grep appuser > /tmp/group_appuser
RUN cat /etc/passwd | grep appuser > /tmp/passwd_appuser

FROM scratch

ARG APPLICATION_NAME

COPY --from=passwd-build /tmp/group_appuser /etc/group
COPY --from=passwd-build /tmp/passwd_appuser /etc/passwd

USER appuser

WORKDIR /app

COPY --from=rust-build /output/bin/${APPLICATION_NAME} /app/entrypoint

ENV RUST_BACKTRACE=full
ENTRYPOINT ["/app/entrypoint"]
