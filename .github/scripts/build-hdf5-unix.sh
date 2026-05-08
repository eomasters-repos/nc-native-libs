#!/usr/bin/env bash
set -euo pipefail

cd build/hdf5

wget -q -O hdf5.tar.gz \
  "https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-1_14_${HDF5_VERSION##*.}.tar.gz"
mkdir -p src
tar -xf hdf5.tar.gz --strip-components=1 -C src
mkdir -p build
cd build

cmake ../src -G Ninja --log-level=WARNING \
  -DBUILD_SHARED_LIBS=ON \
  -DHDF5_BUILD_TOOLS=OFF \
  -DBUILD_TESTING=OFF \
  -DHDF5_BUILD_TESTING=OFF \
  -DHDF5_BUILD_EXAMPLES=OFF \
  -DHDF5_BUILD_HL_TOOLS=OFF \
  -DHDF5_ENABLE_Z_LIB_SUPPORT=ON \
  -DCMAKE_INSTALL_PREFIX="$PWD/install" \
  -DCMAKE_PREFIX_PATH="$ZLIB_ROOT" \
  -DZLIB_ROOT="$ZLIB_ROOT" \
  -DZLIB_DIR="$ZLIB_DIR" \
  -DZLIB_INCLUDE_DIR="$ZLIB_INCLUDE" \
  -DZLIB_LIBRARY="$ZLIB_LIBRARY" \
  -DCMAKE_OSX_ARCHITECTURES="${CMAKE_ARCH}" \
  -DCMAKE_BUILD_TYPE=Release

cmake --build . --config Release
cmake --install . --prefix install
