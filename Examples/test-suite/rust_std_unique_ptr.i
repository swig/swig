%module rust_std_unique_ptr

%include <std_unique_ptr.i>

%inline %{
#include <memory>

struct RustUniqueThing {
  RustUniqueThing() : value(0) {
  }
  RustUniqueThing(int value) : value(value) {
  }
  int value;
};
%}

%unique_ptr(RustUniqueThing)

%inline %{
std::unique_ptr<RustUniqueThing> rust_make_unique_thing(int value) {
  return std::unique_ptr<RustUniqueThing>(new RustUniqueThing(value));
}

int rust_unique_thing_value(const std::unique_ptr<RustUniqueThing> &thing) {
  return thing ? thing->value : -1;
}

int rust_take_unique_thing(std::unique_ptr<RustUniqueThing> thing) {
  return thing ? thing->value : -1;
}
%}
