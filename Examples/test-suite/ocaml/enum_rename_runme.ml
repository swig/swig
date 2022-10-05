open Swig
open Enum_rename

let mydec = C_enum `M_Dec
let _ = assert (((enum_to_int `Month mydec)) = C_int 2)
let _ = assert (((int_to_enum `Month 2)) = C_enum `M_Dec)

let mymay = C_enum `May
let _ = assert (((enum_to_int `Month mymay)) = C_int 1)
let _ = assert (((int_to_enum `Month 1)) = C_enum `May)
