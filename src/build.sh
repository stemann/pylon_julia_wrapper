#!/bin/sh

julia --project --eval 'using Pkg; pkg"instantiate"'
CxxWrap_PATH=`julia --project --eval 'import CxxWrap; println(joinpath(dirname(pathof(CxxWrap)), ".."))'`
rm -rf build\
  && mkdir -p build\
  && cd build\
  && cmake ../src -DCMAKE_FIND_ROOT_PATH=${CxxWrap_PATH}/deps/usr/lib/cmake -DPYLON_INCLUDE_PATH=${PYLON_INCLUDE_PATH} -DPYLON_LIB_PATH=${PYLON_LIB_PATH}\
  && make
