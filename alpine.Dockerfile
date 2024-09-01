FROM nixos/nix AS install

# Nix recommends but has not yet stablised the nix build interface
RUN mkdir -p /etc/nix && \
    echo "experimental-features = nix-command flakes" > /etc/nix/nix.conf

# Copy the flake into the image
WORKDIR /flake
COPY *.nix ./

# Build the Nix environment
RUN nix build

# Extract the subset of the Nix store need for our flake
RUN mkdir /tmp/nix-requisites && \
    cp --archive $(nix-store --query --requisites result) /tmp/nix-requisites


# Runtime image
# Note that Alpine symlinks the Busybox binaries, which may not work well with some security tools
FROM alpine

# Remove existing empty directories
RUN rm -rf /usr/local

# Copy the built environment from the previous stage
COPY --from=install /tmp/nix-requisites /nix/store
COPY --from=install /flake/result/ /usr/local/

# Super-mini Linux!
RUN addgroup -g 2001 apps
RUN adduser -u 1001 -g apps --disabled-password app
USER app
CMD ["/bin/sh"]
