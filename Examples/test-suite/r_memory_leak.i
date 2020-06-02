%module r_memory_leak

%include <std_string.i>

%typemap(in) Foo* foo
{
  $1 = new Foo;
}
%typemap(freearg) Foo* foo
{
  printf("    \"        Object deleted\"\n");
  delete $1;
}
%typemap(out) Foo* verify_no_memory_leak
{
  if ($1 == NULL)
    SWIG_exception_fail(SWIG_RuntimeError, "Let's see how the bindings manage this exception!");
}
%typemap(scoerceout) Foo*
  %{ if (!is.null($result) && !is.logical($result)) {$result <- new("$R_class", ref=$result) ;}; %}

%inline %{
  #include <string>

  class Foo {
      static unsigned count;
    public:
      Foo() { ++count; }
      ~Foo() { --count; }
      static unsigned get_count() { return count; }
  };

  unsigned Foo::count = 0;

  static Foo* trigger_internal_swig_exception(const std::string& message, Foo* foo)
  {
    return (message == "null") ? NULL : foo;
  };

%}
