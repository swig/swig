
/* ------------------------------------------------------------
 *  utility methods for strings handling
 * ------------------------------------------------------------ */

%types(char *);

%fragment("SWIG_AsCharPtrAndSize","header") %{
/* returns '1' if the input is a raw char*, '0' if is a PyString */
SWIGSTATIC(int)
SWIG_AsCharPtrAndSize(PyObject *obj, char** cptr, size_t* size)
{
  static swig_type_info* pchar_info = 0;
  int psize = 0;
  if (!pchar_info) pchar_info = SWIG_TypeQuery("char *");

  if (SWIG_ConvertPtr(obj, swig_reinterpret_cast(void **,cptr), pchar_info, 0) == -1) {
    PyErr_Clear();
    PyString_AsStringAndSize(obj, cptr, &psize);
    if (PyErr_Occurred()) {
      PyErr_Clear();
      PyErr_SetString(PyExc_TypeError,"a string is expected");
    }
    if (size) *size = psize;
    return 0;
  } else {
    if (size) *size = (*cptr) ? (strlen(*cptr) + 1) : 0;
    return 1;
  }
}
%}

%fragment("SWIG_AsCharPtr","header",
	  fragment="SWIG_AsCharPtrAndSize") %{
SWIGSTATICINLINE(char* )
SWIG_AsCharPtr(PyObject *obj)
{
  char* cptr;
  SWIG_AsCharPtrAndSize(obj, &cptr, 0);
  if (PyErr_Occurred()) {
    PyErr_Clear();
    PyErr_SetString(PyExc_TypeError, "a char* is expected");
  }  
  return cptr;
}
%}

%fragment("SWIG_FromCharPtr","header") %{
SWIGSTATICINLINE(PyObject *)
SWIG_FromCharPtr(const char* cptr)
{ 
  size_t size = cptr ? strlen(cptr) : 0;
  if (cptr) {
    if (size > INT_MAX) {
      return SWIG_NewPointerObj(swig_const_cast(char*,cptr), 
				SWIG_TypeQuery("char *"), 0);
    } else {
      return PyString_FromStringAndSize(cptr, swig_numeric_cast(int,size));
    }
  } else {
    Py_INCREF(Py_None);
    return Py_None;
  }
}
%}

%fragment("SWIG_AsNewCharPtr","header",
	  fragment="SWIG_AsCharPtrAndSize") %{
SWIGSTATIC(char*)
SWIG_AsNewCharPtr(PyObject *obj)
{
  char *res = 0;
  char* cptr; size_t csize;
  int is_raw_pchar = SWIG_AsCharPtrAndSize(obj, &cptr, &csize);
  if (PyErr_Occurred()) {
    PyErr_Clear();
    PyErr_SetString(PyExc_TypeError, "a char* is expected");
  } else if (cptr) {
    /* we add the '0' terminator if needed */
    size_t size = (!is_raw_pchar && csize  && !(cptr[csize - 1])) ?
      csize : csize + 1;
    if (size) {
      res = swig_new_array(char, size);
      if (csize) memcpy(res, cptr, csize);
      if (csize < size) res[csize] = 0;
    }
  }
  return res;
}
%}

%fragment("SWIG_AsCharArray","header",
	  fragment="SWIG_AsCharPtrAndSize") %{
SWIGSTATIC(void)
SWIG_AsCharArray(PyObject *obj, char* carray, size_t size)
{ 
  char* cptr; size_t csize;  
  SWIG_AsCharPtrAndSize(obj, &cptr, &csize);
  if (PyErr_Occurred()) {
    PyErr_Clear();
    PyObject *err =  
      PyString_FromFormat("a char array of size %d is expected", size);
    PyErr_SetObject(PyExc_TypeError, err);
    Py_DECREF(err);
  } else {
    /* in C (but not in C++) you can do: 
       
         char x[5] = "hello"; 

        ie, assing the array using an extra '0' char.
    */
#ifndef __cplusplus
    if ((csize == size + 1) && !(cptr[csize-1])) --csize;
#endif
    if (csize > size) {
      PyObject *err =  
         PyString_FromFormat("a char array of maximum size %d is expected", 
			     size);
      PyErr_SetObject(PyExc_TypeError, err);
      Py_DECREF(err);
    } else {
      if (csize) memcpy(carray, cptr, csize);
      if (csize < size) memset(carray + csize, 0, size - csize);
    }
  }
}
%}

