/* -----------------------------------------------------------------------------
 * --- Input arguments --- 
 * ----------------------------------------------------------------------------- */

/* Pointers, references, and arrays */

%typemap(in) SWIGTYPE *, SWIGTYPE [] 
  "SWIG_Python_ConvertPtr($input, (void **)&$1, $descriptor, SWIG_POINTER_EXCEPTION | $disown);
   if (SWIG_arg_fail($argnum)) SWIG_fail;";

%typemap(in) SWIGTYPE* const&  ($*ltype temp) 
  "SWIG_Python_ConvertPtr($input, (void **)&temp, $*descriptor, SWIG_POINTER_EXCEPTION | $disown);
   if (SWIG_arg_fail($argnum)) SWIG_fail;
   $1 = &temp;
   ";

%typemap(in) SWIGTYPE *DISOWN 
  "SWIG_Python_ConvertPtr($input, (void **)&$1, $descriptor, SWIG_POINTER_EXCEPTION | SWIG_POINTER_DISOWN);
   if (SWIG_arg_fail($argnum)) SWIG_fail;";

/* Additional check for null references */
%typemap(in) SWIGTYPE & 
  "SWIG_Python_ConvertPtr($input, (void **)&$1, $descriptor, SWIG_POINTER_EXCEPTION | $disown);
   if (SWIG_arg_fail($argnum)) SWIG_fail;
   if ($1 == NULL) {
     SWIG_null_ref(SWIG_TypePrettyName($descriptor));
   }
   if (SWIG_arg_fail($argnum)) SWIG_fail;";

/* Object passed by value. Convert to a pointer */
%typemap(in) SWIGTYPE  {
  $&ltype argp;
  SWIG_Python_ConvertPtr($input, (void **)&argp, $&descriptor, SWIG_POINTER_EXCEPTION);
   if (SWIG_arg_fail($argnum)) SWIG_fail;
   if (argp == NULL) {
     SWIG_null_ref(SWIG_TypePrettyName($&descriptor));
   }
   if (SWIG_arg_fail($argnum)) SWIG_fail;
   $1 = *argp;
}


/* Pointer to a class member */
%typemap(in) SWIGTYPE (CLASS::*) 
  "if ((SWIG_ConvertPacked($input,(void *)(&$1),sizeof($type),$descriptor,0)) == -1) {
     SWIG_type_error(SWIG_TypePrettyName($descriptor),$input);
   }
   if (SWIG_arg_fail($argnum)) SWIG_fail;
  ";


/* -----------------------------------------------------------------------------
 * --- Output arguments --- 
 * ----------------------------------------------------------------------------- */

/* Pointers, references, and arrays */
%typemap(out) SWIGTYPE *, SWIGTYPE &, SWIGTYPE []
   "$result = SWIG_NewPointerObj((void*)($1), $descriptor, $owner);";

%typemap(out) SWIGTYPE* const&
   "$result = SWIG_NewPointerObj((void*)(*$1), $*descriptor, $owner);";

/* Dynamic casts */

%typemap(out) SWIGTYPE *DYNAMIC, SWIGTYPE &DYNAMIC {
   swig_type_info *ty = SWIG_TypeDynamicCast($1_descriptor, (void **) &$1);
   $result = SWIG_NewPointerObj((void *) $1, ty, $owner);
}

/* Member pointer */
%typemap(out) SWIGTYPE (CLASS::*) 
  "$result = SWIG_NewPackedObj((void*)(&$1), sizeof($type), $descriptor);";

/* Primitive types--return by value */
#ifdef __cplusplus
%typemap(out) SWIGTYPE 
{
  $&1_ltype resultptr;
  resultptr = new $ltype(SWIG_static_cast($1,$type &));
  $result = SWIG_NewPointerObj((void *)(resultptr), $&descriptor, 1);
}
#else
%typemap(out /* warning="452:Default return typemap could be unsafe" */) SWIGTYPE
{
  $&ltype resultptr;
  resultptr = ($&ltype) malloc(sizeof($type));
  memmove(resultptr, &$1, sizeof($type));
  $result = SWIG_NewPointerObj((void *)(resultptr), $&descriptor, 1);
}
#endif


/* -----------------------------------------------------------------------------
 * --- Variable input --- 
 * ----------------------------------------------------------------------------- */


/* Pointers, references, and arrays */

%typemap(varin) SWIGTYPE [ANY] {
  void *temp;
  size_t ii;
  $basetype *b = 0;
  if ((SWIG_ConvertPtr($input, &temp, $descriptor, SWIG_POINTER_EXCEPTION)) == -1) {
    SWIG_append_errmsg("C/C++ variable '$name'");
    return 1;
  }
  b = ($1_basetype *) $1;
  for (ii = 0; ii < (size_t) $1_size; ii++) b[ii] = *(($1_basetype *) temp + ii);
}

%typemap(varin) SWIGTYPE * {
  void *temp;
  if ((SWIG_ConvertPtr($input, &temp, $descriptor, SWIG_POINTER_EXCEPTION | SWIG_POINTER_DISOWN)) == -1) {
    SWIG_append_errmsg("C/C++ variable '$name'");
    return 1;
  }
  $1 = ($ltype) temp;
}

%typemap(varin,warning="462:Unable to set dimensionless array variable") SWIGTYPE []
{
  PyErr_SetString(PyExc_AttributeError, "C/C++ variable '$name' is read-only");
  return 1;
}

