$ErrorActionPreference = "Stop"

$url = "https://github.com/madler/zlib/archive/refs/tags/v$env:ZLIB_VERSION.tar.gz"
Invoke-WebRequest -Uri $url -OutFile "zlib.tar.gz"
New-Item -ItemType Directory -Force -Path zlib-src | Out-Null
tar -xf zlib.tar.gz -C zlib-src --strip-components=1

New-Item -ItemType Directory -Force -Path zlib-build | Out-Null
Set-Location zlib-build
$installPrefix = "$PWD\install"
$installPrefixCMake = $installPrefix -replace '\\','/'

cmake ../zlib-src -A $env:CMAKE_ARCH `
  "-DBUILD_SHARED_LIBS=ON" `
  "-DCMAKE_BUILD_TYPE=Release" `
  "--log-level=WARNING"

cmake --build . --config Release -- /m /verbosity:minimal /nologo
cmake --install . --config Release --prefix $installPrefix

$zlibStaticLibCandidates = @(
  "$installPrefix\lib\zs.lib",
  "$installPrefix\lib\zlibstatic.lib",
  "$installPrefix\lib\zlib.lib"
)
$zlibStaticLib = $zlibStaticLibCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $zlibStaticLib) {
  Get-ChildItem -LiteralPath "$installPrefix\lib" -ErrorAction SilentlyContinue
  throw "Could not find installed zlib static library under $installPrefix\lib"
}
$zlibSharedImportCandidates = @(
  "$installPrefix\lib\zlib.lib",
  "$installPrefix\lib\z.lib"
)
$zlibSharedImportLib = $zlibSharedImportCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $zlibSharedImportLib) {
  Get-ChildItem -LiteralPath "$installPrefix\lib" -ErrorAction SilentlyContinue
  throw "Could not find installed zlib shared import library under $installPrefix\lib"
}
$zlibDllCandidates = @(
  (Join-Path $installPrefix "bin\z.dll"),
  (Join-Path $installPrefix "bin\zlib1.dll"),
  (Join-Path $installPrefix "bin\zlib.dll")
)
$zlibDll = $zlibDllCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $zlibDll -or -not (Test-Path -LiteralPath $zlibDll)) {
  Get-ChildItem -LiteralPath "$installPrefix\bin" -ErrorAction SilentlyContinue
  throw "Could not find installed zlib runtime DLL under $installPrefix\bin"
}
$zlibSharedImportLibCMake = $zlibSharedImportLib -replace '\\','/'
$zlibStaticLibCMake = $zlibStaticLib -replace '\\','/'
$zlibDllCMake = $zlibDll -replace '\\','/'

echo "ZLIB_ROOT=$installPrefixCMake" >> $env:GITHUB_ENV
echo "ZLIB_DIR=$installPrefixCMake/lib/cmake/zlib" >> $env:GITHUB_ENV
echo "ZLIB_INCLUDE=$installPrefixCMake/include" >> $env:GITHUB_ENV
echo "ZLIB_LIBRARY=$zlibSharedImportLibCMake" >> $env:GITHUB_ENV
echo "ZLIB_STATIC_LIBRARY=$zlibStaticLibCMake" >> $env:GITHUB_ENV
echo "ZLIB_SHARED_LIBRARY=$zlibSharedImportLibCMake" >> $env:GITHUB_ENV
echo "ZLIB_DLL=$zlibDllCMake" >> $env:GITHUB_ENV
