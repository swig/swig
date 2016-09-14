%module exception_classname

%warnfilter(SWIGWARN_RUBY_WRONG_NAME);
#ifdef SWIGPHP
%rename(ExceptionClass) Exception;
#endif

%inline %{
class Exception {
public:
  int testfunc() { return 42; }
};
%}
