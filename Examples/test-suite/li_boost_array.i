%module li_boost_array

#if defined(SWIGPYTHON) || defined(SWIGRUBY)

// Hack to use the std::array support for boost::array.
// Is limited as it currently exposes some 'using' bugs in SWIG though.
// For example, the type system fails to see that pointers to std::array
// and pointers to boost::array are the same.

%{
#if __cplusplus >= 201103 || (defined(_MSC_VER) && _MSC_VER >= 1900)
// Use C++11 array as this is unfortunately sometimes included by <algorithm>
#include <array>
namespace boost {
  using std::array;
}
#else
#include <boost/array.hpp>
namespace std {
  using boost::array;
}
#endif
%}
namespace boost {
  using std::array;
}

%ignore std::array::fill; // Some older versions of boost don't have this function

%include <std_array.i>

%template(ArrayInt6) std::array<int, 6>;

%inline %{
boost::array<int, 6> arrayOutVal() {
  const signed char carray[] = { -2, -1, 0, 0, 1, 2 };
  boost::array<int, 6> myarray;
  for (size_t i=0; i<6; ++i) {
    myarray[i] = carray[i];
  }
  return myarray;
}

boost::array<int, 6> & arrayOutRef() {
  static boost::array<int, 6> a = { -2, -1, 0, 0, 1, 2 };
  return a;
}

const boost::array<int, 6> & arrayOutConstRef() {
  static boost::array<int, 6> a = { -2, -1, 0, 0, 1, 2 };
  return a;
}

boost::array<int, 6> * arrayOutPtr() {
  static boost::array<int, 6> a = { -2, -1, 0, 0, 1, 2 };
  return &a;
}

boost::array<int, 6> arrayInVal(boost::array<int, 6> myarray) {
  for (boost::array<int, 6>::iterator it = myarray.begin(); it!=myarray.end(); ++it) {
    *it *= 10;
  }
  return myarray;
}

const boost::array<int, 6> & arrayInConstRef(const boost::array<int, 6> & myarray) {
  static boost::array<int, 6> a = myarray;
  for (boost::array<int, 6>::iterator it = a.begin(); it!=a.end(); ++it) {
    *it *= 10;
  }
  return a;
}

void arrayInRef(boost::array<int, 6> & myarray) {
  for (boost::array<int, 6>::iterator it = myarray.begin(); it!=myarray.end(); ++it) {
    *it *= 10;
  }
}

void arrayInPtr(boost::array<int, 6> * myarray) {
  for (boost::array<int, 6>::iterator it = myarray->begin(); it!=myarray->end(); ++it) {
    *it *= 10;
  }
}
%}

#endif
