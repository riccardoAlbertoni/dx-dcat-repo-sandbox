#!/usr/bin/env bash
# Prepare the Jekyll source tree and generate derived DCAT 3 serializations.
set -euo pipefail

# Resolve paths from the script location so the command works from any directory.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="${1:-"$ROOT/.pages-source"}"
RIOT="${RIOT:-riot}"

# Rebuild from scratch to avoid stale files from an earlier publication.
rm -rf "$DIST"
mkdir -p "$DIST"

# Copy the complete site while excluding build output and stale RDF files.
# The generated files are recreated below from the canonical Turtle source.
tar \
  --exclude='./.git' \
  --exclude='./.DS_Store' \
  --exclude='./_site' \
  --exclude='./.pages-source' \
  --exclude='./TR/rdf/dcat3.jsonld' \
  --exclude='./TR/rdf/dcat3.rdf' \
  -cf - -C "$ROOT" . | tar -xf - -C "$DIST"

# Generate JSON-LD and RDF/XML inside the publication directory.
RIOT="$RIOT" "$ROOT/scripts/generate-rdf.sh" \
  "$DIST/TR/rdf/dcat3.ttl" \
  "$DIST/TR/rdf"

# Report the directory to pass to the Jekyll build.
echo "Jekyll source prepared at $DIST"
