/* File : example.i */
%module example

%typemap(argout) (int &x, int &y) {
  swig_result = caml_list_append(swig_result, caml_val_int(*$1));
  swig_result = caml_list_append(swig_result, caml_val_int(*$2));
}

%{
extern "C" void   factor(int &x, int &y);
%}

extern "C" void   factor(int &x, int &y);
