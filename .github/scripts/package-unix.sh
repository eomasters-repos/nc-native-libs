#!/usr/bin/env bash
set -euo pipefail

rm -rf artifacts package-stage
mkdir -p artifacts
STAGE_DIR="$PWD/package-stage"
rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR/lib"

copy_matches() {
  local pattern="$1"
  shopt -s nullglob
  local files=($pattern)
  shopt -u nullglob
  if ((${#files[@]})); then
    cp -a "${files[@]}" "$STAGE_DIR/lib/"
  fi
}

copy_matches "netcdf-c/build/install/lib/libnetcdf.settings"
if [[ "$MATRIX_OS" == "linux" ]]; then
  copy_matches "netcdf-c/build/install/lib/libnetcdf.so*"
  copy_matches "curl-build/install/lib/libcurl.so*"
  copy_matches "build/hdf5/build/install/lib/libhdf5*.so*"
  copy_matches "zlib-build/install/lib/libz.so*"
else
  copy_matches "netcdf-c/build/install/lib/libnetcdf*.dylib"
  copy_matches "curl-build/install/lib/libcurl*.dylib"
  copy_matches "build/hdf5/build/install/lib/libhdf5*.dylib"
  copy_matches "zlib-build/install/lib/libz*.dylib"
fi

tar -czf "artifacts/netcdf-${NETCDF_TAG}-${MATRIX_OS}-${MATRIX_ARCH}.tar.gz" -C "$STAGE_DIR" .
rm -rf "$STAGE_DIR"
