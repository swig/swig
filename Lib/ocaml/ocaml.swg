%include <ocamlhead.swg>

%typemap(out) SWIGTYPE *
  { $result = caml_alloc_custom(&custom_swigtype_ocaml_operations, sizeof (void *), 0, 1);
    *((void **) Data_custom_val($result)) = (void *)$1;
  }
