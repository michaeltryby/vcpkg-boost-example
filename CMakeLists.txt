


cmake_minimum_required (
    VERSION 3.0
)

if("${CMAKE_BINARY_DIR}" STREQUAL "${CMAKE_SOURCE_DIR}")
    message(FATAL_ERROR "In-source builds are disabled.")
endif()


project(
  first-test
    VERSION 0.0.1
    LANGUAGES CXX
)

enable_testing()
add_subdirectory(test)
