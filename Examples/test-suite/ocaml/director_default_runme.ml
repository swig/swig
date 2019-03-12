open Swig
open Director_default

let director_default_MyFoo ob meth args =
  match meth with
      "Msg" -> (match args with
                  | C_list [ msg ] -> C_string ("director_default_MyFoo-" ^ (msg as string))
                  | _ -> raise (Failure "director_default_MyFoo::Msg()"))
    | _ -> (invoke ob) meth args

let _ =
  let a = new_derived_object new_Foo (director_default_MyFoo) '(10) in
  assert (a -> GetMsg () as string = "director_default_MyFoo-default");
  assert (a -> GetMsg ("boo") as string = "director_default_MyFoo-boo");
  let f = new_Foo '(10) in
  assert (f -> GetMsg () as string = "Foo-default");
  assert (f -> GetMsg ("boo") as string = "Foo-boo");

  let b = new_Bar '(1) in
  assert (b -> GetMsg () as string = "Bar-default");
  assert (b -> GetMsg ("boo") as string = "Bar-boo");
  let b2 = new_Bar '() in
  assert (b2 -> GetMsg () as string = "Bar-default");
  assert (b2 -> GetMsg ("boo") as string = "Bar-boo");
;;
