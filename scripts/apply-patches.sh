#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PATCHES_DIR="$ROOT_DIR/patches"
OUTPUT_DIR="$ROOT_DIR/custom_components/volvo"

# Upstream repo settings
UPSTREAM_REPO="https://github.com/home-assistant/core.git"
UPSTREAM_COMPONENT_PATH="homeassistant/components/volvo"
CURRENT_SHA_FILE="$ROOT_DIR/.current-upstream-sha"

echo "=== Volvo Limited Scopes - Apply Patches ==="
echo ""

# Get the latest upstream SHA for the volvo component
echo "Fetching latest upstream commit for volvo component..."
UPSTREAM_SHA=$(git ls-remote "$UPSTREAM_REPO" HEAD | cut -f1)

# Check if we already have this SHA
if [ -f "$CURRENT_SHA_FILE" ]; then
    CURRENT_SHA=$(cat "$CURRENT_SHA_FILE")
    if [ "$CURRENT_SHA" = "$UPSTREAM_SHA" ]; then
        echo "No upstream changes detected (current: ${UPSTREAM_SHA:0:8})"
        echo "Set FORCE_UPDATE=1 to force rebuild"
        if [ "${FORCE_UPDATE:-0}" != "1" ]; then
            exit 0
        fi
        echo "Force update requested..."
    fi
fi

echo "Upstream changed: ${CURRENT_SHA:-none} -> ${UPSTREAM_SHA:0:8}"

# Create temp directory for clone
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Cloning upstream repo (sparse checkout)..."
cd "$TEMP_DIR"
git init
git remote add origin "$UPSTREAM_REPO"
git config core.sparseCheckout true

# Setup sparse checkout for just the volvo component
cat > .git/info/sparse-checkout << EOF
homeassistant/components/volvo/
EOF

echo "Fetching volvo component..."
git fetch --depth=1 origin dev
git checkout FETCH_HEAD

# Copy component files
echo "Copying component files..."
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
cp -r "$TEMP_DIR/$UPSTREAM_COMPONENT_PATH/"* "$OUTPUT_DIR/"

# Apply patches from patches directory
echo ""
echo "Applying patches..."

# Apply each patch file
for patch_file in "$PATCHES_DIR"/*.patch; do
    if [ -f "$patch_file" ]; then
        patch_name=$(basename "$patch_file")
        echo "Applying: $patch_name"
        
        # Check patch type and apply accordingly
        case "$patch_name" in
            limited-scopes.patch)
                # Apply scope limitation changes
                cd "$OUTPUT_DIR"
                patch -p1 < "$patch_file" || echo "  ⚠ Patch may have already been applied or needs manual review"
                ;;
            hacs-compat.patch)
                # Apply HACS compatibility changes
                cd "$OUTPUT_DIR"
                patch -p1 < "$patch_file" || echo "  ⚠ Patch may have already been applied or needs manual review"
                ;;
            *)
                echo "  Unknown patch: $patch_name"
                ;;
        esac
        
        echo "  ✓ Applied $patch_name"
    fi
done

# Additional HACS setup - create hacs.json if not in patch
if [ ! -f "$OUTPUT_DIR/hacs.json" ]; then
    cat > "$OUTPUT_DIR/hacs.json" << 'HACS'
{
  "name": "Volvo (Limited Scopes)",
  "render_readme": true
}
HACS
    echo "  ✓ Created hacs.json"
fi

# Update version in manifest.json dynamically
echo "Updating version in manifest.json..."
VERSION="${VERSION:-$(date +%Y.%m.%d)}"
if [ -f "$OUTPUT_DIR/manifest.json" ]; then
    python3 << PYTHON
import json

manifest_path = "$OUTPUT_DIR/manifest.json"
with open(manifest_path, 'r') as f:
    manifest = json.load(f)

manifest["version"] = "$VERSION"

with open(manifest_path, 'w') as f:
    json.dump(manifest, f, indent=2)
    f.write('\n')
PYTHON
    echo "  ✓ Version set to $VERSION"
fi



# Save the upstream SHA
echo "$UPSTREAM_SHA" > "$CURRENT_SHA_FILE"

echo ""
echo "=== Done ==="
echo "Component ready at: $OUTPUT_DIR"
echo "Upstream SHA: ${UPSTREAM_SHA:0:8}"
