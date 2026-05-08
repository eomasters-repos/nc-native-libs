$ErrorActionPreference = "Stop"

Set-Location "build/hdf5"
Invoke-WebRequest -Uri "https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-1_14_$($env:HDF5_VERSION.Split('.')[2]).tar.gz" -OutFile hdf5.tar.gz
New-Item -ItemType Directory -Force -Path src | Out-Null
tar -xf hdf5.tar.gz -C src --strip-components=1
New-Item -ItemType Directory -Force -Path build | Out-Null
Set-Location build

cmake ../src -A $env:CMAKE_ARCH "--log-level=WARNING"`
  "-DBUILD_SHARED_LIBS=ON" `
  "-DHDF5_BUILD_TOOLS=OFF" `
  "-DBUILD_TESTING=OFF" `
  "-DHDF5_BUILD_TESTING=OFF" `
  "-DHDF5_BUILD_EXAMPLES=OFF" `
  "-DHDF5_BUILD_HL_TOOLS=OFF" `
  "-DHDF5_ENABLE_Z_LIB_SUPPORT=ON" `
  "-DCMAKE_PREFIX_PATH=$env:ZLIB_ROOT" `
  "-DZLIB_ROOT=$env:ZLIB_ROOT" `
  "-DZLIB_DIR=$env:ZLIB_DIR" `
  "-DZLIB_INCLUDE_DIR=$env:ZLIB_INCLUDE" `
  "-DZLIB_LIBRARY=$env:ZLIB_LIBRARY" `
  "-DCMAKE_INSTALL_PREFIX=$PWD/install" `
  "-DCMAKE_BUILD_TYPE=Release"

cmake --build . --config Release --target install -- /verbosity:minimal
