(* -*- tuareg -*- *)
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
      C_bool b -> if b then 1 else 0
    | C_char c
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

let rec get_float x = 
  match x with
      C_char c
    | C_uchar c -> (float_of_int (int_of_char c))
    | C_short s -> (float_of_int s)
    | C_ushort s -> (float_of_int s)
    | C_int s -> (float_of_int s)
    | C_uint u
    | C_int32 u -> (float_of_int (Int32.to_int u))
    | C_int64 u -> (float_of_int (Int64.to_int u))
    | C_float f -> f
    | C_double d -> d
    | C_obj o -> (try (get_float (o "float" C_void))
		  with _ -> (get_float (o "double" C_void)))
    | _ -> raise (Failure "Can't convert to float")

let rec get_char x =
  (char_of_int (get_int x))

let rec get_string x = 
  match x with 
      C_string str -> str
    | _ -> raise (Failure "Can't convert to string")

let rec get_bool x = 
  match x with
      C_bool b -> b
    | _ -> 
	(try if get_int x != 0 then true else false
	 with _ -> raise (Failure "Can't convert to bool"))
      
let addr_of obj = (invoke obj) "&" C_void
let _ = Callback.register "caml_obj_ptr" addr_of

let make_float f = C_float f
let make_double f = C_double f
let make_string s = C_string s
let make_bool b = C_bool b
let make_char c = C_char c
let make_char_i c = C_char (char_of_int c)
let make_uchar c = C_uchar c
let make_uchar_i c = C_uchar (char_of_int c)
let make_short i = C_short i
let make_ushort i = C_ushort i
let make_int i = C_int i
let make_uint i = C_uint (Int32.of_int i)
let make_int32 i = C_int32 (Int32.of_int i)
let make_int64 i = C_int64 (Int64.of_int i)
