$ErrorActionPreference = "Stop"

if (Test-Path -LiteralPath "artifacts") { Remove-Item -LiteralPath "artifacts" -Recurse -Force }
if (Test-Path -LiteralPath "package-stage") { Remove-Item -LiteralPath "package-stage" -Recurse -Force }
New-Item -ItemType Directory -Force -Path artifacts | Out-Null
$stageDir = Join-Path $PWD "package-stage"
if (Test-Path -LiteralPath $stageDir) { Remove-Item -LiteralPath $stageDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path (Join-Path $stageDir "lib") | Out-Null
$stageLib = Join-Path $stageDir "lib"

$settingsFile = "netcdf-c\build\install\lib\libnetcdf.settings"
if (Test-Path -LiteralPath $settingsFile) {
  Copy-Item -LiteralPath $settingsFile -Destination $stageLib -Force
}

$runtimeDllDirs = @(
  "netcdf-c\build\install\bin",
  "curl-build\install\bin",
  "build\hdf5\build\install\bin",
  "zlib-build\install\bin"
)
foreach ($dllDir in $runtimeDllDirs) {
  if (Test-Path -LiteralPath $dllDir) {
    Get-ChildItem -LiteralPath $dllDir -Filter *.dll -File | ForEach-Object {
      Copy-Item -LiteralPath $_.FullName -Destination $stageLib -Force
    }
  }
}

$artifactPath = "artifacts/netcdf-$env:NETCDF_TAG-$env:BUILD_PROFILE-$env:MATRIX_OS-$env:MATRIX_ARCH.zip"
Compress-Archive -Path "$stageDir/*" -DestinationPath $artifactPath
Remove-Item -LiteralPath $stageDir -Recurse -Force
