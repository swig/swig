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
%typemap(in) SWIGTYPE & {  
  SWIG_Python_ConvertPtr($input, (void **)&$1, $descriptor, SWIG_POINTER_EXCEPTION | $disown);
   if (SWIG_arg_fail($argnum)) SWIG_fail;
   if ($1 == NULL) {
     SWIG_null_ref("$basetype");
   }
   if (SWIG_arg_fail($argnum)) SWIG_fail;
}

/* Object passed by value. Convert to a pointer */
%typemap(in) SWIGTYPE  {
  $&ltype argp;
  SWIG_Python_ConvertPtr($input, (void **)&argp, $&descriptor, SWIG_POINTER_EXCEPTION);
   if (SWIG_arg_fail($argnum)) SWIG_fail;
   if (argp == NULL) {
     SWIG_null_ref("$basetype");
   }
   if (SWIG_arg_fail($argnum)) SWIG_fail;
   $1 = *argp;
}

/* Pointer to a class member */
%typemap(in) SWIGTYPE (CLASS::*) {  
  if ((SWIG_ConvertPacked($input,(void *)(&$1),sizeof($type),$descriptor,0)) == -1) {
     SWIG_type_error("$type",$input);
   }
  if (SWIG_arg_fail($argnum)) SWIG_fail;
}

/* -----------------------------------------------------------------------------
 * --- Output arguments --- 
 * ----------------------------------------------------------------------------- */

/* Pointers, references, and arrays */
%typemap(out) SWIGTYPE *, SWIGTYPE &
   "$result = SWIG_NewPointerObj((void*)($1), $descriptor, $owner);";


%typemap(out) SWIGTYPE* const&
   "$result = SWIG_NewPointerObj((void*)(*$1), $*descriptor, $owner);";

/* Dynamic casts */

%typemap(out) SWIGTYPE *DYNAMIC, SWIGTYPE &DYNAMIC {
   swig_type_info *ty = SWIG_TypeDynamicCast($descriptor, (void **) &$1);
   $result = SWIG_NewPointerObj((void *) $1, ty, $owner);
}

/* Member pointer */
%typemap(out) SWIGTYPE (CLASS::*) 
  "$result = SWIG_NewPackedObj((void*)(&$1), sizeof($type), $descriptor);";

/* Primitive types--return by value */
#ifdef __cplusplus
%typemap(out) SWIGTYPE 
{
  $&ltype resultptr;
  resultptr = new $ltype(SWIG_static_cast($1,$type &));
  $result = SWIG_NewPointerObj((void *)(resultptr), $&descriptor, 1);
}
#else
%typemap(out /* warning="452:Default return typemap could be unsafe" */) SWIGTYPE
{
  $&ltype resultptr;
  resultptr = ($&ltype) malloc(sizeof($type));
  if (resultptr) memmove(resultptr, &$1, sizeof($type));
  $result = SWIG_NewPointerObj((void *)(resultptr), $&descriptor, 1);
}
#endif


/* -----------------------------------------------------------------------------
 * --- Variable input --- 
 * ----------------------------------------------------------------------------- */

/* memberin/globalin/varin, for fix arrays. */

%typemap(memberin) SWIGTYPE [ANY] {
  $basetype *inp = SWIG_static_cast($input, $basetype *);
  if (inp) {
    $basetype *dest = SWIG_static_cast($1, $basetype *);
    size_t ii = 0;
    for (; ii < $dim0; ++ii) dest[ii] = inp[ii];
  } else {
    SWIG_null_ref("$basetype");
  }
}

%typemap(globalin) SWIGTYPE [ANY] {
  $basetype *inp = SWIG_static_cast($input, $basetype *);
  if (inp) {
    $basetype *dest = SWIG_static_cast($1, $basetype *);
    size_t ii = 0;
    for (; ii < $dim0; ++ii) dest[ii] = inp[ii];
  } else {
    SWIG_null_ref("$basetype");
  }
}

%typemap(varin) SWIGTYPE [ANY] {
  $basetype *inp = 0;
  if ((SWIG_ConvertPtr($input, (void **)&inp, $descriptor, SWIG_POINTER_EXCEPTION)) == -1) {
    SWIG_append_errmsg("C/C++ variable '$name'");
    return 1;
  } else if (inp) {
    size_t ii = 0;
    $basetype *dest = SWIG_static_cast($1, $basetype *);
    for (; ii < $dim0; ++ii) dest[ii] = inp[ii];
  } else {
    SWIG_null_ref("$basetype");
    return 1;
  }
}

/* memberin/globalin/varin, for fix double arrays. */

%typemap(memberin) SWIGTYPE [ANY][ANY] {
  $basetype (*inp)[$dim1] = SWIG_static_cast($input, $basetype (*)[$dim1]);
  if (inp) {
    $basetype (*dest)[$dim1] = SWIG_static_cast($1, $basetype (*)[$dim1]);
    size_t ii = 0;
    for (; ii < $dim0; ++ii) {
      $basetype *ip = inp[ii];
      if (ip) {
	$basetype *dp = dest[ii];
	size_t jj = 0;
	for (; jj < $dim1; ++jj) dp[jj] = ip[jj];
      } else {
	SWIG_null_ref("$basetype");
      }
    }
  } else {
    SWIG_null_ref("$basetype[$dim1]");
  }
}

