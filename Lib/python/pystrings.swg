
/* ------------------------------------------------------------
 *  utility methods for strings handling
 * ------------------------------------------------------------ */

%types(char *);

%fragment("SWIG_AsCharPtrAndSize","header") %{
/* returns '1' if the input is a raw char*, '2' if is a PyString */
SWIGSTATIC(int)
SWIG_AsCharPtrAndSize(PyObject *obj, char** cptr, size_t* size)
{
  static swig_type_info* pchar_info = 0;
  int vsize = 0;
  char* vptr = 0;
  if (!pchar_info) pchar_info = SWIG_TypeQuery("char *");

  if (SWIG_ConvertPtr(obj, (void**)&vptr, pchar_info, 0) != -1) {
    if (cptr) *cptr = vptr;
    if (size) *size = vptr ? (strlen(vptr) + 1) : 0;
    return SWIG_OLDOBJ;
  } else {
    if (PyString_Check(obj)) {
#if PY_VERSION_HEX >= 0x02000000
      PyString_AsStringAndSize(obj, &vptr, &vsize);
#else
      vptr = PyString_AsString(obj);
      vsize = PyString_Size(obj);
#endif
      if (cptr) *cptr = vptr;
      if (size) *size = vsize;
      return SWIG_NEWOBJ;
    }
  }
  if (cptr || size) {
    PyErr_SetString(PyExc_TypeError, "a string is expected");
  }
  return 0;
}
%}

%fragment("SWIG_AsCharPtr","header",
	  fragment="SWIG_AsCharPtrAndSize") %{
SWIGSTATICINLINE(int)
  SWIG_AsCharPtr(PyObject *obj, char **val)
{
  char* cptr;
  if (SWIG_AsCharPtrAndSize(obj, &cptr, 0)) {
    if (val) *val = cptr;
    return 1;
  }
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a char* is expected");
  }
  return 0;
}
%}

%fragment("SWIG_FromCharPtr","header") %{
SWIGSTATICINLINE(PyObject *)
SWIG_FromCharPtr(const char* cptr)
{ 
  size_t size = cptr ? strlen(cptr) : 0;
  if (cptr) {
    if (size > INT_MAX) {
      return SWIG_NewPointerObj(swig_const_cast(cptr,char*), 
				SWIG_TypeQuery("char *"), 0);
    } else {
      return PyString_FromStringAndSize(cptr, swig_numeric_cast(size,int));
    }
  } else {
    Py_INCREF(Py_None);
    return Py_None;
  }
}
%}

%fragment("SWIG_AsNewCharPtr","header",
	  fragment="SWIG_AsCharPtrAndSize") %{
SWIGSTATIC(int)
  SWIG_AsNewCharPtr(PyObject *obj, char **val)
{
  char* cptr = 0; size_t csize = 0;
  int res = SWIG_AsCharPtrAndSize(obj, &cptr, &csize);
  if (res) {
    if (val) {
      /* we add the '0' terminator if needed for PyString */
      size_t size = ((res == 2) && csize  && (cptr[csize - 1])) ?
	csize + 1 : csize;
      if (size) {
	*val = swig_new_array(size, char);
	if (csize) memcpy(*val, cptr, csize);
	if (csize < size) (*val)[csize] = 0;
      } else if (cptr) {
	*val = swig_new_array(1, char);
	(*val)[0] = 0;
      } else {
	*val = 0;
      }
      
    }
    return 1;
  } 
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a char* is expected");
  }
  return 0;
}
%}

%fragment("SWIG_AsCharArray","header",
	  fragment="SWIG_AsCharPtrAndSize") %{
SWIGSTATIC(int)
SWIG_AsCharArray(PyObject *obj, char *val, size_t size)
{ 
  char* cptr; size_t csize;  
  if (SWIG_AsCharPtrAndSize(obj, &cptr, &csize)) {
    /* in C (but not in C++) you can do: 
       
         char x[5] = "hello"; 

        ie, assing the array using an extra '0' char.
    */
#ifndef __cplusplus
    if ((csize == size + 1) && !(cptr[csize-1])) --csize;
#endif
    if (csize <= size) {
      if (val) {
	if (csize) memcpy(val, cptr, csize);
	if (csize < size) memset(val + csize, 0, size - csize);
      }
      return 1;
    }
  }
  if (val) {
    PyErr_Format(PyExc_TypeError, 
		 "a char array of maximum size %d is expected", 
		 size);
  }
  return 0;
}
%}

