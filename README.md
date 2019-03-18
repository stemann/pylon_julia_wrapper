# Pylon Julia Wrapper

[![Build Status](https://travis-ci.com/IHPSystems/pylon_julia_wrapper.svg?branch=master)](https://travis-ci.com/IHPSystems/pylon_julia_wrapper)

## Building

### BinaryBuilder
```
BINARYBUILDER_RUNNER=docker julia --color=yes build_tarballs.jl --verbose
```

### Local
Set `PYLON_INCLUDE_PATH` and `PYLON_LIB_PATH` to paths for Pylon library. On macOS:
```
export PYLON_INCLUDE_PATH=/Library/Frameworks/pylon.framework/Headers
export PYLON_LIB_PATH=/Library/Frameworks/pylon.framework/Libraries
```
Build:
```
export CxxWrap_PATH=`julia --eval 'import CxxWrap; println(joinpath(dirname(pathof(CxxWrap)), ".."))'`

mkdir -p build
cd build
cmake ../src -DCMAKE_FIND_ROOT_PATH=${CxxWrap_PATH}/deps/usr/lib/cmake -DPYLON_INCLUDE_PATH=${PYLON_INCLUDE_PATH} -DPYLON_LIB_PATH=${PYLON_LIB_PATH}
make
```

## Running samples
Set dynamic/shared library loading path properly. On macOS:
```
export LD_LIBRARY_PATH=/Library/Frameworks/pylon.framework/Libraries
```
Execute sample:
```
julia samples/init.jl
```
