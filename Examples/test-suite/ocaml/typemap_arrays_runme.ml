open Swig
open Typemap_arrays

let _ = assert (_sumA '(0) as int = 60)
let _ = assert (_gridSize '(0) as int = 12)
let _ = assert (_rowSize '(0) as int = 6)
