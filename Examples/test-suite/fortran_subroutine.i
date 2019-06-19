%module fortran_subroutine

// Treat the struct as a native fortran struct rather than as a class with
%fortransubroutine *::val;
%fortransubroutine Foo<int>::treble;
%fortransubroutine multiply;
%fortransubroutine already_a_subroutine;
%fortransubroutine make_foo;

// Note: feature has to be disabled even though the function is renamed
%rename(get_val) *::val() const;
%nofortransubroutine *::val() const;

// Since make_foo returns a class, it is prohibited from turning into a subroutine
%warnfilter(SWIGWARN_FORTRAN_NO_SUBROUTINE) make_foo;

%inline %{

template<class T>
class Foo {
  T val_;
 public:
  T val() const { return val_; }
  void val(T newval) { val_ = newval; }

  // Triple the stored value if positive, return error code
  int treble() {
    if (val_ < 0)
      return 1;
    val_ *= 3;
    return 0;
  }
};

Foo<int> make_foo(int val) {
  Foo<int> result;
  result.val(val);
  return result;
}

int multiply(int a, int b) {
  return a * b;
}

void already_a_subroutine(int a, int &b) {
  b = a;
}

bool still_a_function() { return true; }
%}

%template(FooInt) Foo<int>;
