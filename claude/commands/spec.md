---
description: "Read spec file (default: ./tmp/spec.md, or specify path)"
---
$(
  SPEC_FILE="${1:-./tmp/spec.md}"
  echo "📍 Working directory: $(pwd)"
  echo "📋 Reading spec: $SPEC_FILE"
  echo "=================================="
  cat "$SPEC_FILE"
  echo "=================================="
)

Please implement the above specification.