#!/usr/bin/env bash
set -euo pipefail

docker build -t nix:ubuntu -f nix-ubuntu.Dockerfile .

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
