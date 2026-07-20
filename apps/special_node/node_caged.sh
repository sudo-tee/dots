#!/usr/bin/env bash
set -euo pipefail

IMAGE="platformatic/node-caged"
TAG="${1:-latest}"
WORKDIR="$(pwd)/node-caged-extract"
ARCHIVE="$WORKDIR/image.tar"
ROOTFS="$WORKDIR/rootfs"

echo "==> Preparing workspace..."
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"

# Check dependencies
for cmd in skopeo jq tar; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing dependency: $cmd"
    echo "Install with: sudo apt install skopeo jq"
    exit 1
  fi
done

echo "==> Downloading image $IMAGE:$TAG ..."
skopeo copy \
  "docker://$IMAGE:$TAG" \
  "docker-archive:$ARCHIVE"

echo "==> Extracting archive..."
cd "$WORKDIR"
tar -xf image.tar

echo "==> Reconstructing filesystem layers..."
mkdir -p "$ROOTFS"

jq -r '.[0].Layers[]' manifest.json | while read -r layer; do
  tar -xf "$layer" -C "$ROOTFS"
done

echo "==> Searching for Node binary..."
NODE_PATH=""

if [ -f "$ROOTFS/usr/local/bin/node" ]; then
  NODE_PATH="$ROOTFS/usr/local/bin/node"
elif [ -f "$ROOTFS/usr/bin/node" ]; then
  NODE_PATH="$ROOTFS/usr/bin/node"
else
  NODE_PATH=$(find "$ROOTFS" -type f -name node | head -n 1 || true)
fi

if [ -z "$NODE_PATH" ]; then
  echo "Node binary not found."
  exit 1
fi

echo "==> Found Node at: $NODE_PATH"

cp "$NODE_PATH" "$WORKDIR/node-caged-node"
chmod +x "$WORKDIR/node-caged-node"

echo "==> Node version inside image:"
"$WORKDIR/node-caged-node" -v || true

echo
echo "Done."
echo "Extracted binary:"
echo "  $WORKDIR/node-caged-node"
