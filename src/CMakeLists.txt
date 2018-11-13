project(pylon_julia_wrapper)

cmake_minimum_required(VERSION 2.8.12)
set(CMAKE_MACOSX_RPATH 1)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

find_package(JlCxx)
get_target_property(JlCxx_location JlCxx::cxxwrap_julia LOCATION)
get_filename_component(JlCxx_location ${JlCxx_location} DIRECTORY)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib;${JlCxx_location}")

message(STATUS "Found JlCxx at ${JlCxx_location}")

add_library(pylon_julia_wrapper SHARED pylon_wrapper.cpp)

target_link_libraries(pylon_julia_wrapper JlCxx::cxxwrap_julia)

target_include_directories(pylon_julia_wrapper PRIVATE "${PYLON_INCLUDE_PATH};${PYLON_INCLUDE_PATH}/GenICam")

find_library(pylonbase_library NAMES pylonbase PATHS ${PYLON_LIB_PATH})
message(STATUS "Found pylonbase at ${pylonbase_library}")
add_library(pylonbase SHARED IMPORTED)
set_property(TARGET pylonbase PROPERTY IMPORTED_LOCATION ${pylonbase_library})

target_link_libraries(pylon_julia_wrapper pylonbase)

install(TARGETS
  pylon_julia_wrapper
LIBRARY DESTINATION lib
ARCHIVE DESTINATION lib
RUNTIME DESTINATION lib)
