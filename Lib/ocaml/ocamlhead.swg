%insert(runtime) %{
  #include <stdlib.h>
  #include <string.h>
  #include <stdio.h>

  /* Including OCaml system. */
  #define CAML_VALUE value
  #include <caml/alloc.h>
  #include <caml/custom.h>
  #include <caml/mlvalues.h>
  #include <caml/memory.h>
  #include <caml/callback.h>
  #include <caml/fail.h>
  #include <caml/misc.h>

  #define SWIG_CAMLlocal1(x) \
    CAML_VALUE x = 0; \
    CAMLxparam1 (x)

  #define SWIG_CAMLlocal2(x, y) \
    CAML_VALUE x = 0, y = 0; \
    CAMLxparam2 (x, y)

  #define SWIG_CAMLlocal3(x, y, z) \
    CAML_VALUE x = 0, y = 0, z = 0; \
    CAMLxparam3 (x, y, z)

  #define SWIG_CAMLlocal4(x, y, z, t) \
    CAML_VALUE x = 0, y = 0, z = 0, t = 0; \
    CAMLxparam4 (x, y, z, t)

  #define SWIG_CAMLlocal5(x, y, z, t, u) \
    CAML_VALUE x = 0, y = 0, z = 0, t = 0, u = 0; \
    CAMLxparam5 (x, y, z, t, u)

  #define SWIG_CAMLlocalN(x, size) \
    CAML_VALUE x [(size)] = { 0, /* 0, 0, ... */ }; \
    CAMLxparamN (x, (size))
%}

%insert(runtime) %{

  /* Declarations for custom block operations. */

  /* For more information of Objective Caml custom blocks,
   * consult the Objective Caml manual, section 18.9. */

  static struct custom_operations custom_swigtype_ocaml_operations = {
    "org.homelinux.yziquel.ocaml.swig",
    custom_finalize_default,
    custom_compare_default,
    custom_hash_default,
    custom_serialize_default,
    custom_deserialize_default
  };

%}
