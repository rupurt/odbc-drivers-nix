# syntax = docker/dockerfile:1.4
FROM nixos/nix:latest AS builder
WORKDIR /tmp/build
RUN mkdir /tmp/output
RUN mkdir /tmp/nix-store-closure
COPY flake.lock flake.lock
COPY flake.nix flake.nix
COPY packages packages
# CI copies nix config for cachix & gha magic cache
COPY ./*.config/nix /root/.config/nix
COPY ./*.config/cachix /root/.config/cachix
# db2-odbc-driver
RUN \
  --mount=type=cache,target=/nix,from=nixos/nix:latest,source=/nix \
  --mount=type=cache,target=/root/.cache \
  --mount=type=bind,target=/tmp/build \
  <<EOF
  nix \
    --extra-experimental-features "nix-command flakes" \
    --option filter-syscalls false \
    --show-trace \
    --log-format raw \
    build .#db2-odbc-driver --out-link /tmp/output/db2-odbc-driver
  cp -R $(nix-store -qR /tmp/output/db2-odbc-driver) /tmp/nix-store-closure
EOF

# postgres-odbc-driver
RUN \
  --mount=type=cache,target=/nix,from=nixos/nix:latest,source=/nix \
  --mount=type=cache,target=/root/.cache \
  --mount=type=bind,target=/tmp/build \
  <<EOF
  nix \
    --extra-experimental-features "nix-command flakes" \
    --option filter-syscalls false \
    --show-trace \
    --log-format raw \
    build .#postgres-odbc-driver --out-link /tmp/output/postgres-odbc-driver
  cp -R $(nix-store -qR /tmp/output/postgres-odbc-driver) /tmp/nix-store-closure
EOF

FROM alpine
WORKDIR /app
COPY --from=builder /tmp/nix-store-closure /nix/store
COPY --from=builder /tmp/output/ /app/
