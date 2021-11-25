cmake_minimum_required(VERSION 3.10)

cmake_policy(SET CMP0025 NEW) # Fix for https://docs.binarybuilder.org/stable/troubleshooting/#CMake-complains-%22No-known-for-CXX-compiler%22

project(pylon_julia_wrapper)

set(CMAKE_MACOSX_RPATH 1)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

if(NOT DEFINED CMAKE_PREFIX_PATH AND NOT DEFINED CMAKE_FIND_ROOT_PATH)
  if(DEFINED ENV{CMAKE_PREFIX_PATH})
    set(CMAKE_PREFIX_PATH $ENV{CMAKE_PREFIX_PATH})
  else()
    execute_process(COMMAND bash "-c" "julia --project --eval 'import CxxWrap; if VERSION >= v\"1.3\" println(CxxWrap.prefix_path()) else println(joinpath(dirname(pathof(CxxWrap)), \"..\", \"deps\", \"usr\")) end'" OUTPUT_VARIABLE CMAKE_PREFIX_PATH OUTPUT_STRIP_TRAILING_WHITESPACE)
  endif()
  message(STATUS "CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}")
endif()

if(NOT DEFINED PYLON_INCLUDE_PATH)
  if(DEFINED ENV{PYLON_INCLUDE_PATH})
    set(PYLON_INCLUDE_PATH $ENV{PYLON_INCLUDE_PATH})
  else()
    message(SEND_ERROR "Please define PYLON_INCLUDE_PATH")
  endif()
endif()
message(STATUS "PYLON_INCLUDE_PATH: ${PYLON_INCLUDE_PATH}")

if(NOT DEFINED PYLON_LIB_PATH)
  if(DEFINED ENV{PYLON_LIB_PATH})
    set(PYLON_LIB_PATH $ENV{PYLON_LIB_PATH})
  else()
    message(SEND_ERROR "Please define PYLON_LIB_PATH")
  endif()
endif()
message(STATUS "PYLON_LIB_PATH: ${PYLON_LIB_PATH}")

if(APPLE AND EXISTS ${PYLON_INCLUDE_PATH} AND EXISTS ${PYLON_INCLUDE_PATH}/GenICam)
  message(STATUS "Copying/linking files from ${PYLON_INCLUDE_PATH} to ${CMAKE_BINARY_DIR}/pylon_include")
  file(COPY ${PYLON_INCLUDE_PATH}/GenICam/ DESTINATION ${CMAKE_BINARY_DIR}/pylon_include)
  file(CREATE_LINK ${PYLON_INCLUDE_PATH} ${CMAKE_BINARY_DIR}/pylon_include/pylon SYMBOLIC)
  set(PYLON_INCLUDE_PATH ${CMAKE_BINARY_DIR}/pylon_include)
  message(STATUS "PYLON_INCLUDE_PATH: ${PYLON_INCLUDE_PATH}")
endif()

find_package(JlCxx)
get_target_property(JlCxx_location JlCxx::cxxwrap_julia LOCATION)
get_filename_component(JlCxx_location ${JlCxx_location} DIRECTORY)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib;${JlCxx_location}")

message(STATUS "Found JlCxx at ${JlCxx_location}")

add_library(pylon_julia_wrapper SHARED pylon_wrapper.cpp)

target_link_libraries(pylon_julia_wrapper JlCxx::cxxwrap_julia)

if(APPLE)
  message(STATUS "Looking for julia uv library in ${Julia_LIBRARY_DIR}")
  find_library(julia_uv_library NAMES uv PATHS ${Julia_LIBRARY_DIR}/julia)
  message(STATUS "Found julia uv at ${julia_uv_library}")
  add_library(julia_uv SHARED IMPORTED)
  set_property(TARGET julia_uv PROPERTY IMPORTED_LOCATION ${julia_uv_library})

  target_link_libraries(pylon_julia_wrapper julia_uv)
endif()

target_include_directories(pylon_julia_wrapper PRIVATE "${PYLON_INCLUDE_PATH};${PYLON_INCLUDE_PATH}/GenICam")

find_library(pylonbase_library NAMES pylonbase PATHS ${PYLON_LIB_PATH})
message(STATUS "Found pylonbase at ${pylonbase_library}")
add_library(pylonbase SHARED IMPORTED)
set_property(TARGET pylonbase PROPERTY IMPORTED_LOCATION ${pylonbase_library})

target_link_libraries(pylon_julia_wrapper pylonbase)

find_library(pylonutility_library NAMES pylonutility PATHS ${PYLON_LIB_PATH})
message(STATUS "Found pylonutility at ${pylonutility_library}")
add_library(pylonutility SHARED IMPORTED)
set_property(TARGET pylonutility PROPERTY IMPORTED_LOCATION ${pylonutility_library})

target_link_libraries(pylon_julia_wrapper pylonutility)

find_library(GCBase_library NAMES GCBase_gcc_v3_1_Basler_pylon GCBase_gcc_v3_1_Basler_pylon_v5_1 GCBase_gcc_v3_0_Basler_pylon_v5_0 PATHS ${PYLON_LIB_PATH})
message(STATUS "Found GCBase at ${GCBase_library}")
add_library(GCBase SHARED IMPORTED)
set_property(TARGET GCBase PROPERTY IMPORTED_LOCATION ${GCBase_library})

target_link_libraries(pylon_julia_wrapper GCBase)

find_library(GenApi_library NAMES GenApi_gcc_v3_1_Basler_pylon GenApi_gcc_v3_1_Basler_pylon_v5_1 GenApi_gcc_v3_0_Basler_pylon_v5_0 PATHS ${PYLON_LIB_PATH})
message(STATUS "Found GenApi at ${GenApi_library}")
add_library(GenApi SHARED IMPORTED)
set_property(TARGET GenApi PROPERTY IMPORTED_LOCATION ${GenApi_library})

target_link_libraries(pylon_julia_wrapper GenApi)

install(TARGETS
  pylon_julia_wrapper
LIBRARY DESTINATION lib
ARCHIVE DESTINATION lib
RUNTIME DESTINATION lib)
