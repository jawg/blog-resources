FROM debian:stretch-slim
# Copy bin from builder to this new image
COPY target/release/rust-lang-docker-multistage-build /bin/
# Default command, run app
CMD rust-lang-docker-multistage-build