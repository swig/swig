%insert(mli) %{
type c_obj = c_enum_tag c_obj_t

exception BadArgs of string
exception BadMethodName of c_obj * string * string
exception NotObject of c_obj
exception NotEnumType of c_obj
exception LabelNotFromThisEnum of c_obj

val invoke : c_obj -> (string -> c_obj -> c_obj)
%}

%insert(ml) %{
type c_obj = c_enum_tag c_obj_t

exception BadArgs of string
exception BadMethodName of c_obj * string * string
exception NotObject of c_obj
exception NotEnumType of c_obj
exception LabelNotFromThisEnum of c_obj
%}