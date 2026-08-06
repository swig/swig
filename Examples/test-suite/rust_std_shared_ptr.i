%module rust_std_shared_ptr

%include <std_shared_ptr.i>

%inline %{
#include <memory>

struct RustSharedThing {
  RustSharedThing() : value(0) {
  }
  RustSharedThing(int value) : value(value) {
  }
  int value;
};

std::shared_ptr<RustSharedThing> rust_make_shared_thing(int value) {
  return std::shared_ptr<RustSharedThing>(new RustSharedThing(value));
}

int rust_shared_thing_value(std::shared_ptr<RustSharedThing> thing) {
  return thing ? thing->value : -1;
}

void rust_shared_thing_set(std::shared_ptr<RustSharedThing> thing, int value) {
  thing->value = value;
}
%}

%shared_ptr(RustSharedThing)
