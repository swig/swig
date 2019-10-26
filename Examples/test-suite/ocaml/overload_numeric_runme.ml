open Swig
open Overload_numeric

let _ =
  let n = new_Nums '() in
  let arg = C_char 'c' in
  assert (n -> over (arg) as string = "signed char");
  let arg = C_short 2 in
  assert (n -> over (arg) as string = "short");
  assert (n -> over (2) as string = "int");
  let arg = C_float 2. in
  assert (n -> over (arg) as string = "float");
  assert (n -> over (2.) as string = "double")
;;
