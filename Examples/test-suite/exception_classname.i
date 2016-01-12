%module exception_classname

%warnfilter(SWIGWARN_RUBY_WRONG_NAME);

%inline %{
class Exception {
public:
  int testfunc() { return 42; }
};
%}
