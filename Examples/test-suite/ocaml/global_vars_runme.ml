open Swig
open Global_vars

_init '()

let _ =
  assert (_b '() as string = "string b");
  assert (_b '("a string value") as string = "a string value");
  assert (_b '() as string = "a string value");
  assert (_x '() as int = 1234);
  assert (_x '(9876) as int = 9876);
  assert (_x '() as int = 9876);
  assert (_Hi '() as int = 0);
  assert (_Hola '() as int = 1);
;;
