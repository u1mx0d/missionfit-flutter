#!/usr/bin/env bash
# Her görevin sonunda çalışır: biçim, analiz, testler ve domain katmanının saf kalması.
set -euo pipefail
cd "$(dirname "$0")/.."

dart format --line-length 100 --set-exit-if-changed lib test
flutter analyze
flutter test

if grep -rnE "package:(flutter|drift|supabase|supabase_flutter)" lib/domain 2>/dev/null; then
  echo "HATA: lib/domain Flutter/drift/Supabase import etmemeli." >&2
  exit 1
fi
echo "check: tamam"
