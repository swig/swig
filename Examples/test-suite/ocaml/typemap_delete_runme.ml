open Swig
open Typemap_delete

let r = new_Rect '(123)
let _ = assert (r -> "[val]" () as int = 123)
