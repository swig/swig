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

// By default SWIG attempts to rename any symbol called 'function' as it is a reserved keyword in some languages.
// Unfortunately, %namewarn for 'function' (which is essentially a %rename) overrides the %template name.
// The rename could be avoided with a more targed rename, in addition to the %template, such as:
//   %template(MyLambda) std::function<bool(int, const std::string &)>;
// But requires users to give the name twice, instead we use the trick below to effectively ignore the %namewarn.
#if defined(SWIGD) || defined(SWIGJAVASCRIPT) || defined(SWIGLUA) || defined(SWIGPHP) || defined(SWIGR)
// The %namewarn below purposefully omits the 'rename="_%s"' attribute as a trick to not rename
%namewarn("314"":""'function' is a keyword") std::function;
#endif


namespace std {
  template <typename> class function;
  template <typename RET, typename... ARGS> class function<RET(ARGS...)> {
  public:
    using result_type = RET;

    function() = default;
    RET operator()(ARGS...) const;
  };
}
