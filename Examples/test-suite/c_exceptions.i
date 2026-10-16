%module c_exceptions

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW1(T1) throw(T1)
%{
#define TESTCASE_THROW1(T1)
%}

%inline %{
  class Ex {
    const char *message;
  public:
    Ex(const char *msg) : message(msg) {}
    const char *what() { return message; }
  };
%}

%exception ThrowByValue() {
  try {
    $action
  } catch(Ex e) {
    SWIG_exception(SWIG_DivisionByZero, e.what());
  }
}

%exception ThrowByReference() {
  try {
    $action
  } catch(Ex &e) {
    SWIG_exception(SWIG_DivisionByZero, e.what());
  }
}

// no canthrow attribute, as the code does not leave the wrapper
%feature("except") NoFailException() {
  try {
    $action
  } catch(Ex) {
    // swallowed
  }
}

%inline %{
// %exception tests
void ThrowByValue()                                     { throw Ex("ThrowByValue"); }
void ThrowByReference()                                 { throw Ex("ThrowByReference"); }
// %feature("except") without canthrow
void NoFailException()                                  { throw Ex("NoFailException"); }
// exception specifications
void ExceptionSpecificationValue() TESTCASE_THROW1(Ex)            { throw Ex("ExceptionSpecificationValue"); }
void ExceptionSpecificationReference() TESTCASE_THROW1(Ex&)       { throw Ex("ExceptionSpecificationReference"); }
void ExceptionSpecificationString() TESTCASE_THROW1(const char *) { throw "ExceptionSpecificationString"; }
void ExceptionSpecificationInteger() TESTCASE_THROW1(int)         { throw 20; }
int ExceptionSpecificationResult() TESTCASE_THROW1(const char *)  { throw "ExceptionSpecificationResult"; }
%}

// test exceptions in the default typemaps

// null reference exceptions
%inline %{
void NullReference(Ex& e) {}
%}

// enums
%inline %{
enum TestEnum {TestEnumItem};
void ExceptionSpecificationEnumValue() TESTCASE_THROW1(TestEnum) { throw TestEnumItem; }
void ExceptionSpecificationEnumReference() TESTCASE_THROW1(TestEnum&) { throw TestEnumItem; }
%}

// Memory leak check (the destructor of a local variable in %exception code must run when leaving the wrapper after an error)
%exception MemoryLeakCheck() {
  Counter destructor_should_be_called;
  try {
    $action
  } catch(Ex e) {
    SWIG_exception(SWIG_DivisionByZero, e.what());
  }
}

%inline %{
struct Counter {
  static int count;
  Counter() { count++; }
  ~Counter() { count--; }
};
int Counter::count = 0;

void MemoryLeakCheck() {
  throw Ex("testing memory leaks when throwing exceptions");
}
%}

// test an error raised by a constructor
%inline %{
struct constructor {
  constructor() TESTCASE_THROW1(int) { throw 10; }
};
%}

// test an error raised in the out typemap
%typemap(out, canthrow=1) unsigned short ushorttest %{
  $result = $1;
  if ($result == 100) {
    SWIG_CException_Raise(SWIG_IndexError, "don't like 100");
    SWIG_fail;
  }
%}
%inline %{
unsigned short ushorttest() { return 100; }
%}

// test errors raised in the variable getters and setters by the canthrow attribute in typemaps
%typemap(check, canthrow=1) int numberin, int InOutStruct::staticnumberin %{
  if ($1 < 0) {
    SWIG_CException_Raise(SWIG_IndexError, "too small");
    SWIG_fail;
  }
%}
%typemap(out, canthrow=1) int numberout, int InOutStruct::staticnumberout %{
  $result = $1;
  if ($result > 10) {
    SWIG_CException_Raise(SWIG_IndexError, "too big");
    SWIG_fail;
  }
%}
%inline %{
  int numberin;
  int numberout;
  struct InOutStruct {
    int numberin;
    int numberout;
    static int staticnumberin;
    static int staticnumberout;
  };
  int InOutStruct::staticnumberin;
  int InOutStruct::staticnumberout;
%}

// test errors raised in %exceptionvar code, which has the canthrow attribute
%exceptionvar exceptionvar_number {
  $action
  if (exceptionvar_number < 0) {
    SWIG_CException_Raise(SWIG_IndexError, "exceptionvar_number negative");
    SWIG_fail;
  }
}
%exceptionvar ExceptionVarStruct::staticnumber {
  $action
  if (ExceptionVarStruct::staticnumber < 0) {
    SWIG_CException_Raise(SWIG_IndexError, "staticnumber negative");
    SWIG_fail;
  }
}
%inline %{
  int exceptionvar_number = 0;
  struct ExceptionVarStruct {
    static int staticnumber;
  };
  int ExceptionVarStruct::staticnumber = 0;
%}

// test SWIG_exception macro - it must leave the wrapper without executing any further code
%typemap(check, canthrow=1) int macrotest {
  if ($1 < 0) {
    SWIG_exception(SWIG_IndexError, "testing SWIG_exception macro");
  }
}
%inline %{
  bool exception_macro_run_flag = false;
  void exceptionmacrotest(int macrotest) {
    exception_macro_run_flag = true;
  }
%}
