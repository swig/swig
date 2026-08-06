%module rust_std_auto_ptr

%include <std_auto_ptr.i>

%inline %{
#if defined(__clang__)
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#elif defined(__GNUC__)
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#endif
#define _LIBCPP_DISABLE_DEPRECATION_WARNINGS
#include <memory>

struct AutoThing {
  AutoThing(int value) : value(value) {
  }

  int value;
};

std::auto_ptr<AutoThing> rust_make_auto_thing(int value) {
  return std::auto_ptr<AutoThing>(new AutoThing(value));
}

int rust_take_auto_thing(std::auto_ptr<AutoThing> thing) {
  return thing->value;
}
%}

%auto_ptr(AutoThing)
