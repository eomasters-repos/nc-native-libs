$ErrorActionPreference = "Stop"

Set-Location "netcdf-c"
$workspaceCMake = $env:GITHUB_WORKSPACE -replace '\\','/'
$hdf5Root = "$workspaceCMake/build/hdf5/build/install"
$curlRootNative = $env:CURL_ROOT -replace '/','\'
$curlIncludeNative = $env:CURL_INCLUDE -replace '/','\'
$env:PATH = "$($hdf5Root -replace '/','\')\bin;$env:PATH"
$env:INCLUDE = "$curlIncludeNative;$env:INCLUDE"
$env:LIB = "$curlRootNative\lib;$env:LIB"
New-Item -ItemType Directory -Force -Path build | Out-Null
Set-Location build

cmake .. -A $env:CMAKE_ARCH "--log-level=WARNING"`
  "-DBUILD_SHARED_LIBS=ON" `
  "-DNETCDF_ENABLE_HDF5=ON" `
  "-DNETCDF_ENABLE_TESTS=OFF" `
  "-DHDF5_ROOT=$hdf5Root" `
  "-DNETCDF_ENABLE_DAP=ON" `
  "-DNETCDF_ENABLE_NCZARR=ON" `
  "-DNETCDF_ENABLE_BYTERANGE=ON" `
  "-DCMAKE_FIND_PACKAGE_PREFER_CONFIG=OFF" `
  "-DCMAKE_C_FLAGS=/I$env:CURL_INCLUDE" `
  "-DCMAKE_PREFIX_PATH=$env:CURL_ROOT;$env:ZLIB_ROOT;$hdf5Root" `
  "-DCURL_ROOT=$env:CURL_ROOT" `
  "-DCURL_DIR=$env:CURL_DIR" `
  "-DCURL_INCLUDE_DIR=$env:CURL_INCLUDE" `
  "-DCURL_INCLUDE_DIRS=$env:CURL_INCLUDE" `
  "-DCURL_LIBRARY=$env:CURL_LIBRARY" `
  "-DZLIB_LIBRARY=$env:ZLIB_LIBRARY" `
  "-DZLIB_INCLUDE_DIR=$env:ZLIB_INCLUDE" `
  "-DCMAKE_INSTALL_PREFIX=$PWD/install" `
  "-DCMAKE_BUILD_TYPE=Release"

cmake --build . --config Release -- /m /verbosity:minimal
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
cmake --install . --config Release --prefix "$PWD/install"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
