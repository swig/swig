var cpp_static = require("cpp_static");

/* await */(cpp_static.StaticFunctionTest.static_func());
/* await */(cpp_static.StaticFunctionTest.static_func_2(1));
/* await */(cpp_static.StaticFunctionTest.static_func_3(1,2));
cpp_static.StaticMemberTest.static_int = 10;
if (cpp_static.StaticMemberTest.static_int != 10)
throw "error";

