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

// test csconstruct  and all the csout typemaps
