


#define BOOST_TEST_MODULE "first_test"

#include <boost/test/included/unit_test.hpp>


BOOST_AUTO_TEST_CASE_EXPECTED_FAILURES(first_test, 1)

BOOST_AUTO_TEST_CASE(first_test)
{
  int i = 1;

  BOOST_TEST(i);
  BOOST_TEST(i == 2);
}
