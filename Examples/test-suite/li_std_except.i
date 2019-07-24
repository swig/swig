%module li_std_except

%include <std_except.i>

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW1(T1) throw(T1)
%{
#define TESTCASE_THROW1(T1)
%}

%inline %{
  struct E1 : public std::exception
  {
  };

  struct E2 
  {
  };

  struct Test {
    int foo1() TESTCASE_THROW1(std::bad_exception) { return 0; }
    int foo2() TESTCASE_THROW1(std::logic_error) { return 0; }
    int foo3() TESTCASE_THROW1(E1) { return 0; }
    int foo4() TESTCASE_THROW1(E2) { return 0; }
    // all the STL exceptions...
    void throw_bad_cast()         TESTCASE_THROW1(std::bad_cast)          { throw std::bad_cast(); }
    void throw_bad_exception()    TESTCASE_THROW1(std::bad_exception)     { throw std::bad_exception(); }
    void throw_domain_error()     TESTCASE_THROW1(std::domain_error)      { throw std::domain_error("oops"); }
    void throw_exception()        TESTCASE_THROW1(std::exception)         { throw std::exception(); }
    void throw_invalid_argument() TESTCASE_THROW1(std::invalid_argument)  { throw std::invalid_argument("oops"); }
    void throw_length_error()     TESTCASE_THROW1(std::length_error)      { throw std::length_error("oops"); }
    void throw_logic_error()      TESTCASE_THROW1(std::logic_error)       { throw std::logic_error("oops"); }
    void throw_out_of_range()     TESTCASE_THROW1(std::out_of_range)      { throw std::out_of_range("oops"); }
    void throw_overflow_error()   TESTCASE_THROW1(std::overflow_error)    { throw std::overflow_error("oops"); }
    void throw_range_error()      TESTCASE_THROW1(std::range_error)       { throw std::range_error("oops"); }
    void throw_runtime_error()    TESTCASE_THROW1(std::runtime_error)     { throw std::runtime_error("oops"); }
    void throw_underflow_error()  TESTCASE_THROW1(std::underflow_error)   { throw std::underflow_error("oops"); }
  };
%}

