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


# Setup a staticically-compiled busybox to use as a shell
FROM busybox:stable-uclibc AS basics
RUN addgroup -g 2001 apps
RUN adduser -u 1001 -g apps --disabled-password app

# Create an install of busybox here as our scratch image doesn't have a shell
# Install it as hard links to work better with security tools
RUN mkdir /tmp/busybox-bin && \
    busybox --install /tmp/busybox-bin


# Create a minimal runtime image
FROM scratch

# Copy the built environment from the previous stage
COPY --from=install /tmp/nix-requisites /nix/store
COPY --from=install /flake/result/ /usr/local/

# Super-mini Linux!
COPY --from=basics /tmp/busybox-bin /bin
COPY --from=basics /etc/passwd /etc/
COPY --from=basics /etc/group /etc/
USER app
CMD ["/bin/sh"]
