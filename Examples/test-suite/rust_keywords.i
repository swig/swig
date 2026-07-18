%module rust_keywords

%nspace;
#pragma SWIG nowarn=SWIGWARN_PARSE_KEYWORD

%include <enums.swg>

%inline %{
int crate(int value) {
  return value + 1;
}

enum async {
  dyn = 1,
  impl = 2
};

async select_async(async value) {
  return value == dyn ? impl : dyn;
}

class type {
public:
  type(int value) : use(value) {
  }

  int match() const {
    return use + 2;
  }

  int use;
};

namespace outer {
namespace mod {

class trait {
public:
  trait(int value) : value_(value) {
  }

  int self() const {
    return value_;
  }

private:
  int value_;
};

}
}
%}
