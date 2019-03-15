# Pylon Julia Wrapper

## Building

### BinaryBuilder
```
BINARYBUILDER_RUNNER=docker julia --color=yes build_tarballs.jl --verbose
```

### Local
```
export CxxWrap_PATH=`julia --eval 'import CxxWrap; println(joinpath(dirname(pathof(CxxWrap)), ".."))'`

mkdir -p build
cd build
cmake ../src -DCMAKE_FIND_ROOT_PATH=${CxxWrap_PATH}/deps/usr/lib/cmake
make
```
