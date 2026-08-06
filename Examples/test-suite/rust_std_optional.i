%module rust_std_optional

%include <std_optional.i>

%inline %{
#include <optional>

struct RustOptionalThing {
  RustOptionalThing() : value(0) {
  }
  RustOptionalThing(int value) : value(value) {
  }
  int get_value() const {
    return value;
  }
  int value;
};
%}

%optional(RustOptionalThing)

%inline %{
std::optional<RustOptionalThing> rust_make_optional_thing(int value) {
  return RustOptionalThing(value);
}

std::optional<RustOptionalThing> rust_make_empty_optional_thing() {
  return std::nullopt;
}

int rust_optional_thing_value(std::optional<RustOptionalThing> value) {
  return value ? value->get_value() : -1;
}
%}
