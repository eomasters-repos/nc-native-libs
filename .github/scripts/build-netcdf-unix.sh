#!/usr/bin/env bash
set -euo pipefail

cd netcdf-c

export PATH="${GITHUB_WORKSPACE}/build/hdf5/build/install/bin:$PATH"
export CPATH="$CURL_INCLUDE${CPATH:+:$CPATH}"
export LIBRARY_PATH="$CURL_ROOT/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"

mkdir -p build
cd build

cmake .. -G Ninja \
  -DBUILD_SHARED_LIBS=ON \
  -DNETCDF_ENABLE_HDF5=ON \
  -DHDF5_ROOT="${GITHUB_WORKSPACE}/build/hdf5/build/install" \
  -DNETCDF_ENABLE_DAP=ON \
  -DNETCDF_ENABLE_NCZARR=ON \
  -DNETCDF_ENABLE_BYTERANGE=ON \
  -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=OFF \
  -DCMAKE_PREFIX_PATH="$CURL_ROOT;$ZLIB_ROOT;${GITHUB_WORKSPACE}/build/hdf5/build/install" \
  -DCURL_ROOT="$CURL_ROOT" \
  -DCURL_DIR="$CURL_DIR" \
  -DCURL_INCLUDE_DIR="$CURL_INCLUDE" \
  -DCURL_INCLUDE_DIRS="$CURL_INCLUDE" \
  -DCURL_LIBRARY="$CURL_LIBRARY" \
  -DZLIB_INCLUDE_DIR="$ZLIB_INCLUDE" \
  -DZLIB_LIBRARY="$ZLIB_LIBRARY" \
  -DCMAKE_OSX_ARCHITECTURES="${CMAKE_ARCH}" \
  -DCMAKE_INSTALL_PREFIX="$PWD/install" \
  -DCMAKE_BUILD_TYPE=Release

cmake --build . --config Release -- -j"$(sysctl -n hw.ncpu 2>/dev/null || nproc)"
cmake --install . --prefix install
