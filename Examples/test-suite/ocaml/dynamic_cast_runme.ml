open Swig
open Dynamic_cast

let f = new_Foo '()
let b = new_Bar '()

let x = f -> blah ()
let y = b -> blah ()
assert (_do_test '(y) as string = "Bar::test")
