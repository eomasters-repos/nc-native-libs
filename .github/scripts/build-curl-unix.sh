#!/usr/bin/env bash
set -euo pipefail

curl -sSL "https://curl.se/download/curl-$CURL_VERSION.tar.gz" -o curl.tar.gz
mkdir -p curl-src
tar -xf curl.tar.gz -C curl-src --strip-components=1

mkdir -p curl-build
cd curl-build

cmake ../curl-src \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PWD/install" \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DBUILD_SHARED_LIBS=ON \
  -DCURL_USE_LIBPSL=OFF \
  -DCURL_ZLIB=OFF \
  -DCMAKE_OSX_ARCHITECTURES="${CMAKE_ARCH}" \
  -DCURL_USE_OPENSSL=ON \
  --log-level=WARNING

cmake --build . --target install -- -s

echo "CURL_ROOT=$PWD/install" >> "$GITHUB_ENV"
echo "CURL_DIR=$PWD/install/lib/cmake/CURL" >> "$GITHUB_ENV"
echo "CURL_INCLUDE=$PWD/install/include" >> "$GITHUB_ENV"
if [[ "$RUNNER_OS" == "Linux" ]]; then
  echo "CURL_LIBRARY=$PWD/install/lib/libcurl.so" >> "$GITHUB_ENV"
  echo "CURL_SHARED_LIBRARY=$PWD/install/lib/libcurl.so" >> "$GITHUB_ENV"
else
  echo "CURL_LIBRARY=$PWD/install/lib/libcurl.dylib" >> "$GITHUB_ENV"
  echo "CURL_SHARED_LIBRARY=$PWD/install/lib/libcurl.dylib" >> "$GITHUB_ENV"
fi
