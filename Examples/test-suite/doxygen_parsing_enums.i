%module doxygen_parsing_enums

%inline %{


/** Test enumeration */
enum E_TEST
{
  /** the first item */
  E_TEST_ONE,
  E_TEST_TWO = 2, /**< the second */
  E_TEST_THREE = 2+1
};

%}