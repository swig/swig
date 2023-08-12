%module using2

%warnfilter(SWIGWARN_PARSE_USING_UNDEF) ::baz;

using ::baz;

%inline %{

namespace X {
  typedef int Integer;

  class FooImpl_ {
  public:
      typedef Integer value_type;
  };
  typedef FooImpl_ Foo;
}

namespace Y = X;
using Y::Foo;

int spam(Foo::value_type x) { return x; }

 
%}
