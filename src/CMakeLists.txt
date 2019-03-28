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
