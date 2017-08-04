/* This test case checks whether SWIG correctly parses and ignores
   "static_assert()" in various places.
*/
%module cpp11_static_assert

%inline %{
static_assert(sizeof(int) >= 2, "What?  int size is invalid!");

namespace dummy {
// C++17 allows the message to be omitted, so check that works too.
static_assert(sizeof(int) >= sizeof(short));
}

template <typename T>
struct Check1 {
  static_assert(sizeof(int) <= sizeof(T), "not big enough");
  Check1() {
      static_assert(true);
  }
};

template <typename T>
class Check2 {
  static_assert(sizeof(int) <= sizeof(T), "not big enough");
};
%}

