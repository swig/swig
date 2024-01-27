%module friends_operator_overloading

// Tests friend operators within a namespace
// Demonstrates how to turn friend operators into member functions (required for some languages - tests includes a Python runtime test)
// Note that by default the friend functions result in global function wrappers (overloaded as there are friends from two different classes)
// Testcase highlighted a compilation problem with Python builtin wrappers
// Tests only the languages that don't ignore operator<<

%warnfilter(SWIGWARN_LANG_IDENTIFIER,                    // Warning 503: Can't wrap 'operator <<' unless renamed to a valid identifier.
            SWIGWARN_IGNORE_OPERATOR_LSHIFT) operator<<; // Warning 373: operator<< ignored

%inline %{
// Remove this define to test the equivalent implementation using member methods instead of friends
#define FRIENDS

// Debugging/tracing using printf
#include <cstdio>
//#define myprintf(a, b) printf(a, b)
#define myprintf(a, b)

namespace shifting {

class ShiftA {
  int val;
public:
  ShiftA(int val = 0) : val(val) {}
#if !defined(FRIENDS)
  ShiftA operator<<(const ShiftA& gd) {
    ShiftA ret(val - gd.getVal());
    myprintf("member operator << (GeoData) %d\n", ret.getVal());
    return ret;
  }
  ShiftA operator<<(int amount) {
    ShiftA ret(val - amount);
    myprintf("member operator << (int) %d\n", ret.getVal());
    return ret;
  }
#else
  friend ShiftA operator<<(const ShiftA& this_, const ShiftA& gd) {
    ShiftA ret(this_.val - gd.getVal());
    myprintf("friend operator << (GeoData) %d\n", ret.getVal());
    return ret;
  }
  friend ShiftA operator<<(const ShiftA& this_, int amount) {
    ShiftA ret(this_.val - amount);
    myprintf("friend operator << (int) %d\n", ret.getVal());
    return ret;
  }
#if defined(SWIG)
%extend {
  ShiftA operator<<(const ShiftA& gd) { return *$self << gd; }
  ShiftA operator<<(int amount) { return *$self << amount; }
}
#endif
#endif
  int getVal() const { return val; }
};

class ShiftB {
  int val;
public:
  ShiftB(int val = 0) : val(val) {}
#if !defined(FRIENDS)
  ShiftB operator<<(const ShiftB& gd) {
    ShiftB ret(val - gd.getVal());
    myprintf("member operator << (GeoData) %d\n", ret.getVal());
    return ret;
  }
  ShiftB operator<<(int amount) {
    ShiftB ret(val - amount);
    myprintf("member operator << (int) %d\n", ret.getVal());
    return ret;
  }
#else
  friend ShiftB operator<<(const ShiftB& this_, const ShiftB& gd) {
    ShiftB ret(this_.val - gd.getVal());
    myprintf("friend operator << (GeoData) %d\n", ret.getVal());
    return ret;
  }
  friend ShiftB operator<<(const ShiftB& this_, int amount) {
    ShiftB ret(this_.val - amount);
    myprintf("friend operator << (int) %d\n", ret.getVal());
    return ret;
  }
#if defined(SWIG)
%extend {
  ShiftB operator<<(const ShiftB& gd) { return *$self << gd; }
  ShiftB operator<<(int amount) { return *$self << amount; }
}
#endif
#endif
  int getVal() const { return val; }
};

void sanity_checker_ShiftA() {
  ShiftA gd1(20);
  ShiftA gd2(100);
  ShiftA gd3(gd2 << gd1);
  myprintf("gd3 %d\n", gd3.getVal());
  ShiftA gd4(gd2 << 30);
  myprintf("gd4 %d\n", gd4.getVal());

}
void sanity_checker_ShiftB() {
  ShiftB gd1(20);
  ShiftB gd2(100);
  ShiftB gd3(gd2 << gd1);
  myprintf("gd3 %d\n", gd3.getVal());
  ShiftB gd4(gd2 << 30);
  myprintf("gd4 %d\n", gd4.getVal());
}

}
%}
