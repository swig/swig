open Swig
open Extend_template_method

let _ =
  let em = new_ExtendMe '() in
  assert (em -> do_stuff_double (1, 1.1) as float = 1.1);
  assert (em -> do_stuff_string (1, "hello there") as string = "hello there");
  assert (em -> do_overloaded_stuff (1.1) as float = 1.1);
  assert (em -> do_overloaded_stuff ("hello there") as string = "hello there");

  assert (_ExtendMe_static_method '(123) as int = 123);
  ignore (new_ExtendMe '(123));
  let em = new_TemplateExtend '() in
  assert (em -> do_template_stuff_double (1, 1.1) as float = 1.1);
  assert (em -> do_template_stuff_string (1, "hello there") as string = "hello there");
  assert (em -> do_template_overloaded_stuff (1.1) as float = 1.1);
  assert (em -> do_template_overloaded_stuff ("hello there") as string = "hello there");
  assert (_TemplateExtend_static_template_method '(123) as int = 123);
  ignore (new_TemplateExtend '(123))
;;
