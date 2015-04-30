/*
This test case checks that all exception throwing and handling produced by
swig's director code can be disabled with SWIG_DIRECTOR_THROW,
SWIG_DIRECTOR_RETHROW, SWIG_DIRECTOR_NO_UEH and
SWIG_DIRECTOR_NO_CATCH_EXCEPTIONS. This is useful for using directors in
environments that do not allow exceptions to be used.

The resulting wrapper code will be compiled with -fno-exceptions to ensure that
no exception code is generated.

Note:
  The generated code may still contain exception specifications which are
  allowed with -fno-exceptions.
 */

%module(directors="1") director_no_stray_exceptions

%insert("begin")
%{

#define SWIG_DIRECTOR_THROW(e)
#define SWIG_DIRECTOR_RETHROW
#define SWIG_DIRECTOR_NO_UEH
#define SWIG_DIRECTOR_NO_CATCH_EXCEPTIONS

class TestClass {
public:
  virtual void TestMethod() = 0;
  virtual ~TestClass() {}
};

%}

%feature("director") TestClass;
class TestClass {
public:
  virtual void TestMethod() = 0;
  virtual ~TestClass();
};
