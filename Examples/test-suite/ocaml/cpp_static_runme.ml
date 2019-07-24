open Swig
open Cpp_static

let _ = _StaticFunctionTest_static_func (C_void)
let _ = _StaticFunctionTest_static_func_2 (C_int 1)
let _ = _StaticFunctionTest_static_func_3 (C_list [C_int 1; C_int 2])

let _ = assert (get_int (_StaticMemberTest_static_int (C_void)) = 99)
let _ = _StaticMemberTest_static_int (C_int 10)
let _ = assert (get_int (_StaticMemberTest_static_int (C_void)) = 10)

let _ = assert (get_int (_StaticBase_statty (C_void)) = 11)
let _ = assert (get_int (_StaticDerived_statty (C_void)) = 111)
let _ = _StaticBase_statty (C_int 22)
let _ = _StaticDerived_statty (C_int 222)
let _ = assert (get_int (_StaticBase_statty (C_void)) = 22)
let _ = assert (get_int (_StaticDerived_statty (C_void)) = 222)
