%module exception_memory_leak

%include <std_string.i>
%include <exception.i>

%typemap(in) Foo* foo
{
  $1 = new Foo;
}
%typemap(freearg) Foo* foo
{
  Foo::inc_freearg_count();
  delete $1;
}
%typemap(out) Foo* trigger_internal_swig_exception
{
  if ($1 == NULL) {
    SWIG_exception(SWIG_RuntimeError, "Let's see how the bindings manage this exception!");
#ifdef SWIG_fail
    SWIG_fail;
#endif
  }
  $1 = NULL;
}
%typemap(out) Foo trigger_internal_swig_exception
{
  SWIG_exception(SWIG_RuntimeError, "Let's see how the bindings manage this exception!");
#ifdef SWIG_fail
  SWIG_fail;
#endif
}

%inline %{
  #include <string>

  class Foo {
      static unsigned count;
      static unsigned freearg_count;
    public:
      Foo() { ++count; }
      ~Foo() { --count; }
      static unsigned get_count() { return count; }
      static unsigned get_freearg_count() { return freearg_count; }
#ifndef SWIG
      static void inc_freearg_count() { ++freearg_count; }
#endif
  };

  unsigned Foo::count = 0;
  unsigned Foo::freearg_count = 0;

  static Foo* trigger_internal_swig_exception(const std::string& message, Foo* foo)
  {
    return (message == "null") ? NULL : foo;
  }

  static Foo trigger_internal_swig_exception(const std::string& message)
  {
    return Foo();
  }

%}
