// Tests SWIG's handling of varargs (function varargs, not preprocessor varargs).
// The default behavior is to simply ignore the varargs.
%module varargs

// Default handling of varargs

%{
#include <string.h>
%}

%inline %{
char *test(const char *fmt, ...) {
  return (char *) fmt;
}

struct VarargConstructor {
  char *str;
  VarargConstructor(const char *fmt, ...) {
    str = new char[strlen(fmt) + 1];
    strcpy(str, fmt);
  }
};
%}

// %varargs support

%varargs(int mode = 0) test_def;
%varargs(int mode = 0) Foo::Foo;
%varargs(int mode = 0) Foo::statictest(const char*fmt, ...);
%varargs(2, int mode = 0) test_plenty(const char*fmt, ...);

%inline %{
const char *test_def(const char *fmt, ...) {
  return fmt;
}

class Foo {
public:
    char *str;
    Foo() {
        str = NULL;
    }
    Foo(const char *fmt, ...) {
        str = new char[strlen(fmt) + 1];
        strcpy(str, fmt);
    }
    ~Foo() {
        delete [] str;
    }
    char *test(const char *fmt, ...) {
        return (char *) fmt;
    }
    static char *statictest(const char *fmt, ...) {
        return (char *) fmt;
    }
};

const char *test_plenty(const char *fmt, ...) {
  return fmt;
}
%}
