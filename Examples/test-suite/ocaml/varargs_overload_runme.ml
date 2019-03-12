open Swig
open Varargs_overload

let _ =
  assert (_vararg_over1 '("Hello") as string = "Hello");
  assert (_vararg_over1 '(2) as string = "2");
  assert (_vararg_over2 '("Hello") as string = "Hello");
  assert (_vararg_over2 '(2, 2.2) as string = "2 2.2");

  assert (_vararg_over3 '("Hello") as string = "Hello");
  assert (_vararg_over3 '(2, 2.2, "hey") as string = "2 2.2 hey");
  assert (_vararg_over4 '("Hello") as string = "Hello");
  assert (_vararg_over4 '(123) as string = "123");
  assert (_vararg_over4 '("Hello", 123) as string = "Hello");


  (* Same as above but non-vararg function declared first *)

  assert (_vararg_over6 '("Hello") as string = "Hello");
  assert (_vararg_over6 '(2) as string = "2");
  assert (_vararg_over7 '("Hello") as string = "Hello");
  assert (_vararg_over7 '(2, 2.2) as string = "2 2.2");

  assert (_vararg_over8 '("Hello") as string = "Hello");
  assert (_vararg_over8 '(2, 2.2, "hey") as string = "2 2.2 hey");
  assert (_vararg_over9 '("Hello") as string = "Hello");
  assert (_vararg_over9 '(123) as string = "123");
  assert (_vararg_over9 '("Hello", 123) as string = "Hello");
;;
