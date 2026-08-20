#!/bin/bash

set -euo pipefail

repository_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repository_root"

if [[ -z "${DEVELOPER_DIR:-}" ]]; then
  if [[ -d /Applications/Xcode_26.6.app/Contents/Developer ]]; then
    export DEVELOPER_DIR=/Applications/Xcode_26.6.app/Contents/Developer
  else
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
  fi
fi

mkdir -p .build

xcrun docc convert ObjectTracking.docc \
  --output-path .build/site \
  --fallback-display-name ObjectTrackingWithRCP \
  --fallback-bundle-identifier com.madebyrsh.ObjectTrackingWithRCP \
  --fallback-default-module-kind Application \
  --hosting-base-path /2026TechMap_tutorial \
  --transform-for-static-hosting \
  --warnings-as-errors

cp scripts/docc-root-redirect.html .build/site/index.html
