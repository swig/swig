/* ------------------------------------------------------------
 *  utility methods for wstrings handling
 * ------------------------------------------------------------ */

%types(wchar_t *);
%{
#include <wchar.h>
%}
%fragment("SWIG_AsWCharPtrAndSize","header") %{
SWIGSTATIC(int)
SWIG_AsWCharPtrAndSize(PyObject *obj, wchar_t **cptr, size_t *psize)
{
  static swig_type_info* pwchar_info = 0;
  wchar_t * vptr = 0;
  if (!pwchar_info) pwchar_info = SWIG_TypeQuery("wchar_t *");
  if (SWIG_ConvertPtr(obj, (void**)&vptr, pwchar_info, 0) != -1) {
    if (cptr) *cptr = vptr;
    if (psize) *psize = vptr ? (wcslen(vptr) + 1) : 0;
    return SWIG_OLDOBJ;
  } else {
    int isunicode = PyUnicode_Check(obj);
    if (isunicode || PyString_Check(obj)) {
      if (cptr) {
	int size = isunicode ? PyUnicode_GetSize(obj) : PyString_Size(obj);
	wchar_t *nptr = swig_new_array(size + 1, wchar_t);
	PyUnicodeObject *uni = (PyUnicodeObject *)PyUnicode_FromObject(obj);
	PyUnicode_AsWideChar(uni, nptr, size);
	nptr[size] = 0;
	*cptr = nptr;
	if (psize) {
	  *psize = (size_t) size + 1;
	}
	Py_DECREF(uni);
      }
      return SWIG_NEWOBJ;
    }
  }
  if (cptr) {
    PyErr_SetString(PyExc_TypeError, "a wchar_t * is expected");
  }
  return 0;
}
%}

%fragment("SWIG_AsWCharPtr","header",
	  fragment="SWIG_AsWCharPtrAndSize") %{
SWIGSTATICINLINE(int)
SWIG_AsWCharPtr(PyObject *obj, wchar_t **val)
{
  wchar_t * cptr = 0;
  int res = 0;
  if ((res = SWIG_AsWCharPtrAndSize(obj, &cptr, (size_t*)(0)))) {
    if (val) *val = cptr;
    return res;
  }
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a wchar_t * is expected");
  }
  return 0;
}
%}

%fragment("SWIG_FromWCharPtr","header") %{
SWIGSTATICINLINE(PyObject *)
SWIG_FromWCharPtr(const wchar_t * cptr)
{ 
  if (cptr) {
    size_t size = wcslen(cptr);
    if (size > INT_MAX) {
      return SWIG_NewPointerObj(swig_const_cast(cptr,wchar_t *), 
				SWIG_TypeQuery("wchar_t *"), 0);
    } else {
      return PyUnicode_FromWideChar(cptr, size);
    }
  }
  Py_INCREF(Py_None);
  return Py_None;
}
%}

%fragment("SWIG_AsNewWCharPtr","header",
	  fragment="SWIG_AsWCharPtrAndSize") %{
SWIGSTATIC(int)
SWIG_AsNewWCharPtr(PyObject *obj, wchar_t **val)
{
  wchar_t * cptr = 0; size_t csize = 0;
  int res = SWIG_AsWCharPtrAndSize(obj, &cptr, &csize);
  if (res) {
    if (val) {
      if (csize) {
	*val = swig_new_array(csize, wchar_t);
	memcpy(*val, cptr, (--csize)*sizeof(wchar_t));
	(*val)[csize] = 0;
      } else if (cptr) {
	*val = swig_new_array(1, wchar_t);
	(*val)[0] = 0;
      } else {
	*val = 0;
      }
    }
    return SWIG_NEWOBJ;
  } 
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a wchar_t * is expected");
  }
  return 0;
}
%}

%fragment("SWIG_AsWCharArray","header",
	  fragment="SWIG_AsWCharPtrAndSize") %{
SWIGSTATIC(int)
SWIG_AsWCharArray(PyObject *obj, wchar_t *val, size_t size)
{ 
  wchar_t * cptr; size_t csize;  
  if (SWIG_AsWCharPtrAndSize(obj, &cptr, &csize)) {
    if ((csize == size + 1) && !(cptr[csize-1])) --csize;
    if (csize <= size) {
      if (val) {
	if (csize) memcpy(val, cptr, csize*sizeof(wchar_t));
	if (csize < size) memset(val+csize, 0, (size-csize)*sizeof(wchar_t));
      }
      return 1;
    }
  }
  if (val) {
    PyErr_Format(PyExc_TypeError, 
		 "a wchar_t array of maximum size %d is expected", 
		 size);
  }
  return 0;
}
%}

