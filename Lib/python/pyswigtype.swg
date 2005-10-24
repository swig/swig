/* ------------------------------------------------------------
 * --- Consttab --- needed for callbacks, it should be removed later.
 * ------------------------------------------------------------ */

%typemap(consttab) SWIGTYPE ((*)(ANY))  
{ SWIG_PY_POINTER, (char*)"$symname", 0, 0, (void *)($value), &$descriptor }

%typemap(constcode) SWIGTYPE ((*)(ANY)) "";

