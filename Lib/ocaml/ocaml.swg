%include <ocamlhead.swg>

%typemap(ocamlout) SWIGTYPE "Obj.t"
%typemap(out) SWIGTYPE
  { $result = caml_alloc_custom(&custom_swigtype_ocaml_operations, sizeof (void *), 0 ,1);
    *((void **) Data_custom_val($result)) = new $1_ltype((const $1_ltype &)$1);
  }

%typemap(ocamlout) SWIGTYPE * "Obj.t"
%typemap(out) SWIGTYPE *
  { $result = caml_alloc_custom(&custom_swigtype_ocaml_operations, sizeof (void *), 0, 1);
    *((void **) Data_custom_val($result)) = (void *)$1;
  }

%typemap(ocamlin) SWIGTYPE * "Obj.t"
%typemap(in) SWIGTYPE *
  %{ $1 = *(($1_ltype *) Data_custom_val($input)); %}
