// Tests SWIG's *default* handling of varargs.  The default behavior is to simply ignore the varargs.
%module varargs

%inline %{

char *test(const char *fmt, ...) {
  return (char *) fmt;
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
