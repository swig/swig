open Swig
open Template_opaque

let v = new_OpaqueVectorType (C_uint 10l)
let _ = _FillVector '(v)
