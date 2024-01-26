%module exception_memory_leak

%include <std_string.i>
%include <exception.i>

#ifdef SWIGCSHARP
  #define TYPEMAP_OUT_INIT $result = 0;
#else
  #ifdef VOID_Object
    #define TYPEMAP_OUT_INIT $result = VOID_Object;
  #else
    #define TYPEMAP_OUT_INIT
  #endif
#endif

%typemap(in) Foo* foo
{
  $1 = new Foo;
}
%typemap(freearg) Foo* foo
{
  Foo::inc_freearg_count();
  delete $1;
}

#ifdef SWIG_STD_STRING
%typemap(freearg) const std::string &
{
  Foo::inc_freearg_string_count();
  delete $1;
}
#endif
%typemap(freearg) const char *
{
  Foo::inc_freearg_char_count();
  delete[] $1;
}

%typemap(out) Foo* trigger_internal_swig_exception
{
  TYPEMAP_OUT_INIT
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
  TYPEMAP_OUT_INIT
  SWIG_exception(SWIG_RuntimeError, "Let's see how the bindings manage this exception!");
#ifdef SWIG_fail
  SWIG_fail;
#endif
}
%typemap(out) Foo trigger_internal_swig_exception_c = Foo trigger_internal_swig_exception;

// Throwing constructor
%catches(int) ThrowingCtorChar;
%catches(int) ThrowingCtorString;
%catches(int) ThrowingCtorOverloaded;

%inline %{
  #include <string>

  class Foo {
      static unsigned count;
      static unsigned freearg_count;
      static unsigned freearg_string_count;
      static unsigned freearg_char_count;
    public:
      Foo() { ++count; }
      ~Foo() { --count; }
      static unsigned get_count() { return count; }
      static unsigned get_freearg_count() { return freearg_count; }
      static unsigned get_freearg_string_count() { return freearg_string_count; }
      static unsigned get_freearg_char_count() { return freearg_char_count; }
#ifndef SWIG
      static void inc_freearg_count() { ++freearg_count; }
      static void inc_freearg_string_count() { ++freearg_string_count; }
      static void inc_freearg_char_count() { ++freearg_char_count; }
#endif
  };

  unsigned Foo::count = 0;
  unsigned Foo::freearg_count = 0;
  unsigned Foo::freearg_string_count = 0;
  unsigned Foo::freearg_char_count = 0;

  static Foo* trigger_internal_swig_exception(const std::string& message, Foo* foo)
  {
    return (message == "null") ? NULL : foo;
  }

  static Foo trigger_internal_swig_exception(const std::string& message)
  {
    return Foo();
  }

  static Foo trigger_internal_swig_exception_c(char const* message)
  {
    return Foo();
  }

  struct ThrowingCtorString {
    ThrowingCtorString(const std::string &) { throw (int)1; };
  };
  struct ThrowingCtorChar {
    ThrowingCtorChar(const char *) { throw (int)2; };
  };
  struct ThrowingCtorOverloaded {
    ThrowingCtorOverloaded(const std::string &) { throw (int)3; };
    ThrowingCtorOverloaded(int) { throw (int)4; };
  };
%}
