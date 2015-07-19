%module cpp_using_type_aliasing

namespace Space {
  template<typename T> struct Okay {
  };
  struct User {
  protected:
    using OkayInt = Okay<int>;
  };
  struct Derived : User {
    Okay<OkayInt> ff();
  };
};
