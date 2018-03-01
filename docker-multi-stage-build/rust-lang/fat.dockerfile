FROM rust:1-stretch
# Choose a workdir
WORKDIR /usr/src/app
# Copy sources
COPY . .
# Build app (bin will be in /usr/src/app/target/release/rust-lang-docker-multistage-build)
RUN cargo build --release
# Default command, run app
CMD /usr/src/app/target/release/rust-lang-docker-multistage-build