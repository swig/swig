// This testcase checks SWIG's support for the 'decltype(auto)' placeholder introduced in C++14.
// It stands wherever the 'auto' placeholder does, but unlike 'auto' it deduces the declared type
// of the initialiser exactly, keeping any reference.
%module cpp14_decltype_auto

// A deduced return type cannot be deduced from the body, which SWIG does not analyse, so each of
// these is ignored with warning 345.
%warnfilter(SWIGWARN_CPP14_AUTO) ret_plain;
%warnfilter(SWIGWARN_CPP14_AUTO) ret_trailing;
%warnfilter(SWIGWARN_CPP14_AUTO) Klass::mem;
%warnfilter(SWIGWARN_CPP14_AUTO) Klass::operator decltype(auto)();

%warnfilter(SWIGWARN_CPP11_LAMBDA) lambda_dauto;

// The deduced reference variables are settable, which is what warning 454 is about.
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) var_ref;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) global_ref;

%inline %{
int global_int = 42;
int &global_ref = global_int;

// Deduced from the initialiser, exactly as an 'auto' variable is.
decltype(auto) var_int = global_int;

// 'decltype(auto)' keeps the reference that 'auto' would drop.
decltype(auto) var_ref = global_ref;

const int global_const = 7;
decltype(auto) var_const = global_const;

// Return types, all ignored as the type would have to come from the body.
decltype(auto) ret_plain() { return global_int; }
auto ret_trailing() -> decltype(auto);

struct Klass {
  int v;

  explicit Klass(int v_) : v(v_) { }

  decltype(auto) mem() { return v; }

  // A conversion function cannot have a trailing return type, so this is ignored too.
  operator decltype(auto)() { return v; }

  int plain() const { return v; }
};

// A lambda is wrapped as an opaque object whatever its return type is spelt as.
auto lambda_dauto = [](int x) -> decltype(auto) { return x; };
%}
