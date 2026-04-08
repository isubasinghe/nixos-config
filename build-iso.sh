#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "==> Step 1/2: Bundling personal data..."
bash ./bundle-data.sh ./data-bundle.tar.gz

echo ""
echo "==> Step 2/2: Building NixOS ISO..."
nix build .#nixosConfigurations.iso.config.system.build.isoImage

ISO=$(ls result/iso/*.iso)
SIZE=$(du -sh "$ISO" | cut -f1)
echo ""
echo "==> Done!"
echo "    ISO: $ISO ($SIZE)"
echo "    Flash with: sudo dd if=$ISO of=/dev/sdX bs=4M status=progress conv=fsync"