%fragment("SWIG_FromCharArray","header") %{
SWIGSTATICINLINE(PyObject *)
SWIG_FromCharArray(const char* carray, size_t size)
{
  if (size > INT_MAX) {
    SWIG_NewPointerObj(swig_const_cast(char*,carray), SWIG_TypeQuery("char *"), 0);
    return Py_None;    
  } else {
    return PyString_FromStringAndSize(carray, swig_numeric_cast(int,size));
  }
}
%}

/* ------------------------------------------------------------
 *  The plain char * handling
 * ------------------------------------------------------------ */

/* in */

%typemap(in,fragment="SWIG_AsCharPtr")
  char *, char const*, char *const, char const *const
  "$1 = SWIG_AsCharPtr($input);
   if (PyErr_Occurred()) SWIG_fail;";

%typemap(in,fragment="SWIG_AsCharPtr") 
  char const*&, char *const&, char const *const & 
{
  $*ltype temp = SWIG_AsCharPtr($input);
  if (PyErr_Occurred()) SWIG_fail;
  $1 = &temp;
}    

/* out */

%typemap(out,fragment="SWIG_FromCharPtr")
  char *, char const*, char *const, char const *const
  "$result = SWIG_FromCharPtr($1);";

%typemap(out,fragment="SWIG_FromCharPtr")
  char *const &, char const* &, char const *const &
  "$result = SWIG_FromCharPtr(*$1);";

/* varin */

%typemap(varin,fragment="SWIG_AsNewCharPtr") char *
{
  char *cptr = SWIG_AsNewCharPtr($input);
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  if ($1) swig_delete_array($1);
  $1 = cptr;
}

%typemap(varin,fragment="SWIG_AsNewCharPtr",
	 warning="451:Setting const char * variable may leak memory") 
  const char *
{
  char *cptr = SWIG_AsNewCharPtr($input);
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = cptr;
}

/* varout */

%typemap(varout,fragment="SWIG_FromCharPtr")
  char*, char const*, char *const, char const *const
  "$result = SWIG_FromCharPtr($1);";

/* constant */

%typemap(constcode,fragment="SWIG_FromCharPtr")
  char *, char const*, char * const, char const* const
  "PyDict_SetItemString(d,\"$symname\", SWIG_FromCharPtr($value));";

/* directorin */

%typemap(directorin,fragment="SWIG_FromCharPtr")
  char *, char const*, char *const, char const *const, 
  char const *&, char *const &, char const *const &
  "$input = SWIG_NewPointerObj(swig_const_cast(char*,$1_name), $descriptor(char *), 0);"
  /* "$input = SWIG_FromCharPtr($1_name);"; */


/* directorout */

%typemap(directorout,fragment="SWIG_AsCharPtr")
  char *, char const*, char *const, char const* const
  "$result = SWIG_AsCharPtr($input);
   if (PyErr_Occurred()) {
      Swig::DirectorTypeMismatchException(\"Error converting Python object into char*\");
   }";

%typemap(directorout,fragment="SWIG_AsCharPtr")
  char const *&, char *const &, char const *const &
{ 
  char* temp = SWIG_AsCharPtr($input);
  if (PyErr_Occurred()) {
    Swig::DirectorTypeMismatchException("Error converting Python object into char*");
  }
  $result = ($1_ltype) &temp;
}

/* typecheck */

%typemap(typecheck,precedence=SWIG_TYPECHECK_STRING,
	 fragment="SWIG_AsCharPtr") 
  char *, char const*, char *const, char const *const,
  char const*&, char *const&, char const *const & 
 "SWIG_AsCharPtr($input);
  if (PyErr_Occurred()) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = 1;
  }";

/* throws */

