/* -----------------------------------------------------------------------------
 * std_function.i
 *
 * Generic std::function wrappers.
 *
 * To use std::function
 *  1. Provide a factory function that will return the C++ callable std::function
 *     required.
 *  2. Instantiate the std::function template with a suitable parameter pack.
 *
 * Example:
 *   std::function<bool(int, const std::string &)> MakeLambda(int pass) {
 *     return [pass](int passcode, const std::string &name) -> bool {
 *       return passcode == pass && name == "magic";
 *     };
 *   }
 *   %template(MyLambda) std::function<bool(int, const std::string &)>;
 *
 * Instantiate it and call the operator() wrapper (renamed to call), for example
 * from Java:
 *
 *   MyLambda fn = MakeLambda(10);
 *   boolean result = fn.call(10, "magic");
 * ----------------------------------------------------------------------------- */

%rename(call) std::function::operator();
%ignore std::function::function();

namespace std {
  template <typename> class function;
  template <typename RET, typename... ARGS> class function<RET(ARGS...)> {
  public:
    using result_type = RET;

    function() = default;
    RET operator()(ARGS...) const;
  };
}