%fragment("SWIG_FromWCharArray","header") %{
SWIGSTATICINLINE(PyObject *)
SWIG_FromWCharArray(const wchar_t * carray, size_t size)
{
  if (size > INT_MAX) {
    SWIG_NewPointerObj(swig_const_cast(carray,wchar_t *), SWIG_TypeQuery("wchar_t *"), 0);
    return Py_None;    
  } else {
    return PyUnicode_FromWideChar(carray, swig_numeric_cast(size,int));
  }
}
%}

/* ------------------------------------------------------------
 *  The plain wchar_t * handling
 * ------------------------------------------------------------ */

/* in */

%typemap(in,fragment="SWIG_AsWCharPtr")
  wchar_t *, wchar_t const*, wchar_t *const, wchar_t const *const
  "if (!SWIG_AsWCharPtr($input, (wchar_t **)&$1)) SWIG_fail;";

%typemap(in,fragment="SWIG_AsWCharPtr") 
  wchar_t const*&, wchar_t *const&, wchar_t const *const & 
{
  $*ltype temp;
  if (!SWIG_AsWCharPtr($input, (wchar_t **)&temp)) SWIG_fail;
  $1 = &temp;
}    

/* out */

%typemap(out,fragment="SWIG_FromWCharPtr")
  wchar_t *, wchar_t const*, wchar_t *const, wchar_t const *const
  "$result = SWIG_FromWCharPtr($1);";

%typemap(out,fragment="SWIG_FromWCharPtr")
  wchar_t *const &, wchar_t const* &, wchar_t const *const &
  "$result = SWIG_FromWCharPtr(*$1);";

/* varin */

