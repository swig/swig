%module exception_partial_info

// This produced compilable code for Tcl, Python in 1.3.27, fails in 1.3.29

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW(TYPES...) throw(TYPES)
%{
#define TESTCASE_THROW(TYPES...)
%}

%{
class myException
{
   public:
      virtual const char *name() = 0;
};

class ex1 : public myException
{
   public:
      virtual const char *name() { return "ex1"; }
};

class ex2 : public myException
{
   public:
      virtual const char *name()  { return "ex2"; }
};
%}

#if !defined(SWIGUTL)

#if !defined(SWIGCHICKEN)

%inline %{
class Impl
{
   public:
      void f1() TESTCASE_THROW(myException) { ex1 e; throw e; }
      void f2() TESTCASE_THROW(myException) { ex2 e; throw e; }
};
%}

#else
#warning "Chicken needs fixing for partial exception information"
#endif

#else
#warning "UTL needs fixing for partial exception information"
#endif