%fragment("SWIG_FromCharArray","header") %{
SWIGSTATICINLINE(PyObject *)
SWIG_FromCharArray(const char* carray, size_t size)
{
  if (size > INT_MAX) {
    SWIG_NewPointerObj(swig_const_cast(carray,char*), SWIG_TypeQuery("char *"), 0);
    return Py_None;    
  } else {
    return PyString_FromStringAndSize(carray, swig_numeric_cast(size,int));
  }
}
%}

/* ------------------------------------------------------------
 *  The plain char * handling
 * ------------------------------------------------------------ */

/* in */

%typemap(in,fragment="SWIG_AsCharPtr")
  char *, char const*, char *const, char const *const
  "if (!SWIG_AsCharPtr($input, (char**)&$1)) SWIG_fail;";

%typemap(in,fragment="SWIG_AsCharPtr") 
  char const*&, char *const&, char const *const & 
{
  $*ltype temp;
  if (!SWIG_AsCharPtr($input, (char**)&temp)) SWIG_fail;
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
  char *cptr = 0;
  if (!SWIG_AsNewCharPtr($input, &cptr)) {
    PyErr_Clear();
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
  char *cptr;
  if (!SWIG_AsNewCharPtr($input, &cptr)) {    
    PyErr_Clear();
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
  "$input = SWIG_NewPointerObj((char*)($1_name), $descriptor(char *), 0);"
  /* "$input = SWIG_FromCharPtr($1_name);"; */


/* directorout */

%typemap(directorout,fragment="SWIG_AsCharPtr")
  char *, char const*, char *const, char const* const
  "if (!SWIG_AsCharPtr($input, (char**) &$result)) {
      Swig::DirectorTypeMismatchException(\"Error converting Python object into char*\");
   }";

%typemap(directorout,fragment="SWIG_AsCharPtr")
  char const *&, char *const &, char const *const &
{ 
  char* temp;
  if (!SWIG_AsCharPtr($input, &temp)) {
    Swig::DirectorTypeMismatchException("Error converting Python object into char*");
  }
  $result = ($1_ltype) &temp;
}

/* typecheck */

%typemap(typecheck,precedence=SWIG_TYPECHECK_STRING,
	 fragment="SWIG_AsCharPtr") 
  char *, char const*, char *const, char const *const,
  char const*&, char *const&, char const *const & 
 "$1 = SWIG_AsCharPtr($input, (char **)(0));";

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
  if (!SWIG_AsCharArray($input, temp, $1_dim0)) SWIG_fail;
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
  if (!SWIG_AsCharArray($input, $1, $1_dim0)) {
    PyErr_Clear();
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
  if (!SWIG_AsCharArray($input, temp, $result_dim0)) {
    Swig::DirectorTypeMismatchException("Error converting Python object into char[$result_dim0]");
  }
  $result = temp;
}

/* typecheck */

%typemap(typecheck,precedence=SWIG_TYPECHECK_STRING,
	 fragment="SWIG_AsCharArray")  
  char [ANY], const char[ANY]
{  
  return SWIG_AsCharArray($input, (char **)0, (size_t *)0);
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
  int res = SWIG_AsCharPtrAndSize($input, &buf, &size);
  if (!res) SWIG_fail;
  $1 = ($1_ltype) buf;
  $2 = ($2_ltype) ((res == 1) && size) ? size - 1 : size;
}

/* Here size includes the '0' terminator */
%typemap(in,fragment="SWIG_AsCharPtrAndSize")
  (char *STRING, int SIZE) (char *buf, size_t size)
{
  if (!SWIG_AsCharPtrAndSize($input, &buf, &size)) SWIG_fail;
  $1 = ($1_ltype) buf;
  $2 = ($2_ltype) size;
}
