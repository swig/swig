/* ------------------------------------------------------------
 *  Enums 
 * ------------------------------------------------------------ */
%apply int { enum SWIGTYPE };

%typemap(varin,fragment=SWIG_AsVal_frag(int)) enum SWIGTYPE
{
  if (sizeof(int) != sizeof($1)) {
    PyErr_SetString(PyExc_TypeError, "enum variable '$name' can not be set");
    return 1;
  }  
  if (!SWIG_AsVal(int)($input, (int*)(void*)&($1))) {
    return 1;
  }
}


/* this doesn't work now, you need to redefined it for each enum. */
%apply const int& { const enum SWIGTYPE& };


