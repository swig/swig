%module typemap_ns_using

%warnfilter(801) X::_FooImpl;	/* Ruby, wrong class name */

%inline %{
namespace X {
  typedef int Integer;

  class _FooImpl {
  public:
      typedef Integer value_type;
  };
  typedef _FooImpl Foo;
}

using X::Foo;

int spam(Foo::value_type x) { return x; }

%}

