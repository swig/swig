open Swig
open Extend_constructor_destructor

let check o v =
  assert ((o -> "[ivar]" () as int) = v);
  ignore (o -> "~" ());
  assert ((_globalVar '() as int) = -v)

let ctors = [new_AStruct; new_BStruct; new_CStruct; new_DStruct; new_EStruct;
             new_FStruct; new_GStruct]

let _  = List.iteri (fun i c -> let j = succ i in check (c (C_int j)) j) ctors
