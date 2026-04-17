/* -----------------------------------------------------------------------------
 * std_function.i
 *
 * Generic std::function wrappers.
 *
 * To create a wrapped caller, instantiate SWIG_call_std_function.
 * For example for
 *   int(double, double):
 * %template(my_wrapped_caller) SWIG_call_std_function<int, double, double>;
 * This will produce a wrapper that expects three arguments:
 *   a wrapped function object and two doubles,
 *   and returns an integer.
 * ----------------------------------------------------------------------------- */

namespace std {
  template <typename> class function {};
  /* TODO: Fix bug where the primary template above is instantiated instead of the specialized template below - the operator() is thus not wrapped */
  template <typename RET, typename... ARGS> class function<RET(ARGS...)> {
  public:
    using result_type = RET;

    function() = default;
    RET operator()(ARGS...) const;
  };
}

%inline %{
template <typename RET, typename... ARGS>
RET SWIG_call_std_function(std::function<RET(ARGS...)> fn, ARGS ...args) {
  return fn(args...);
}
%}
