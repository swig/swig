(* Test the unions example... *)

open Unions 

let a = new_SmallStruct C_void
let b = new_BigStruct C_void
let c = new_UnionTest C_void
let d = new_EmbeddedUnionTest C_void 

let _ = (invoke a) "jill_set" (C_short 3)
let _ = (invoke b) "jack_set" (C_char 'a')  (* Int conversion *)
let _ = (invoke b) "smallstruct_set" a      (* Put a in b *)
let _ = (invoke c) "bs_set" b

let _ = if get_int ((invoke a) "jill_get" C_void) != 3 then
	raise (Failure "jill value is not preserved")
let _ = if get_int ((invoke b) "jack_get" C_void) != (int_of_char 'a') then
	raise (Failure "jack value is not preserved")
let _ = if get_int ((invoke ((invoke b) "smallstruct_get" C_void))
	"jill_get" C_void) != 3 then
	raise (Failure "jill value is not embedded in bigstruct")
let _ = if get_int ((invoke ((invoke c) "bs_get" C_void))
	"jack_get" C_void) != (int_of_char 'a') then
	raise (Failure "union set of bigstruct did not take")
let _ = if get_int ((invoke ((invoke c) "ss_get" C_void))
	"jill_get" C_void) != (int_of_char 'a') then
	raise (Failure "corresponding union values are not the same")
