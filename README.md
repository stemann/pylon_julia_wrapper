# Pylon Julia Wrapper

[![Build Status](https://travis-ci.com/IHPSystems/pylon_julia_wrapper.svg?branch=master)](https://travis-ci.com/IHPSystems/pylon_julia_wrapper)

## BinaryBuilder
```
BINARYBUILDER_RUNNER=docker BINARYBUILDER_AUTOMATIC_APPLE=true julia --color=yes build_tarballs.jl --verbose
```

## Docker
Build the image:
```
docker build -t pylon_julia_wrapper .
```

Run the `init.jl` sample:
```
docker run --rm -it pylon_julia_wrapper
```

Run the `enumerate_devices.jl` sample - passing through USB device 2 on bus 4:
```
docker run --rm -it --device=/dev/bus/usb/004/002 pylon_julia_wrapper julia --eval 'import Pkg; Pkg.activate("."); include("samples/enumerate_devices.jl")'
```

## Local

### Building

Set `PYLON_INCLUDE_PATH` and `PYLON_LIB_PATH` to paths for Pylon library. On macOS:
```
export PYLON_INCLUDE_PATH=/Library/Frameworks/pylon.framework/Headers
export PYLON_LIB_PATH=/Library/Frameworks/pylon.framework/Libraries
```
Build:
```
export CxxWrap_PATH=`julia --eval 'import Pkg; Pkg.activate("."); import CxxWrap; println(joinpath(dirname(pathof(CxxWrap)), ".."))'`

mkdir -p build
cd build
cmake ../src -DCMAKE_FIND_ROOT_PATH=${CxxWrap_PATH}/deps/usr/lib/cmake -DPYLON_INCLUDE_PATH=${PYLON_INCLUDE_PATH} -DPYLON_LIB_PATH=${PYLON_LIB_PATH}
make
```

### Running samples
Set dynamic/shared library loading path properly. On macOS:
```
export LD_LIBRARY_PATH=/Library/Frameworks/pylon.framework/Libraries
```
Execute sample:
```
julia --eval 'import Pkg; Pkg.activate("."); include("samples/init.jl")'
```
