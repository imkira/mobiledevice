#!/usr/bin/env bash

# Apple bars linking against PrivateFrameworks on recent versions of
# macOS, but we can work around this by symlinking the framework here
# and pointing to this directory with `-F` in Makefile, which does work.
MobileDevice="/System/Library/PrivateFrameworks/MobileDevice.framework"
LocalFrameworks="$(pwd)/Frameworks"

if [ -d "$LocalFrameworks" ]; then
  echo "$LocalFrameworks seems to exist already; please delete it & try again"
  exit 1
fi

mkdir -p "$LocalFrameworks"
ln -sf "$MobileDevice" "$LocalFrameworks/MobileDevice.framework"

if [ "$(readlink "$LocalFrameworks/MobileDevice.framework")" == "$MobileDevice" ]
then
  echo "Symlink creation successful"
else
  echo "Failed to create expected symlink"
  exit 1
fi
