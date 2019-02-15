open Swig
open Global_ns_arg

let _ = assert ((_foo '(1) as int) = 1)
let _ = assert ((_bar_fn '() as int) = 1)