%typemap(throws,fragment="SWIG_FromCharPtr")
  char *, char const*, char * const, char const* const
{
  PyErr_SetObject(PyExc_RuntimeError, SWIG_FromCharPtr($1));
  SWIG_fail;
}


/* ------------------------------------------------------------
 *  Fix size character array char[ANY] handling
 * ------------------------------------------------------------ */

/*  memberin and globalin typemaps  */

%typemap(memberin) char [ANY]
{
  if ($input) memcpy($1,$input,$1_dim0);
  else memset($1,0,$1_dim0);
}

%typemap(globalin) char [ANY]
{
  if ($input) memcpy($1,$input,$1_dim0);
  else memset($1,0,$1_dim0);
}

/* in */

%typemap(in,fragment="SWIG_AsCharArray")
  char [ANY], const char [ANY]
{  
  char temp[$1_dim0];
  SWIG_AsCharArray($input, temp, $1_dim0);
  if (PyErr_Occurred()) SWIG_fail;
  $1 = temp;
}

/* out */

%typemap(out,fragment="SWIG_FromCharArray")
  char [ANY], const char [ANY]
  "$result = SWIG_FromCharArray($1, $1_dim0);";

/* varin */

%typemap(varin,fragment="SWIG_AsCharArray")
  char [ANY]
{
  SWIG_AsCharArray($input, $1, $1_dim0);
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
}

/* varout */

%typemap(varout,fragment="SWIG_FromCharArray")
  char [ANY], const char [ANY] 
  "$result = SWIG_FromCharArray($1, $1_dim0);";


/* constants */

%typemap(constcode,fragment="SWIG_FromCharArray")
  char [ANY], const char [ANY]
  "PyDict_SetItemString(d,\"$symname\", SWIG_FromCharArray($value, $value_dim0));";

/* directorin */

%typemap(directorin,fragment="SWIG_FromCharArray")
  char [ANY], const char [ANY] 
  "$input = SWIG_FromCharArray($1_name, $1_dim0);";

/* directorout */

%typemap(directorout,fragment="SWIG_AsCharArray")
  char [ANY], const char [ANY] (char temp[$result_dim0])
{ 
  SWIG_AsCharArray($input, temp, $result_dim0);
  if (PyErr_Occurred()) {
    Swig::DirectorTypeMismatchException("Error converting Python object into char[$result_dim0]");
  }
  $result = temp;
}

/* typecheck */

%typemap(typecheck,precedence=SWIG_TYPECHECK_STRING,
	 fragment="SWIG_AsCharArray")  
  char [ANY], const char[ANY]
{
  char* carray = 0; size_t size = 0;
  SWIG_AsCharArray($input, &carray, &size);
  if (PyErr_Occurred()) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = ((carray != 0) && (size <= $input_dim0));
  }
}

/* throw */

%typemap(throws,fragment="SWIG_FromCharArray")
  char[ANY], const char[ANY] {
  PyErr_SetObject(PyExc_RuntimeError, SWIG_FromCharArray($1,$1_dim0));
  SWIG_fail;
}

/* ------------------------------------------------------------
 * --- String & length ---
 * ------------------------------------------------------------ */

/* Here len doesn't include the '0' terminator */
%typemap(in, fragment="SWIG_AsCharPtrAndSize") 
  (char *STRING, int LENGTH) (char *buf, size_t size)
{
  int is_raw_pchar = SWIG_AsCharPtrAndSize($input, &buf, &size);
  if (PyErr_Occurred()) SWIG_fail;
  $1 = ($1_ltype) buf;
  $2 = ($2_ltype) (is_raw_pchar && size) ? size - 1 : size;
}

/* Here size includes the '0' terminator */
%typemap(in,fragment="SWIG_AsCharPtrAndSize")
  (char *STRING, int SIZE) (char *buf, size_t size)
{
  SWIG_AsCharPtrAndSize($input, &buf, &size);
  if (PyErr_Occurred()) SWIG_fail;
  $1 = ($1_ltype) buf;
  $2 = ($2_ltype) size;
}
