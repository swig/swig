var cpp_static = require("cpp_static");

cpp_static.StaticFunctionTest.static_func();
cpp_static.StaticFunctionTest.static_func_2(1);
cpp_static.StaticFunctionTest.static_func_3(1, 2);
cpp_static.StaticMemberTest.static_int = 10;
if (cpp_static.StaticMemberTest.static_int != 10)
  throw new Error;

if (cpp_static.StaticBase.statty !== 11)
  throw new Error;

if (cpp_static.StaticDerived.statty !== 111)
  throw new Error;

if (cpp_static.StaticBase.grab_statty_base() !== 11)
  throw new Error;

if (Object.keys(cpp_static.StaticDerived).length === 1 && typeof print === undefined) {
  // This works only with Node-API where the classes themselves are inherited
  // (only the instances are inherited in raw V8/JSC)
  if (cpp_static.StaticDerived.grab_statty_base() !== 11)
    throw new Error;
}

if (cpp_static.StaticDerived.grab_statty_derived() !== 111)
  throw new Error;
