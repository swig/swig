/**
 * To create a wrapped caller, instantiate  _SWIG_call_std_function.
 * For example for
 *   int(double, double):
 * %template(myWrappedCaller) _SWIG_call_std_function<int, double, double>;
 * This will produce a wrapper that expects three arguments:
 *   a wrapped function object and two doubles,
 *   and returns an integer.
 */

namespace std {
  template <typename> class function {};
  template <typename RET, typename... ARGS> class function<RET(ARGS...)> {
    public:
    function() = default;
  };
}

%inline %{
template <typename RET, typename... ARGS>
RET _SWIG_call_std_function(std::function<RET(ARGS...)> fn, ARGS ...args) {
  return fn(args...);
}
%}
