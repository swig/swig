%module csharp_exceptions

%include "exception.i"

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

%csnothrowexception NoThrowException() {
  try {
    $action
  } catch(Ex e) {
    // swallowed
  }
}

%inline %{
// %exception tests
void ThrowByValue()                                     { throw Ex("ThrowByValue"); }
void ThrowByReference()                                 { throw Ex("ThrowByReference"); }
// %csnothrowexception
void NoThrowException()                                 { throw Ex("NoThrowException"); }
// exception specifications
void ExceptionSpecificationValue() throw(Ex)            { throw Ex("ExceptionSpecificationValue"); }
void ExceptionSpecificationReference() throw(Ex&)       { throw Ex("ExceptionSpecificationReference"); }
void ExceptionSpecificationString() throw(const char *) { throw "ExceptionSpecificationString"; }
void ExceptionSpecificationInteger() throw(int)         { throw 20; }
%}

// test exceptions in the default typemaps

// null reference exceptions
%inline %{
void NullReference(Ex& e) {}
void NullValue(Ex e) {}
%}

// enums
%inline %{
enum TestEnum {TestEnumItem};
void ExceptionSpecificationEnumValue() throw(TestEnum) { throw TestEnumItem; }
void ExceptionSpecificationEnumReference() throw(TestEnum&) { throw TestEnumItem; }
%}

// std::string
%include "std_string.i"
%inline %{
void ExceptionSpecificationStdStringValue() throw(std::string) { throw std::string("ExceptionSpecificationStdStringValue"); }
void ExceptionSpecificationStdStringReference() throw(const std::string&) { throw std::string("ExceptionSpecificationStdStringReference"); }
void NullStdStringValue(std::string s) {}
void NullStdStringReference(std::string &s) {}
%}

// Memory leak check (The C++ exception stack was never unwound in the original approach to throwing exceptions from unmanaged code)
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

// test exception pending in the csconstruct typemap
%inline %{
struct constructor {
  constructor(std::string s) {}
  constructor() throw(int) { throw 10; }
};
%}

// test exception pending in the csout typemaps
%typemap(out, canthrow=1) unsigned short ushorttest %{
  $result = $1;
  if ($result == 100) {
    SWIG_CSharpSetPendingException(SWIG_CSharpIndexOutOfRangeException, "don't like 100");
    return $null;
  }
%}
%inline %{
unsigned short ushorttest() { return 100; }
%}

// test exception pending in the csvarout/csvarin typemaps and canthrow attribute in unmanaged code typemaps
%typemap(check, canthrow=1) int numberin, int InOutStruct::staticnumberin %{
  if ($1 < 0) {
    SWIG_CSharpSetPendingException(SWIG_CSharpIndexOutOfRangeException, "too small");
    return $null;
  }
%}
%typemap(out, canthrow=1) int numberout, int InOutStruct::staticnumberout %{
  $result = $1;
  if ($result > 10) {
    SWIG_CSharpSetPendingException(SWIG_CSharpIndexOutOfRangeException, "too big");
    return $null;
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

// test SWIG_exception macro - it must return from unmanaged code without executing any further unmanaged code
%typemap(check, canthrow=1) int macrotest %{
  if ($1 < 0) {
    SWIG_exception(SWIG_IndexError, "testing SWIG_exception macro");
    return $null;
  }
%}
%inline %{
  bool exception_macro_run_flag = false;
  void exceptionmacrotest(int macrotest) {
    exception_macro_run_flag = true;
  }
%}
