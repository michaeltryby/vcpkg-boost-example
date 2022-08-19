


if(WIN32)
    set(
      Boost_USE_STATIC_LIBS ON
    )
else()
    set(
      Boost_USE_STATIC_LIBS OFF
    )
    add_definitions(
      -DBOOST_ALL_DYN_LINK
    )
endif()


find_package(
  Boost
    REQUIRED
    COMPONENTS
        unit_test_framework
)

include_directories(
    ${Boost_INCLUDE_DIRS}
)
