#!/usr/bin/env bash
set -euo pipefail

# Cross-platform vcpkg -> raw export -> nuget pack from a template.
# Works in Git Bash on Windows, and on macOS/Linux shells.

# Inputs (env vars; sensible defaults provided):
# - REPO_URL          (required) Repository URL for metadata links
# - PORT_TRIPLET      (default: boost-test:x64-windows)
# - ID                (default: PORT_TRIPLET with ':' -> '-')
# - VERSION           (default: 1.0.${GITHUB_RUN_NUMBER:-0})
# - AUTHORS           (default: michaeltryby)
# - OWNERS            (default: michaeltryby)
# - DESC              (default: "Boost.Test built via vcpkg ($PORT_TRIPLET)")
# - VCPKG_DIR         (optional) Path to vcpkg directory. Auto-detected if not set.
#
# Optional Git metadata (auto-detected if not set):
# - GITHUB_REF_NAME
# - GITHUB_SHA

if [[ -z "${REPO_URL:-}" ]]; then
  echo "REPO_URL is required (e.g., https://github.com/michaeltryby/vcpkg-boost-example.git)" >&2
  exit 1
fi

PORT_TRIPLET="${PORT_TRIPLET:-boost-test:x64-windows}"
ID="${ID:-$(echo "$PORT_TRIPLET" | tr ':' '-')}"
AUTHORS="${AUTHORS:-michaeltryby}"
OWNERS="${OWNERS:-michaeltryby}"
DESC="${DESC:-Boost.Test built via vcpkg ($PORT_TRIPLET)}"
VERSION="${VERSION:-1.0.${GITHUB_RUN_NUMBER:-0}}"

# Resolve paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VCPKG_DIR="${VCPKG_DIR:-}"

# Auto-detect vcpkg location if not provided
if [[ -z "$VCPKG_DIR" ]]; then
    if [[ -f "./vcpkg" && -x "./vcpkg" ]] || [[ -f "./vcpkg.exe" ]]; then
    VCPKG_DIR="$(pwd)"
  else
    VCPKG_DIR="$REPO_ROOT/vcpkg"
  fi
fi

if [[ ! -d "$VCPKG_DIR" ]]; then
  echo "VCPKG_DIR does not exist: $VCPKG_DIR" >&2
  exit 1
fi

# Find vcpkg binary cross-platform
if [[ -x "$VCPKG_DIR/vcpkg" ]]; then
  VCPKG_BIN="$VCPKG_DIR/vcpkg"
elif [[ -f "$VCPKG_DIR/vcpkg.exe" ]]; then
  VCPKG_BIN="$VCPKG_DIR/vcpkg.exe"
else
  echo "vcpkg binary not found in $VCPKG_DIR. Did you bootstrap vcpkg?" >&2
  echo "Windows:   cmd //c \"cd $VCPKG_DIR && bootstrap-vcpkg.bat\"" >&2
  echo "macOS/Linux: $VCPKG_DIR/bootstrap-vcpkg.sh" >&2
  exit 1
fi

# Ensure nuget CLI is available
if ! command -v nuget >/dev/null 2>&1; then
  echo "nuget CLI not found. Install it first, e.g.:" >&2
  echo "  dotnet tool install -g NuGet.CommandLine" >&2
  echo "  export PATH=\"\$PATH:\$HOME/.dotnet/tools\"" >&2
  exit 1
fi

# Git metadata (helpful locally)
GITHUB_REF_NAME="${GITHUB_REF_NAME:-$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || true)}"
GITHUB_SHA="${GITHUB_SHA:-$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || true)}"

# 1) Install (idempotent)
"$VCPKG_BIN" install "$PORT_TRIPLET"

# 2) Export raw
EXPORT_DIR="$VCPKG_DIR/exported"
rm -rf "$EXPORT_DIR"
"$VCPKG_BIN" export "$PORT_TRIPLET" --raw --output "$EXPORT_DIR"
if [[ ! -d "$EXPORT_DIR" ]]; then
  echo "Export directory not found: $EXPORT_DIR" >&2
  exit 1
fi

# 3) nuget pack using template
NUSPEC="$SCRIPT_DIR/package.nuspec"
if [[ ! -f "$NUSPEC" ]]; then
  echo "nuspec template not found: $NUSPEC" >&2
  exit 1
fi

PROPS="id=$ID;authors=$AUTHORS;owners=$OWNERS;description=$DESC;repositoryUrl=$REPO_URL;repoBranch=$GITHUB_REF_NAME;repoCommit=$GITHUB_SHA"

# Output goes to VCPKG_DIR so it matches CI behavior
nuget pack "$NUSPEC" \
  -BasePath "$EXPORT_DIR" \
  -OutputDirectory "$VCPKG_DIR" \
  -Version "$VERSION" \
  -Properties "$PROPS"

PKG="$VCPKG_DIR/$ID.$VERSION.nupkg"
if [[ ! -f "$PKG" ]]; then
  # Fallback: most recent nupkg in VCPKG_DIR
  PKG="$(ls -1t "$VCPKG_DIR"/*.nupkg 2>/dev/null | head -n1 || true)"
fi

if [[ -z "${PKG:-}" || ! -f "$PKG" ]]; then
  echo "No .nupkg produced." >&2
  exit 1
fi


# Move package to upload directory
UPLOAD_DIR="$REPO_ROOT/upload"
mkdir -p "$UPLOAD_DIR"

UPLOAD_PKG="$UPLOAD_DIR/$(basename "$PKG")"
mv "$PKG" "$UPLOAD_PKG"

echo "Package moved to: $UPLOAD_PKG"


# If running in Actions, expose PACKAGE to later steps
if [[ -n "${GITHUB_ENV:-}" ]]; then
  echo "PACKAGE=upload/$(basename "$PKG")" >> "$GITHUB_ENV"
fi

echo "Produced package: $PKG"
