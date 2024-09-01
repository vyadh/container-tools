#!/usr/bin/env bash
set -euo pipefail

# Query latest version of Nix (or more specifically and not ideally, the latest tag)
NIX_VERSION=$(curl -s https://api.github.com/repos/NixOS/nix/tags | jq -r '.[0].name')
echo "Nix version: $NIX_VERSION"

docker build -t nix:ubuntu -f nix-ubuntu.Dockerfile --build-arg NIX_VERSION="$NIX_VERSION" .

types=(alpine ubuntu scratch)

for type in "${types[@]}"; do
  echo "Building: $type"
  docker build -t "tools-$type" -f "$type.Dockerfile" .

  echo "Testing: $type"
  version_info=$(docker run --rm "tools-$type" kubectl version --client --output=json)
  version=$(echo "$version_info" | jq -r '.clientVersion.gitVersion')
  echo "kubectl version: $version"
  if [[ ! $version =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "kubectl version check failed"
    exit 1
  fi
done