%typemap(varin) SWIGTYPE & {
  void *temp;
  if ((SWIG_ConvertPtr($input, &temp, $descriptor, SWIG_POINTER_EXCEPTION)) == -1 || temp == NULL) {
    SWIG_append_errmsg("C/C++ variable '$name'");
    return 1;
  }
  $1 = *($ltype) temp;
}


%typemap(varin) SWIGTYPE (CLASS::*) {
  char temp[sizeof($type)];
  if ((SWIG_ConvertPacked($input,(void *) temp, sizeof($1_type), $1_descriptor, SWIG_POINTER_EXCEPTION)) == -1) {
    SWIG_append_errmsg("C/C++ variable '$name'");
    return 1;
  }
  memmove((void *) &$1,temp,sizeof($type));
}

%typemap(varin) SWIGTYPE {
  $&ltype temp;
  if ((SWIG_ConvertPtr($input, (void **)(&temp), $&descriptor, SWIG_POINTER_EXCEPTION)) == -1) {
    SWIG_append_errmsg("C/C++ variable '$name'");
    return 1;
  }
  $1 = *(($&type) temp);
}

/* -----------------------------------------------------------------------------
 * --- Variable output --- 
 * ----------------------------------------------------------------------------- */

/* Pointers and arrays */
%typemap(varout) SWIGTYPE *, SWIGTYPE [] 
  "$result = SWIG_NewPointerObj((void *)($1), $1_descriptor, 0);";

/* References */
%typemap(varout) SWIGTYPE & 
  "$result = SWIG_NewPointerObj((void *)(&$1), $1_descriptor, 0);";

/* Member pointer */
%typemap(varout) SWIGTYPE (CLASS::*) 
  "$result = SWIG_NewPackedObj((void *)(&$1), sizeof($1_type), $1_descriptor);";

%typemap(varout) SWIGTYPE 
  "$result = SWIG_NewPointerObj((void *)(&$1), $&1_descriptor, 0);";

/* -----------------------------------------------------------------------------
 * --- Constants --- *
 * ----------------------------------------------------------------------------- */


/* Pointers, arrays, objects */

%typemap(consttab) SWIGTYPE *, SWIGTYPE &, SWIGTYPE []
{ SWIG_PY_POINTER, (char*)"$symname", 0, 0, (void *)$value, &$descriptor}

%typemap(consttab) SWIGTYPE (CLASS::*) 
{ SWIG_PY_BINARY,  (char *)"$symname", sizeof($type), 0, (void *)&$value, &$descriptor}


/* -----------------------------------------------------------------------------
 * --- Director typemaps --- *
 * ----------------------------------------------------------------------------- */

/* director in not needed, see python.cxx */

/* directorout */

%typemap(directorout) SWIGTYPE ($&ltype argp)
 "if ((SWIG_ConvertPtr($input, (void **)(&argp),
		       $&descriptor, SWIG_POINTER_EXCEPTION | $disown)) == -1)
    throw Swig::DirectorTypeMismatchException(\"Pointer conversion failed.\");
  $result = *argp;";

%typemap(directorout) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] 
 "if ((SWIG_ConvertPtr($input,(void **)(&$result),
		       $descriptor,SWIG_POINTER_EXCEPTION | $disown )) == -1)
    throw Swig::DirectorTypeMismatchException(\"Pointer conversion failed.\");";


/* ------------------------------------------------------------
 * --- Typechecking rules ---
 * ------------------------------------------------------------ */

%typecheck(SWIG_TYPECHECK_POINTER) 
  SWIGTYPE *, SWIGTYPE &, SWIGTYPE []
{
  void *ptr;
  if (SWIG_ConvertPtr($input, &ptr, $descriptor, 0) == -1) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE 
{
  void *ptr;
  if (SWIG_ConvertPtr($input, &ptr, $&descriptor, 0) == -1) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = 1;
  }
}


/* ------------------------------------------------------------
 * --- Exception handling ---
 * ------------------------------------------------------------ */

%typemap(throws) SWIGTYPE {
  $&1_ltype temp = new $1_ltype($1);
  if ($&1_descriptor->clientdata) {
    PyErr_SetObject((PyObject *) ($&1_descriptor->clientdata), SWIG_NewPointerObj(temp,$&1_descriptor,1));
  } else {
    PyErr_SetString(PyExc_RuntimeError,"$1_type");
    /*
      PyErr_SetObject(PyExc_RuntimeError, SWIG_NewPointerObj(temp,$&1_descriptor,1));
    */
  }
  SWIG_fail;
}


%typemap(throws) SWIGTYPE * {
  if ($1_descriptor->clientdata) {
    PyErr_SetObject((PyObject *) ($1_descriptor->clientdata),
		    SWIG_NewPointerObj((void *) $1,$1_descriptor,1));
  } else {
    PyErr_SetString(PyExc_RuntimeError,"$1_type");
  }
  SWIG_fail;
}


%typemap(throws) SWIGTYPE [ANY] {
  if ($1_descriptor->clientdata) {
    PyErr_SetObject((PyObject *) ($1_descriptor->clientdata),
		    SWIG_NewPointerObj((void *)$1,$1_descriptor,1));
  } else {
    PyErr_SetString(PyExc_RuntimeError,"$1_type");
  }
  SWIG_fail;
}

%typemap(throws) SWIGTYPE & {
  if ($1_descriptor->clientdata) {
    PyErr_SetObject((PyObject *) ($1_descriptor->clientdata), 
		    SWIG_NewPointerObj((void *)&($1),$1_descriptor,1));
  } else {
    PyErr_SetString(PyExc_RuntimeError,"$1_type");
  }
  SWIG_fail;
}
