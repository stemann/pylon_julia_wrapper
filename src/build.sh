#!/bin/sh

julia --project --eval 'using Pkg; pkg"instantiate"'
rm -rf build\
  && mkdir -p build\
  && cd build\
  && cmake -DCMAKE_BUILD_TYPE=Release ../src\
  && cmake --build . --config Release
