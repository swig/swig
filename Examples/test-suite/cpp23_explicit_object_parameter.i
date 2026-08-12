%module cpp23_explicit_object_parameter

// C++23 explicit object parameters ("deducing this").  A member function can declare its first
// parameter with the 'this' specifier, naming the object the function is called on.  That parameter
// is not one of the function's arguments, so the wrapped method takes only the parameters declared
// after it - the object is passed the same way it is for an ordinary member function.

// A lambda can have an explicit object parameter too, but a lambda is wrapped as an opaque object.
%warnfilter(SWIGWARN_CPP11_LAMBDA) recurse;

%inline %{
struct Counter {
  int value;

  Counter() : value(10) {}

  // Explicit object parameter by lvalue reference.
  int by_lvalue_ref(this Counter &self) { return self.value + 1; }

  // Explicit object parameter by const lvalue reference.
  int by_const_ref(this const Counter &self) { return self.value + 2; }

  // Explicit object parameter by value.
  int by_value(this Counter self) { return self.value + 3; }

  // Deduced explicit object parameter.  This is a function template in C++, but the object type is
  // deduced from the object the wrapper passes, so it wraps as an ordinary member function.
  int deduced(this auto &&self) { return self.value + 4; }

  // Deduced explicit object parameter with a trailing return type.
  auto deduced_trailing(this auto &&self) -> int { return self.value + 5; }

  // Ordinary parameters follow the explicit object parameter and are the only arguments wrapped.
  int add(this Counter &self, int a, int b) { return self.value + a + b; }

  // Declaration and out of class definition.
  int declared_only(this Counter &self);

  // An ordinary member function and a static member function declared after a member function with
  // an explicit object parameter are unaffected by it.
  int implicit_object() const { return value + 8; }
  static int no_object() { return 9; }
};

inline int Counter::declared_only(this Counter &self) { return self.value + 7; }

// A member function returning a pointer, so that the declarator is not the simplest form.
struct Chain {
  int value;

  Chain() : value(20) {}

  Chain *self_ptr(this Chain &self) { return &self; }
};

// A lambda with an explicit object parameter, the usual way of writing a recursive lambda.
auto recurse = [](this auto&& self, int n) -> int { return n <= 1 ? 1 : n * self(n - 1); };
%}
