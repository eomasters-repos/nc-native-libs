$ErrorActionPreference = "Stop"

$url = "https://curl.se/download/curl-$env:CURL_VERSION.tar.gz"
Invoke-WebRequest -Uri $url -OutFile "curl.tar.gz"
tar -xf curl.tar.gz
Rename-Item "curl-$env:CURL_VERSION" curl-src

New-Item -ItemType Directory -Force -Path curl-build | Out-Null
Set-Location curl-build
$curlInstallPrefix = ("$PWD\install" -replace '\\','/')

cmake ../curl-src -A $env:CMAKE_ARCH `
  "-DBUILD_SHARED_LIBS=ON" `
  "-DCURL_USE_SCHANNEL=ON" `
  "-DCURL_USE_OPENSSL=OFF" `
  "-DCURL_USE_LIBPSL=OFF" `
  "-DCURL_ZLIB=OFF" `
  "-DCMAKE_INSTALL_PREFIX=$curlInstallPrefix" `
  "-DCMAKE_BUILD_TYPE=Release" `
  "--log-level=WARNING"

cmake --build . --config Release --target install -- /m /verbosity:minimal /nologo

$curlImportLibCandidates = @(
  "$PWD\install\lib\libcurl_imp.lib",
  "$PWD\install\lib\libcurl.lib"
)
$curlImportLib = $curlImportLibCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $curlImportLib) {
  Get-ChildItem -LiteralPath "$PWD\install\lib" -ErrorAction SilentlyContinue
  throw "Could not find installed curl import library"
}
$curlDll = "$PWD\install\bin\libcurl.dll"
if (-not (Test-Path -LiteralPath $curlDll)) {
  Get-ChildItem -LiteralPath "$PWD\install\bin" -ErrorAction SilentlyContinue
  throw "Could not find installed curl runtime DLL"
}
$curlImportLibCMake = $curlImportLib -replace '\\','/'
$curlDllCMake = $curlDll -replace '\\','/'

echo "CURL_ROOT=$curlInstallPrefix" >> $env:GITHUB_ENV
echo "CURL_DIR=$curlInstallPrefix/lib/cmake/CURL" >> $env:GITHUB_ENV
echo "CURL_INCLUDE=$curlInstallPrefix/include" >> $env:GITHUB_ENV
echo "CURL_LIBRARY=$curlImportLibCMake" >> $env:GITHUB_ENV
echo "CURL_SHARED_LIBRARY=$curlImportLibCMake" >> $env:GITHUB_ENV
echo "CURL_DLL=$curlDllCMake" >> $env:GITHUB_ENV
