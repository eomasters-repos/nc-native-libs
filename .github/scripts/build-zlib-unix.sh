#!/usr/bin/env bash
set -euo pipefail

curl -sSLf "https://github.com/madler/zlib/archive/refs/tags/v${ZLIB_VERSION}.tar.gz" -o zlib.tar.gz
mkdir -p zlib-src
tar -xf zlib.tar.gz -C zlib-src --strip-components=1

mkdir -p zlib-build
cd zlib-build

cmake ../zlib-src \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PWD/install" \
  -DZLIB_BUILD_SHARED=ON \
  -DCMAKE_OSX_ARCHITECTURES="${CMAKE_ARCH}" \
  --log-level=WARNING

cmake --build . --target install -- -s

echo "ZLIB_ROOT=$PWD/install" >> "$GITHUB_ENV"
echo "ZLIB_DIR=$PWD/install/lib/cmake/zlib" >> "$GITHUB_ENV"
echo "ZLIB_INCLUDE=$PWD/install/include" >> "$GITHUB_ENV"

if [[ "$RUNNER_OS" == "Linux" ]]; then
  echo "ZLIB_LIBRARY=$PWD/install/lib/libz.so" >> "$GITHUB_ENV"
  echo "ZLIB_STATIC_LIBRARY=$PWD/install/lib/libz.a" >> "$GITHUB_ENV"
  echo "ZLIB_SHARED_LIBRARY=$PWD/install/lib/libz.so" >> "$GITHUB_ENV"
else
  echo "ZLIB_LIBRARY=$PWD/install/lib/libz.dylib" >> "$GITHUB_ENV"
  echo "ZLIB_STATIC_LIBRARY=$PWD/install/lib/libz.a" >> "$GITHUB_ENV"
  echo "ZLIB_SHARED_LIBRARY=$PWD/install/lib/libz.dylib" >> "$GITHUB_ENV"
fi
