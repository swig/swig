(* -*- tuareg -*- *)
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
  | C_director_core of c_obj * c_obj option ref
exception BadArgs of string
exception BadMethodName of c_obj * string * string
exception NotObject of c_obj
exception NotEnumType of c_obj
exception LabelNotFromThisEnum of c_obj

val invoke : c_obj -> (string -> c_obj -> c_obj)
val get_int : c_obj -> int
val get_float : c_obj -> float
val get_string : c_obj -> string
val get_char : c_obj -> char
val get_bool : c_obj -> bool

val make_float : float -> c_obj
val make_double : float -> c_obj
val make_string : string -> c_obj
val make_bool : bool -> c_obj
val make_char : char -> c_obj
val make_char_i : int -> c_obj
val make_uchar : char -> c_obj
val make_uchar_i : int -> c_obj
val make_short : int -> c_obj
val make_ushort : int -> c_obj
val make_int : int -> c_obj
val make_uint : int -> c_obj
val make_int32 : int -> c_obj
val make_int64 : int -> c_obj
