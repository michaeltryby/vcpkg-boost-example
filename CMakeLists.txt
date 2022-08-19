


cmake_minimum_required (
    VERSION 3.0
)

if("${CMAKE_BINARY_DIR}" STREQUAL "${CMAKE_SOURCE_DIR}")
    message(FATAL_ERROR "In-source builds are disabled.")
endif()


project(
  boost-test
    VERSION 0.0.1
    LANGUAGES CXX
)

enable_testing()
add_subdirectory(src)



set(
    TEST_BIN_DIRECTORY "${CMAKE_BINARY_DIR}/src/$<CONFIGURATION>"
)

add_test(
    NAME
      first_test
    COMMAND
      "${TEST_BIN_DIRECTORY}/first_test"
)