%typemap(varin,fragment="SWIG_AsNewWCharPtr") wchar_t *
{
  wchar_t *cptr = 0;
  if (!SWIG_AsNewWCharPtr($input, &cptr)) {
    PyErr_Clear();
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  if ($1) swig_delete_array($1);
  $1 = cptr;
}

%typemap(varin,fragment="SWIG_AsNewWCharPtr",
	 warning="451:Setting const wchar_t * variable may leak memory") 
  const wchar_t *
{
  wchar_t *cptr;
  if (!SWIG_AsNewWCharPtr($input, &cptr)) {    
    PyErr_Clear();
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = cptr;
}

/* varout */

%typemap(varout,fragment="SWIG_FromWCharPtr")
  wchar_t *, wchar_t const*, wchar_t *const, wchar_t const *const
  "$result = SWIG_FromWCharPtr($1);";

/* constant */

%typemap(constcode,fragment="SWIG_FromWCharPtr")
  wchar_t *, wchar_t const*, wchar_t * const, wchar_t const* const
  "PyDict_SetItemString(d,\"$symname\", SWIG_FromWCharPtr($value));";

/* directorin */

%typemap(directorin,fragment="SWIG_FromWCharPtr")
  wchar_t *, wchar_t const*, wchar_t *const, wchar_t const *const, 
  wchar_t const *&, wchar_t *const &, wchar_t const *const &
  "$input = SWIG_NewPointerObj((wchar_t *)($1_name), $descriptor(wchar_t *), 0);"
  /* "$input = SWIG_FromWCharPtr($1_name);"; */


/* directorout */

%typemap(directorout,fragment="SWIG_AsWCharPtr")
  wchar_t *, wchar_t const*, wchar_t *const, wchar_t const* const
  "if (!SWIG_AsWCharPtr($input, (wchar_t **) &$result)) {
      Swig::DirectorTypeMismatchException(\"Error converting Python object into wchar_t *\");
   }";

%typemap(directorout,fragment="SWIG_AsWCharPtr")
  wchar_t const *&, wchar_t *const &, wchar_t const *const &
{ 
  wchar_t * temp;
  if (!SWIG_AsWCharPtr($input, &temp)) {
    Swig::DirectorTypeMismatchException("Error converting Python object into wchar_t *");
  }
  $result = ($1_ltype) &temp;
}

/* typecheck */

%typemap(typecheck,precedence=SWIG_TYPECHECK_STRING,
	 fragment="SWIG_AsWCharPtr") 
  wchar_t *, wchar_t const*, wchar_t *const, wchar_t const *const,
  wchar_t const*&, wchar_t *const&, wchar_t const *const & 
 "$1 = SWIG_AsWCharPtr($input, (wchar_t **)(0));";

/* throws */

%typemap(throws,fragment="SWIG_FromWCharPtr")
  wchar_t *, wchar_t const*, wchar_t * const, wchar_t const* const
{
  PyErr_SetObject(PyExc_RuntimeError, SWIG_FromWCharPtr($1));
  SWIG_fail;
}


/* ------------------------------------------------------------
 *  Fix size wcharacter array wchar_t[ANY] handling
 * ------------------------------------------------------------ */

/*  memberin and globalin typemaps  */

%typemap(memberin) wchar_t [ANY]
{
  if ($input) memcpy($1,$input,$1_dim0*sizeof(wchar_t));
  else memset($1,0,$1_dim0*sizeof(wchar_t));
}

%typemap(globalin) wchar_t [ANY]
{
  if ($input) memcpy($1,$input,$1_dim0*sizeof(wchar_t));
  else memset($1,0,$1_dim0*sizeof(wchar_t));
}

/* in */

%typemap(in,fragment="SWIG_AsWCharArray")
  wchar_t [ANY], const wchar_t [ANY]
{  
  wchar_t temp[$1_dim0];
  if (!SWIG_AsWCharArray($input, temp, $1_dim0)) SWIG_fail;
  $1 = temp;
}

/* out */

%typemap(out,fragment="SWIG_FromWCharArray")
  wchar_t [ANY], const wchar_t [ANY]
  "$result = SWIG_FromWCharArray($1, $1_dim0);";

/* varin */

%typemap(varin,fragment="SWIG_AsWCharArray")
  wchar_t [ANY]
{
  if (!SWIG_AsWCharArray($input, $1, $1_dim0)) {
    PyErr_Clear();
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
}

/* varout */

%typemap(varout,fragment="SWIG_FromWCharArray")
  wchar_t [ANY], const wchar_t [ANY] 
  "$result = SWIG_FromWCharArray($1, $1_dim0);";


/* constants */

%typemap(constcode,fragment="SWIG_FromWCharArray")
  wchar_t [ANY], const wchar_t [ANY]
  "PyDict_SetItemString(d,\"$symname\", SWIG_FromWCharArray($value, $value_dim0));";

/* directorin */

%typemap(directorin,fragment="SWIG_FromWCharArray")
  wchar_t [ANY], const wchar_t [ANY] 
  "$input = SWIG_FromWCharArray($1_name, $1_dim0);";

/* directorout */

%typemap(directorout,fragment="SWIG_AsWCharArray")
  wchar_t [ANY], const wchar_t [ANY] (wchar_t temp[$result_dim0])
{ 
  if (!SWIG_AsWCharArray($input, temp, $result_dim0)) {
    Swig::DirectorTypeMismatchException("Error converting Python object into wchar_t[$result_dim0]");
  }
  $result = temp;
}

/* typecheck */

%typemap(typecheck,precedence=SWIG_TYPECHECK_STRING,
	 fragment="SWIG_AsWCharArray")  
  wchar_t [ANY], const wchar_t[ANY]
{  
  return SWIG_AsWCharArray($input, (wchar_t **)0, (size_t *)0);
}

/* throw */

%typemap(throws,fragment="SWIG_FromWCharArray")
  wchar_t[ANY], const wchar_t[ANY] {
  PyErr_SetObject(PyExc_RuntimeError, SWIG_FromWCharArray($1,$1_dim0));
  SWIG_fail;
}

/* ------------------------------------------------------------
 * --- String & length ---
 * ------------------------------------------------------------ */

/* Here len doesn't include the '0' terminator */
%typemap(in, fragment="SWIG_AsWCharPtrAndSize") 
  (wchar_t *STRING, int LENGTH) (wchar_t *buf, size_t size)
{
  int res = SWIG_AsWCharPtrAndSize($input, &buf, &size);
  if (!res) SWIG_fail;
  $1 = ($1_ltype) buf;
  $2 = ($2_ltype) size - 1;
}

/* Here size includes the '0' terminator */
%typemap(in,fragment="SWIG_AsWCharPtrAndSize")
  (wchar_t *STRING, int SIZE) (wchar_t *buf, size_t size)
{
  if (!SWIG_AsWCharPtrAndSize($input, &buf, &size)) SWIG_fail;
  $1 = ($1_ltype) buf;
  $2 = ($2_ltype) size;
}