%typemap(globalin) SWIGTYPE [ANY][ANY] {
  $basetype (*inp)[$dim1] = SWIG_static_cast($input, $basetype (*)[$dim1]);
  if (inp) {
    $basetype (*dest)[$dim1] = SWIG_static_cast($1, $basetype (*)[$dim1]);
    size_t ii = 0;
    for (; ii < $dim0; ++ii) {
      $basetype *ip = inp[ii];
      if (ip) {
	$basetype *dp = dest[ii];
	size_t jj = 0;
	for (; jj < $dim1; ++jj) dp[jj] = ip[jj];
      } else {
	SWIG_null_ref("$basetype");
      }
    }
  } else {
    SWIG_null_ref("$basetype[$dim1]");
  }
}

%typemap(varin) SWIGTYPE [ANY][ANY] {
  $basetype (*inp)[$dim1] = 0;
  if ((SWIG_ConvertPtr($input, (void **)&inp, $descriptor, SWIG_POINTER_EXCEPTION)) == -1) {
    SWIG_append_errmsg("C/C++ variable '$name'");
    return 1;
  } else if (inp) {
    $basetype (*dest)[$dim1] = SWIG_static_cast($1, $basetype (*)[$dim1]);
    size_t ii = 0;
    for (; ii < $dim0; ++ii) {
      $basetype *ip = inp[ii];
      if (ip) {
	$basetype *dp = dest[ii];
	size_t jj = 0;
	for (; jj < $dim1; ++jj) dp[jj] = ip[jj];
      } else {
	SWIG_null_ref("$basetype");
	return 1;
      }
    }
  } else {
    SWIG_null_ref("$basetype[$dim1]");
    return 1;
  }
}

/* Pointers, references, and variable size arrays */

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
  if ((SWIG_ConvertPacked($input,(void *) temp, sizeof($type), $descriptor, SWIG_POINTER_EXCEPTION)) == -1) {
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
  "$result = SWIG_NewPointerObj((void *)($1), $descriptor, 0);";

/* References */
%typemap(varout) SWIGTYPE & 
  "$result = SWIG_NewPointerObj((void *)(&$1), $descriptor, 0);";

/* Member pointer */
%typemap(varout) SWIGTYPE (CLASS::*) 
  "$result = SWIG_NewPackedObj((void *)(&$1), sizeof($type), $descriptor);";

%typemap(varout) SWIGTYPE 
  "$result = SWIG_NewPointerObj((void *)(&$1), $&descriptor, 0);";

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
 "if (!$input || (SWIG_ConvertPtr($input, (void **)(&argp),
		       $&descriptor, SWIG_POINTER_EXCEPTION | $disown)) == -1)
    Swig::DirectorTypeMismatchException::raise(\"Pointer conversion failed.\");
  $result = *argp;";

%typemap(directorout) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] 
 "if (!$input || (SWIG_ConvertPtr($input,(void **)(&$result),
		       $descriptor,SWIG_POINTER_EXCEPTION | $disown )) == -1)
    Swig::DirectorTypeMismatchException::raise(\"Pointer conversion failed.\");";


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

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE &
{
  void *ptr = 0;
  if (SWIG_ConvertPtr($input, &ptr, $descriptor, 0) == -1) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = (ptr != 0);
  }
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE 
{
  void *ptr = 0;
  if (SWIG_ConvertPtr($input, &ptr, $&descriptor, 0) == -1) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = (ptr != 0);
  }
}


/* ------------------------------------------------------------
 * --- Exception handling ---
 * ------------------------------------------------------------ */

%typemap(throws) SWIGTYPE {
  $&ltype temp = new $ltype($1);
  if ($&descriptor->clientdata) {
    PyErr_SetObject((PyObject *) ($&descriptor->clientdata), SWIG_NewPointerObj(temp,$&descriptor,1));
  } else {
    PyErr_SetString(PyExc_RuntimeError,"$type");
    /*
      PyErr_SetObject(PyExc_RuntimeError, SWIG_NewPointerObj(temp,$&descriptor,1));
    */
  }
  SWIG_fail;
}


%typemap(throws) SWIGTYPE * {
  if ($descriptor->clientdata) {
    PyErr_SetObject((PyObject *) ($descriptor->clientdata),
		    SWIG_NewPointerObj((void *) $1,$descriptor,1));
  } else {
    PyErr_SetString(PyExc_RuntimeError,"$type");
  }
  SWIG_fail;
}


%typemap(throws) SWIGTYPE [ANY] {
  if ($descriptor->clientdata) {
    PyErr_SetObject((PyObject *) ($descriptor->clientdata),
		    SWIG_NewPointerObj((void *)$1,$descriptor,1));
  } else {
    PyErr_SetString(PyExc_RuntimeError,"$type");
  }
  SWIG_fail;
}

%typemap(throws) SWIGTYPE & {
  if ($descriptor->clientdata) {
    PyErr_SetObject((PyObject *) ($descriptor->clientdata), 
		    SWIG_NewPointerObj((void *)&($1),$descriptor,1));
  } else {
    PyErr_SetString(PyExc_RuntimeError,"$type");
  }
  SWIG_fail;
}
