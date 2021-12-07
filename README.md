# Pylon Julia Wrapper

[![Build Status](https://github.com/IHPSystems/pylon_julia_wrapper/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/IHPSystems/pylon_julia_wrapper/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/IHPSystems/pylon_julia_wrapper/branch/master/graph/badge.svg)](https://codecov.io/gh/IHPSystems/pylon_julia_wrapper)

## BinaryBuilder
```
BINARYBUILDER_RUNNER=docker BINARYBUILDER_AUTOMATIC_APPLE=true julia --color=yes --project=binary_builder binary_builder/build_tarballs.jl --verbose --deploy=local
```

## Docker
Build the image:
```sh
docker build -t pylon_julia_wrapper .
```

Run the `init.jl` sample:
```sh
docker run --rm -it pylon_julia_wrapper
```

Run the `enumerate_devices.jl` sample - passing through USB device 2 on bus 4:
```sh
docker run --rm -it --device=/dev/bus/usb/004/002 pylon_julia_wrapper julia --project samples/enumerate_devices.jl
```

## Local

### Building

Set `PYLON_INCLUDE_PATH` and `PYLON_LIB_PATH` to paths for Pylon library. On macOS:
```sh
export PYLON_INCLUDE_PATH=/Library/Frameworks/pylon.framework/Headers
export PYLON_LIB_PATH=/Library/Frameworks/pylon.framework/Libraries
```
Build:
```sh
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ../src
cmake --build . --config Release
```

### Running samples
Set dynamic/shared library loading path properly. On macOS:
```sh
export LD_LIBRARY_PATH=/Library/Frameworks/pylon.framework/Libraries
```
Execute sample:
```sh
julia --project samples/init.jl
```
