FROM rust:1-stretch as builder
# Choose a workdir
WORKDIR /usr/src/app
# Create blank project
RUN USER=root cargo init
# Copy Cargo.toml to get dependencies
COPY Cargo.toml .
# This is a dummy build to get the dependencies cached
RUN cargo build --release
# Copy sources
COPY src src
# Build app (bin will be in /usr/src/app/target/release/rust-lang-docker-multistage-build)
RUN cargo build --release

FROM debian:stretch-slim
# Copy bin from builder to this new image
COPY --from=builder /usr/src/app/target/release/rust-lang-docker-multistage-build /bin/
# Default command, run app
CMD rust-lang-docker-multistage-build