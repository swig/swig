open Int32
open Int64

type c_obj = 
    C_void
  | C_bool of bool
  | C_char of char
  | C_uchar of char
  | C_short of int
  | C_ushort of int
  | C_int of int
  | C_uint of int32
  | C_int32 of int32
  | C_int64 of int64
  | C_float of float
  | C_double of float
  | C_ptr of int64 * int64
  | C_array of c_obj array
  | C_list of c_obj list
  | C_obj of (string -> c_obj -> c_obj)
  | C_string of string
  | C_enum of c_enum_tag
exception BadArgs of string
exception BadMethodName of c_obj * string * string
exception NotObject of c_obj
exception NotEnumType of c_obj
exception LabelNotFromThisEnum of c_obj

let invoke obj = match obj with C_obj o -> o | _ -> raise (NotObject obj)
let fnhelper fin f arg =
  let args = match arg with C_list l -> l | C_void -> [] | _ -> [ arg ] in
  match f args with
    [] -> C_void
  | [ x ] -> (if fin then Gc.finalise 
	(fun x -> ignore ((invoke x) "~" C_void)) x) ; x
  | lst -> C_list lst
let rec get_int x = 
  match x with
    C_char c
  | C_uchar c -> (int_of_char c)
  | C_short s
  | C_ushort s
  | C_int s -> s
  | C_uint u
  | C_int32 u -> (Int32.to_int u)
  | C_int64 u -> (Int64.to_int u)
  | C_float f -> (int_of_float f)
  | C_double d -> (int_of_float d)
  | C_ptr (p,q) -> (Int64.to_int p)
  | C_obj o -> (try (get_int (o "int" C_void))
    with _ -> (get_int (o "&" C_void)))
  | _ -> raise (Failure "Can't convert to int")
let addr_of obj = (invoke obj) "&" C_void
let _ = Callback.register "caml_obj_ptr" addr_of
