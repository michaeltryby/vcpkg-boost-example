


include(./boost-test.cmake)

add_executable(
  first_test
    first_test.cpp
)

target_link_libraries(
  first_test
    ${Boost_LIBRARIES}
)
