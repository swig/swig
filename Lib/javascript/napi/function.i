template <typename RET, typename... ARGS> class SWIG_function {};

%template(CPPFunctionType) SWIG_function<std::string, int, const std::string &>;

%{
#include <functional>
template <typename RET, typename... ARGS>
using SWIG_function = std::function<RET(ARGS...)>;
%}

%inline {
  template <typename RET, typename ...ARGS>
  RET __SWIG_CallCPPFunction(SWIG_function<RET, ARGS...> &fn, ARGS ...args) {
    return fn(args...);
  }
  
  template <typename RET, typename...ARGS>
  RET __SWIG_CallCFunction(RET (*fn)(ARGS...), ARGS ...args) {
    return fn(args...);
  }
}

%template(CallCPPFunction) __SWIG_CallCPPFunction<std::string, int, const std::string &>;
%template(CallCFunction)   __SWIG_CallCFunction<char *, int, const char *>;
