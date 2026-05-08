# NC Native Libraries

This repository provides native NetCDF libraries (serial) for Windows, Linux and MacOS 
|    OS    | x64 | ARM |
|----------|-----|-----|
| Windows  | ✅  | ❌   |
| Linux    | ✅  | ✅   |
| macOS    | ❌  | ✅   |

It uses 
* [HDF5 v1.14.6](https://github.com/HDFGroup/hdf5) Version 2.x is not compatible with NetCDF
* [ZLIB_VERSION v1.3.2](https://github.com/madler/zlib)
* [CURL_VERSION v8.20.0](https://github.com/curl/curl)

## Artifact profile

Current workflow artifacts are built as `full-feature-shared`:
- NetCDF shared library
- DAP/NCZARR/BYTERANGE enabled
- Runtime dependencies are included in the package (`curl`, `hdf5`, `zlib`)

## Package layout

Each artifact is a runtime bundle (not a full SDK):
- `lib/`:
  - Linux/macOS: shared libraries (`libnetcdf`, `libcurl`, `libhdf5*`, `libz*`)
  - Windows: runtime DLLs (`netcdf`, `curl`, `hdf5`, `zlib`, and required CRT DLLs if present)
  - all OS: `libnetcdf.settings` (build configuration summary)

## How to use per OS

### Windows (x64)

For Java/JNI/JNA runtime, use `lib/`:
- put `lib/*.dll` next to your executable, or add `lib` to `PATH`
- `lib/libnetcdf.settings` is informational and useful for diagnostics

### Linux (x64, arm64)

For Java/JNI/JNA runtime, use `lib/`:
- make loader resolve all `.so` files in `lib/` (for example `LD_LIBRARY_PATH` or rpath)
- `lib/libnetcdf.settings` is informational and useful for diagnostics

### macOS (arm64)

For Java/JNI/JNA runtime, use `lib/`:
- make loader resolve all `.dylib` files in `lib/` (for example `@rpath` + embedded rpath)
- `lib/libnetcdf.settings` is informational and useful for diagnostics

## Java quick start

Use these JVM settings:
`-Djava.library.path=<bundle>/lib`

If the JVM still cannot resolve transitive native dependencies, also set:
- Windows: `PATH=<bundle>\\lib;%PATH%`
- Linux: `LD_LIBRARY_PATH=<bundle>/lib:$LD_LIBRARY_PATH`
- macOS: `DYLD_LIBRARY_PATH=<bundle>/lib:$DYLD_LIBRARY_PATH`
