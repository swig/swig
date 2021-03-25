open Swig
open Extend_typedef_class

let test_obj o v =
  let cint = C_int v in
  let _ = o -> "[membervar]" (cint) in
  assert ((o -> "getvar" () as int) = v)

let ctors = [new_AClass; new_BClass; new_CClass; new_DClass; new_AStruct;
             new_BStruct; new_CStruct; new_DStruct]

let _  = List.iteri (fun i c -> test_obj (c '()) i) ctors
