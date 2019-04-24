open Swig
open Director_exception

exception MyException of string * string

let director_exception_MyFoo ob meth args =
  match meth with
      "ping" -> raise (Failure "MyFoo::ping() EXCEPTION")
    | _ -> (invoke ob) meth args

let director_exception_MyFoo2 ob meth args =
  match meth with
      "ping" -> (C_bool true)
    | _ -> (invoke ob) meth args

let director_exception_MyFoo3 ob meth args =
  match meth with
      "ping" -> raise (MyException ("foo", "bar"))
    | _ -> (invoke ob) meth args

(* Check that Failure is raised by MyFoo.ping() (via MyFoo.pong()). *)
let a =
  new_derived_object
    new_Foo (director_exception_MyFoo) '()
let a = _launder(a)
try
  let _ = a -> pong () in assert false
with Failure s -> assert(s = "MyFoo::ping() EXCEPTION")

let a =
  new_derived_object
    new_Foo (director_exception_MyFoo2) '()
let a = _launder(a)
try
  let _ = a -> pong () in assert false
with Failure s -> assert(s = "No appropriate conversion found.")

let a =
  new_derived_object
    new_Foo (director_exception_MyFoo3) '()
let a = _launder(a)
try
  let _ = a -> pong () in assert false
with MyException (s1, s2) ->
  assert (s1 = "foo");
  assert (s2 = "bar");
