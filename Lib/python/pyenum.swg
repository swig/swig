/* ------------------------------------------------------------
 *  Enums 
 * ------------------------------------------------------------ */
%apply int { enum SWIGTYPE };
%apply const int& { const enum SWIGTYPE& };


%typemap(varin,fragment=SWIG_AsVal_frag(int)) enum SWIGTYPE
{
  if (sizeof(int) != sizeof($1)) {
    PyErr_SetString(PyExc_AttributeError, "enum variable '$name' can not be set");
    return 1;
  }  
  if (!SWIG_AsVal(int)($input, (int*)(void*)(&$1))) {
    return 1;
  }
}

/* 
   typemaps needed due to unnamed enums
*/
%define PY_ENUM_OUT_TYPEMAPS(from_meth,pyfrag)
  %typemap(out,fragment=pyfrag) enum SWIGTYPE 
   "$result = from_meth(($1));";
  %typemap(out,fragment=pyfrag) const enum SWIGTYPE& 
   "$result = from_meth((*$1));";
  %typemap(varout,fragment=pyfrag) enum SWIGTYPE, const enum SWIGTYPE&  
   "$result = from_meth($1);";
  %typemap(constcode,fragment=pyfrag) enum SWIGTYPE
   "PyDict_SetItemString(d,\"$symname\", from_meth($value));";
  %typemap(directorin,fragment=pyfrag) enum SWIGTYPE *DIRECTORIN 
   "$input = from_meth(*$1_name);";
  %typemap(directorin,fragment=pyfrag) enum SWIGTYPE, const enum SWIGTYPE& 
   "$input = from_meth($1_name);";
  %typemap(throws,fragment=pyfrag) enum SWIGTYPE 
   "PyErr_SetObject(PyExc_RuntimeError, from_meth($1));
    SWIG_fail;";
%enddef

PY_ENUM_OUT_TYPEMAPS(SWIG_From(int),SWIG_From_frag(int));

  




