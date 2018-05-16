%module catches

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW3(T1, T2, T3) throw(T1, T2, T3)
%{
#define TESTCASE_THROW3(T1, T2, T3)
%}

%include <exception.i> // for throws(...) typemap

%catches(int, const char *, const ThreeException&) test_catches(int i);
%catches(int, ...) test_exception_specification(int i); // override the exception specification
%catches(...) test_catches_all(int i);

%inline %{
struct ThreeException {};
void test_catches(int i) {
  if (i == 1) {
    throw int(1);
  } else if (i == 2) {
    throw (const char *)"two";
  } else if (i == 3) {
    throw ThreeException();
  }
}
void test_exception_specification(int i) TESTCASE_THROW3(int, const char *, const ThreeException&) {
  test_catches(i);
}
void test_catches_all(int i) {
  test_catches(i);
}
%}

