#!/usr/bin/env bash
# Assemble the GitHub Pages site and generate derived DCAT 3 serializations.
set -euo pipefail

# Resolve paths from the script location so the command works from any directory.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="${1:-"$ROOT/_site"}"
RIOT="${RIOT:-riot}"

# Rebuild from scratch to avoid stale files from an earlier publication.
rm -rf "$DIST"
mkdir -p "$DIST"

# Copy the site while excluding source-control metadata and derived RDF.
# The generated files are recreated below from the canonical Turtle source.
tar \
  --exclude='./.git' \
  --exclude='./.DS_Store' \
  --exclude='./_site' \
  --exclude='./TR/rdf/dcat3.jsonld' \
  --exclude='./TR/rdf/dcat3.rdf' \
  -cf - -C "$ROOT" . | tar -xf - -C "$DIST"

# Generate JSON-LD and RDF/XML inside the publication directory.
RIOT="$RIOT" "$ROOT/scripts/generate-rdf.sh" \
  "$DIST/TR/rdf/dcat3.ttl" \
  "$DIST/TR/rdf"

# Report the directory that can be uploaded or served locally.
echo "Publication site built at $DIST"
