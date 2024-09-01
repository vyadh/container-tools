# Container Tools

Container tooling installs using [the Nix package manager](https://nix.dev).

> Nix is a powerful package manager for Linux and other Unix systems that makes
> package management reliable and reproducible. It provides atomic upgrades and
> rollbacks, side-by-side installation of multiple versions of a package, multi-user
> package management and easy setup of build environments. 

Nix is a good choice for installing container tools because:
1. It has a large selection of packages available.
2. While not a trivial to setup, it makes it much easier to add new packages to
install when they are not available through standard apt sources.
3. It provides a convenient and visible way of managing tooling updates.

The [recommended way](https://nix.dev/tutorials/nixos/building-and-running-docker-images.html)
to create images with Nix is to use a `docker load` approach. However, this requires
Nix be installed outside a container. This is not always possible or desirable.
The approach here copies the Nix store into the container instead. The main disadvantage
of this approach is less effective caching of layers. It's likely possible to mitigate
this, but we're starting simple.

## Prequisites

Docker and `jq` to build/test the container images.
Install manually or install [Devbox](https://www.jetify.com/devbox) and type `devbox shell`
to install the dependencies.

## Usage

See [`build.sh`](build.sh) for example of how to build and run the container images.

There are currently three different types of images:
- [`alpine.Dockerfile`](alpine.Dockerfile) using the standard Nix base container image
- [`scratch.Dockerfile`](scratch.Dockerfile) using a "no distro" scratch image and Busybox
- [`ubuntu.Dockerfile`](ubuntu.Dockerfile) using an Ubuntu-based base image [`nix-ubuntu.Dockerfile`](nix-ubuntu.Dockerfile)

The packages to install are defined in [`flake.nix`](flake.nix).
