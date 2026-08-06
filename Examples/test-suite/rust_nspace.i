%module rust_nspace

%nspace;

%inline %{
namespace outer {

enum Kind {
  KindSmall = 1,
  KindLarge = 2
};

class Thing {
public:
  Thing(int value) : value_(value) {
  }

  int value() const {
    return value_;
  }

  Kind kind() const {
    return KindLarge;
  }

private:
  int value_;
};

namespace inner {

class Nested {
public:
  Nested(int value) : value_(value) {
  }

  int value() const {
    return value_;
  }

private:
  int value_;
};

}

}

outer::Thing *make_outer_thing(int value) {
  return new outer::Thing(value);
}

int read_outer_thing(outer::Thing *thing) {
  return thing ? thing->value() : -1;
}
%}

%newobject make_outer_thing;
