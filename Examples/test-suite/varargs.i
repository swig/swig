// Tests SWIG's *default* handling of varargs.  The default behavior is to simply ignore the varargs.
%module varargs

%inline %{

char *test(const char *fmt, ...) {
  return (char *) fmt;
}

class Foo {
public:
	char *test(const char *fmt, ...) {
             return (char *) fmt;
        }
};

%}
