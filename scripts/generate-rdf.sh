#!/usr/bin/env bash
# Generate and verify the derived DCAT 3 RDF serializations.
set -euo pipefail

# Allow CI or a local installation to provide the Apache Jena commands.
RIOT="${RIOT:-riot}"
RDFCOMPARE="${RDFCOMPARE:-rdfcompare}"
# Accept an optional source and output directory for local testing.
SOURCE="${1:-TR/rdf/dcat3.ttl}"
OUTPUT_DIR="${2:-TR/rdf}"

# Fail clearly instead of producing empty derived files when the source is absent.
if [[ ! -f "$SOURCE" ]]; then
  echo "Source file not found: $SOURCE" >&2
  exit 1
fi

# Ensure the destination exists before writing the generated files.
mkdir -p "$OUTPUT_DIR"
# Validate the canonical Turtle source before converting it.
"$RIOT" --validate "$SOURCE"
# Generate the two machine-readable formats served by the publication site.
"$RIOT" --output=JSONLD "$SOURCE" > "$OUTPUT_DIR/dcat3.jsonld"
"$RIOT" --output=RDFXML "$SOURCE" > "$OUTPUT_DIR/dcat3.rdf"

# Validate both generated files so malformed output cannot be published.
"$RIOT" --validate "$OUTPUT_DIR/dcat3.jsonld"
"$RIOT" --validate "$OUTPUT_DIR/dcat3.rdf"

# Compare graphs, not serialized text, so ordering and blank-node labels do
# not create false differences.
"$RDFCOMPARE" "$SOURCE" "$OUTPUT_DIR/dcat3.jsonld" TURTLE JSON-LD
"$RDFCOMPARE" "$SOURCE" "$OUTPUT_DIR/dcat3.rdf" TURTLE RDF/XML
