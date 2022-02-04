%module using2

%warnfilter(SWIGWARN_PARSE_USING_UNDEF);

using ::baz;

%warnfilter(SWIGWARN_RUBY_WRONG_NAME) X::_FooImpl;	/* Ruby, wrong class name */
#ifdef SWIGFORTRAN
%rename(FooImpl) X::_FooImpl;   /* Fortran CANNOT have class names with leading underscores */
#endif

%inline %{

namespace X {
  typedef int Integer;

  class _FooImpl {
  public:
      typedef Integer value_type;
  };
  typedef _FooImpl Foo;
}

namespace Y = X;
using Y::Foo;

int spam(Foo::value_type x) { return x; }

 
%}
