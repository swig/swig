open Swig
open Director_enum

let director_enum_MyFoo ob meth args =
  match meth with
    | "say_hi" ->
      (match args with
         | C_list [ C_enum `hello ] -> C_enum `yo
         | C_list [ C_enum `yo ] -> C_enum `awright
         | _ -> raise (Failure meth))
    | "say_hi_ref" ->
      (match args with
         | C_list [ C_enum `hi ] -> C_enum `hello
         | _ -> raise (Failure meth))
    | "say_bye" ->
      (match args with
         | C_list [ C_enum `aufwiedersehen ] -> C_enum `adios
         | _ -> raise (Failure meth))
    | _ -> (invoke ob) meth args

let _ =
  let a = new_derived_object new_Foo (director_enum_MyFoo) '() in
  assert (a -> ping ((C_enum `hello)) = C_enum `yo);
  assert (a -> ping ((C_enum `yo)) = C_enum `awright);
  assert (a -> ping_ref ((C_enum `hi)) = C_enum `hello);
  assert (a -> ping_member_enum ((C_enum `aufwiedersehen)) = C_enum `adios);
  assert (a -> say_hello ((C_enum `hi)) = C_enum `hello);
  let b = new_Foo '() in
  assert (b -> ping ((C_enum `awright)) = C_enum `awright);
  assert (b -> ping_ref ((C_enum `yo)) = C_enum `yo);
  assert (b -> say_hi_ref ((C_enum `awright)) = C_enum `awright);
  assert (b -> ping_member_enum ((C_enum `adios)) = C_enum `adios);
;;
