// Tests SWIG's *default* handling of varargs.  The default behavior is to simply ignore the varargs.
%module varargs

%varargs(int mode = 0) test_def;

%inline %{
char *test(const char *fmt, ...) {
  return (char *) fmt;
}

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
};

%}
