# Ubuntu version to use
FROM ubuntu:noble AS ubuntu-base


# Official image is Alpine-based so we use a glibc-based nix image to avoid issues with musl
FROM nix:ubuntu AS install

# Nix recommends but has not yet stablised the nix build interface
RUN mkdir -p /etc/nix && \
    echo "experimental-features = nix-command flakes" > /etc/nix/nix.conf

# Configure Nix environment on login
RUN echo ". ~/.nix-profile/etc/profile.d/nix.sh" >>~/.profile

# Copy our package install flake into the image
WORKDIR /flake
COPY *.nix ./

# Install the Nix flake packages
RUN nix build

# Extract the subset of the Nix store we need for our flake
RUN mkdir /tmp/nix-requisites && \
    cp --archive $(nix-store --query --requisites result) /tmp/nix-requisites


# Runtime image
FROM ubuntu-base

# Remove existing empty directories
RUN rm -rf /usr/local

# Copy the built environment from the previous stage
COPY --from=install /tmp/nix-requisites /nix/store
COPY --from=install /flake/result/ /usr/local/

# Run as non-root by default
RUN groupadd -g 2001 apps
RUN useradd -u 1001 -g apps app
USER app
CMD ["/bin/sh"]
