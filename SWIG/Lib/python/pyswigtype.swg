/* -----------------------------------------------------------------------------
 * --- Input arguments --- 
 * ----------------------------------------------------------------------------- */

/* Pointers, references, and arrays */

%typemap(in) SWIGTYPE *, SWIGTYPE []
  "if ((SWIG_ConvertPtr($input,(void **)(&$1),$1_descriptor,
             SWIG_POINTER_EXCEPTION | $disown)) == -1) SWIG_fail;";

%typemap(in) SWIGTYPE *DISOWN 
  "if ((SWIG_ConvertPtr($input,(void **)(&$1),$1_descriptor,
             SWIG_POINTER_EXCEPTION | SWIG_POINTER_DISOWN)) == -1) SWIG_fail;";

/* Additional check for null references */
%typemap(in) SWIGTYPE & 
  "if ((SWIG_ConvertPtr($input,(void **)(&$1),$1_descriptor,
             SWIG_POINTER_EXCEPTION | $disown)) == -1)
     SWIG_fail;
   if ($1 == NULL) {
     PyErr_SetString(PyExc_TypeError,\"null reference\");
     SWIG_fail;
   }";

/* Object passed by value. Convert to a pointer */
%typemap(in) SWIGTYPE ($&1_ltype argp) 
  "if ((SWIG_ConvertPtr($input,(void **)(&argp),$&1_descriptor,
             SWIG_POINTER_EXCEPTION) == -1)) SWIG_fail;
   $1 = *argp;";

/* Pointer to a class member */
%typemap(in) SWIGTYPE (CLASS::*) 
  "if ((SWIG_ConvertPacked($input,(void *)(&$1),sizeof($1_type),
	 		   $1_descriptor,SWIG_POINTER_EXCEPTION)) == -1)
     SWIG_fail;";


/* -----------------------------------------------------------------------------
 * --- Outnput arguments --- 
 * ----------------------------------------------------------------------------- */

/* Pointers, references, and arrays */
%typemap(out) SWIGTYPE *, SWIGTYPE &, SWIGTYPE []
   "$result = SWIG_NewPointerObj((void*)($1), $1_descriptor, $owner);";

/* Dynamic casts */

%typemap(out) SWIGTYPE *DYNAMIC, SWIGTYPE &DYNAMIC {
   swig_type_info *ty = SWIG_TypeDynamicCast($1_descriptor, (void **) &$1);
   $result = SWIG_NewPointerObj((void *) $1, ty, $owner);
}

/* Member pointer */
%typemap(out) SWIGTYPE (CLASS::*) 
  "$result = SWIG_NewPackedObj((void*)(&$1), sizeof($1_type), $1_descriptor);";

/* Primitive types--return by value */
#ifdef __cplusplus
%typemap(out) SWIGTYPE 
{
  $&1_ltype resultptr;
  resultptr = new $1_ltype(($1_ltype &) $1);
  $result = SWIG_NewPointerObj((void *)(resultptr), $&1_descriptor, 1);
}
#else
%typemap(out /* warning="452:Default return typemap could be unsafe" */) SWIGTYPE
{
  $&1_ltype resultptr;
  resultptr = ($&1_ltype) malloc(sizeof($1_type));
  memmove(resultptr, &$1, sizeof($1_type));
  $result = SWIG_NewPointerObj((void *)(resultptr), $&1_descriptor, 1);
}
#endif


/* -----------------------------------------------------------------------------
 * --- Variable input --- 
 * ----------------------------------------------------------------------------- */


/* Pointers, references, and arrays */

%typemap(varin) SWIGTYPE [ANY] {
  void *temp;
  int ii;
  $1_basetype *b = 0;
  if ((SWIG_ConvertPtr($input, &temp, $1_descriptor, SWIG_POINTER_EXCEPTION)) == -1) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  b = ($1_basetype *) $1;
  for (ii = 0; ii < $1_size; ii++) b[ii] = *(($1_basetype *) temp + ii);
}

%typemap(varin) SWIGTYPE * {
  void *temp;
  if ((SWIG_ConvertPtr($input, &temp, $1_descriptor, SWIG_POINTER_EXCEPTION | SWIG_POINTER_DISOWN)) == -1) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = ($1_ltype) temp;
}

%typemap(varin) SWIGTYPE & {
  void *temp;
  if ((SWIG_ConvertPtr($input, &temp, $1_descriptor, SWIG_POINTER_EXCEPTION)) == -1 || temp == NULL) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = *($1_ltype) temp;
}


%typemap(varin) SWIGTYPE (CLASS::*) {
  char temp[sizeof($1_type)];
  if ((SWIG_ConvertPacked($input,(void *) temp, sizeof($1_type), $1_descriptor, SWIG_POINTER_EXCEPTION)) == -1) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  memmove((void *) &$1,temp,sizeof($1_type));
}

%typemap(varin) SWIGTYPE {
  $&1_ltype temp;
  if ((SWIG_ConvertPtr($input, (void **)(&temp), $&1_descriptor, SWIG_POINTER_EXCEPTION)) == -1) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = *(($&1_type) temp);
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
{ SWIG_PY_POINTER, (char*)"$symname", 0, 0, (void *)$value, &$1_descriptor}

%typemap(consttab) SWIGTYPE (CLASS::*) 
{ SWIG_PY_BINARY,  (char *)"$symname", sizeof($type), 0, (void *)&$value, &$1_descriptor}


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

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE *, SWIGTYPE &, SWIGTYPE []
{
  void *ptr;
  if (SWIG_ConvertPtr($input, &ptr, $1_descriptor, 0) == -1) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE 
{
  void *ptr;
  if (SWIG_ConvertPtr($input, &ptr, $&1_descriptor, 0) == -1) {
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

/* This doesn't work, and not sure if it is needed... */
#if 0
%typecheck(throws) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] {
  if ($1_descriptor->clientdata) {
    PyErr_SetObject((PyObject *) ($1_descriptor->clientdata), SWIG_NewPointerObj($1,$1_descriptor,1));
  } else {
    PyErr_SetString(PyExc_RuntimeError,"$1_type");
  }
  SWIG_fail;
}
#endif

