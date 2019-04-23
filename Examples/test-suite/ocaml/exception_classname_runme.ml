open Swig
open Exception_classname

let a = new_Exception '()
assert (a -> testfunc () as int = 42)
