/* -----------------------------------------------------------------------------
 * python.swg
 *
 * Python configuration module.
 * ----------------------------------------------------------------------------- */

/* Python.h has to appear first */

%insert(runtime) %{
#include "Python.h"
%}



%insert(runtime) "precommon.swg";
%insert(runtime) "common.swg";          // Common type-checking code
%insert(runtime) "pyrun.swg";           // Python run-time code

/* Special directive for shadow code */

#define %shadow      %insert("shadow")
#define %pythoncode  %insert("python")


/* auxiliar memory allocators */

#ifdef __cplusplus
#define %swig_new(type, size) new type[(size)]
#define %swig_delete(cptr) delete [] cptr;
#else
#define %swig_new(type, size) (type*) malloc((size)*sizeof(type))
#define %swig_delete(cptr) free((char*)cptr);
#endif

/* -----------------------------------------------------------------------------
 *                          standard typemaps
 * ----------------------------------------------------------------------------- */



/* -----------------------------------------------------------------------------
 * --- memberin and globalin typemaps --- 
 * ----------------------------------------------------------------------------- */

/* Character array handling */

%typemap(memberin) char [ANY] {
  if ($input) memcpy($1,$input,$1_dim0);
  else memset($1,0,$1_dim0);
}

%typemap(globalin) char [ANY] {
  if ($input) memcpy($1,$input,$1_dim0);
  else memset($1,0,$1_dim0);
}


/* -----------------------------------------------------------------------------
 * --- Input arguments --- 
 * ----------------------------------------------------------------------------- */

/* Primitive datatypes.  */

%define PY_IN_TYPEMAP(type, pyobj_as)
%typemap(in,fragment=#pyobj_as) type {
  $1 = ($1_type) pyobj_as($input);  
  if (PyErr_Occurred()) SWIG_fail;
 }
 %typemap(in) const type& ($basetype temp) {
   temp = ($basetype) pyobj_as($input);
   if (PyErr_Occurred()) SWIG_fail;
   $1 = &temp;
 }
%enddef

/* Pointers, references, and arrays */

%typemap(in) SWIGTYPE *, 
             SWIGTYPE [] 
       "if ((SWIG_ConvertPtr($input,(void **) &$1, $1_descriptor,SWIG_POINTER_EXCEPTION | $disown )) == -1) SWIG_fail;"

%typemap(in) SWIGTYPE *DISOWN 
       "if ((SWIG_ConvertPtr($input,(void **) &$1, $1_descriptor,SWIG_POINTER_EXCEPTION | SWIG_POINTER_DISOWN )) == -1) SWIG_fail;"

/* Additional check for null references */
%typemap(in) SWIGTYPE & 
       "if ((SWIG_ConvertPtr($input,(void **) &$1, $1_descriptor,SWIG_POINTER_EXCEPTION | $disown )) == -1) SWIG_fail;
        if ($1 == NULL) { PyErr_SetString(PyExc_TypeError,\"null reference\"); SWIG_fail; }"

/* Void pointer.  Accepts any kind of pointer */
%typemap(in) void * "if ((SWIG_ConvertPtr($input,(void **) &$1, 0, SWIG_POINTER_EXCEPTION | $disown )) == -1) SWIG_fail;"

/* Object passed by value. Convert to a pointer */
%typemap(in) SWIGTYPE ($&1_ltype argp) "if ((SWIG_ConvertPtr($input,(void **) &argp, $&1_descriptor,SWIG_POINTER_EXCEPTION) == -1)) SWIG_fail;
                                               $1 = *argp; ";

/* Pointer to a class member */
%typemap(in) SWIGTYPE (CLASS::*) "if ((SWIG_ConvertPacked($input, (void *) &$1, sizeof($1_type), $1_descriptor,SWIG_POINTER_EXCEPTION)) == -1) SWIG_fail;";

/* The char* and char [ANY] case */
%typemap(in) char *, char const*, char *const, char const *const
{
  $1 = SWIG_PyObj_AsCharPtr($input, $descriptor(char*));
  if (PyErr_Occurred()) SWIG_fail;
}

%typemap(in) char const*&, char *const&, char const *const & 
{
  $*ltype temp = SWIG_PyObj_AsCharPtr($input, $descriptor(char*));
  if (PyErr_Occurred()) SWIG_fail;
  $1 = &temp;
}

%typemap(in) char [ANY], const char [ANY]
{  
  char temp[$1_dim0];
  SWIG_PyObj_AsCharArray($input, $descriptor(char*), temp, $1_dim0);
  if (PyErr_Occurred()) SWIG_fail;
  $1 = temp;
}


/* -----------------------------------------------------------------------------
 * --- Outnput arguments --- 
 * ----------------------------------------------------------------------------- */

/* Primitive types */
%define PY_OUT_TYPEMAP(type, pyobj_from)
  %typemap(out,fragment=#pyobj_from) type "$result = pyobj_from((type)$1);";
  %typemap(out,fragment=#pyobj_from) const type& "$result = pyobj_from((type) *($1));";
%enddef

/* Pointers, references, and arrays */
%typemap(out) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] "$result = SWIG_NewPointerObj((void *) $1, $1_descriptor, $owner);";

/* Dynamic casts */

%typemap(out) SWIGTYPE *DYNAMIC, SWIGTYPE &DYNAMIC {
   swig_type_info *ty = SWIG_TypeDynamicCast($1_descriptor, (void **) &$1);
   $result = SWIG_NewPointerObj((void *) $1, ty, $owner);
}

/* Member pointer */
%typemap(out) SWIGTYPE (CLASS::*) "$result = SWIG_NewPackedObj((void *) &$1, sizeof($1_type), $1_descriptor);";

/* Void */
%typemap(out) void "Py_INCREF(Py_None); $result = Py_None;";

/* Special typemap for character array return values */
%typemap(out) char*, char const*, char *const, char const *const,
              char *const &, char const* &, char const *const &
              "$result = SWIG_PyObj_FromCharPtr((const char*)$1);";

%typemap(out) char [ANY], const char [ANY]
              "$result = SWIG_PyObj_FromCharArray((const char*)$1, $1_dim0);";

/* Primitive types--return by value */
%typemap(out) SWIGTYPE 
#ifdef __cplusplus
{
  $&1_ltype resultptr;
  resultptr = new $1_ltype(($1_ltype &) $1);
  $result = SWIG_NewPointerObj((void *) resultptr, $&1_descriptor, 1);
}
#else
{
  $&1_ltype resultptr;
  resultptr = ($&1_ltype) malloc(sizeof($1_type));
  memmove(resultptr, &$1, sizeof($1_type));
  $result = SWIG_NewPointerObj((void *) resultptr, $&1_descriptor, 1);
}
#endif


/* -----------------------------------------------------------------------------
 * --- Variable input --- 
 * ----------------------------------------------------------------------------- */

/* primitive types */
%define PY_VARIN_TYPEMAP(type, pyobj_as)
  %typemap(varin,fragment=#pyobj_as) type {
    $1_type temp = ($1_type) pyobj_as($input);  
    if (PyErr_Occurred()) {
      PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
      return 1;
    }
    $1 = temp;
  }
%enddef

/* char* and char[ANY] */
%typemap(varin) char * {
  char *cptr = SWIG_PyObj_AsNewCharPtr($input, $descriptor(char*));
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  if ($1) %swig_delete($1);
  $1 = cptr;
}

%typemap(varin,warning="451:Setting const char * variable may leak memory") const char * {
  char *cptr = SWIG_PyObj_AsNewCharPtr($input, $descriptor(char*));
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = cptr;
}

%typemap(varin) char [ANY] {
  SWIG_PyObj_AsCharArray($input, $descriptor(char*), $1, $1_dim0);
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
}

/* Pointers, references, and arrays */

%typemap(varin) SWIGTYPE [ANY] {
  void *temp;
  int ii;
  $1_basetype *b = 0;
  if ((SWIG_ConvertPtr($input,(void **) &temp, $1_descriptor, SWIG_POINTER_EXCEPTION)) == -1) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  b = ($1_basetype *) $1;
  for (ii = 0; ii < $1_size; ii++) b[ii] = *(($1_basetype *) temp + ii);
}

%typemap(varin) SWIGTYPE * {
  void *temp;
  if ((SWIG_ConvertPtr($input,(void **) &temp, $1_descriptor, SWIG_POINTER_EXCEPTION | SWIG_POINTER_DISOWN)) == -1) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = ($1_ltype) temp;
}

%typemap(varin) SWIGTYPE & {
  void *temp;
  if ((SWIG_ConvertPtr($input,(void **) &temp, $1_descriptor, SWIG_POINTER_EXCEPTION)) == -1 || temp == NULL) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = *($1_ltype) temp;
}

%typemap(varin) void * {
  void * temp;
  if ((SWIG_ConvertPtr($input,(void **) &temp, 0, SWIG_POINTER_EXCEPTION | SWIG_POINTER_DISOWN)) == -1) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = ($1_ltype) temp;
}

%typemap(varin) SWIGTYPE (CLASS::*) {
  char      temp[sizeof($1_type)];
  if ((SWIG_ConvertPacked($input,(void *) temp, sizeof($1_type), $1_descriptor, SWIG_POINTER_EXCEPTION)) == -1) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  memmove((void *) &$1,temp,sizeof($1_type));
}

%typemap(varin) SWIGTYPE {
  $&1_ltype temp;
  if ((SWIG_ConvertPtr($input, (void **) &temp, $&1_descriptor, SWIG_POINTER_EXCEPTION)) == -1) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = *(($&1_type) temp);
}

/* -----------------------------------------------------------------------------
 * --- Variable output --- 
 * ----------------------------------------------------------------------------- */

/* Primitive types */
%define PY_VAROUT_TYPEMAP(type, pyobj_from)
  %typemap(varout,fragment=#pyobj_from) type, const type&  "$result = pyobj_from((type)$1);";
%enddef

/* Pointers and arrays */
%typemap(varout) SWIGTYPE *, SWIGTYPE [] 
  "$result = SWIG_NewPointerObj((void *) $1, $1_descriptor, 0);";

/* References */
%typemap(varout) SWIGTYPE & 
  "$result = SWIG_NewPointerObj((void *) &$1, $1_descriptor, 0);";

/* Member pointer */
%typemap(varout) SWIGTYPE (CLASS::*) 
  "$result = SWIG_NewPackedObj((void *) &$1, sizeof($1_type), $1_descriptor);";

/* Void */
%typemap(varout) void "Py_INCREF(Py_None); $result = Py_None;";

/* Special typemap for char* return values */
%typemap(varout) char*, char const*, char *const, char const *const
  "$result = SWIG_PyObj_FromCharPtr($1);";

/* Special typemap for character array return values */
%typemap(varout) char [ANY], const char [ANY] 
  "$result = SWIG_PyObj_FromCharArray($1, $1_dim0);";

%typemap(varout) SWIGTYPE 
  "$result = SWIG_NewPointerObj((void *) &$1, $&1_descriptor, 0);";

/* -----------------------------------------------------------------------------
 * --- Constants --- *
 * ----------------------------------------------------------------------------- */

/* Primitive types */
%define PY_CONSTCODE_TYPEMAP(type, pyobj_from)
  %typemap(constcode,fragment=#pyobj_from) type 
     "PyDict_SetItemString(d,\"$symname\", pyobj_from((type)$value));";
%enddef

/* Pointers, arrays, objects */
%typemap(consttab) char *, char const*, char * const, char const* const
    { SWIG_PY_STRING,  (char*)"$symname", 0, 0, (void *)$value, 0}

%typemap(consttab) char [ANY], const char [ANY]
  "PyDict_SetItemString(d,\"$symname\", SWIG_PyObj_FromCharArray($value, $value_dim0));";

%typemap(consttab) SWIGTYPE *, SWIGTYPE &, SWIGTYPE []
    { SWIG_PY_POINTER, (char*)"$symname", 0, 0, (void *)$value, &$1_descriptor}

%typemap(consttab) SWIGTYPE (CLASS::*) 
    { SWIG_PY_BINARY,  (char *)"$symname", sizeof($type), 0, (void *)&$value, &$1_descriptor}


/* -----------------------------------------------------------------------------
 * --- Director typemaps --- *
 * ----------------------------------------------------------------------------- */

/*
 *
 * Inverse argument typemaps are for marshaling C/C++ parameters to call Python
 * methods from C++ proxy wrapper classes.
 *
 */

/* --- directorin typemaps --- */

/* Primitive datatypes */

%define PY_DIRECTORIN_TYPEMAP(type, pyobj_from)
  %typemap(directorin,fragment=#pyobj_from) type *DIRECTORIN "$input = pyobj_from((type) *$1_name);";
  %typemap(directorin,fragment=#pyobj_from) type, const type& "$input = pyobj_from((type) $1_name);";
%enddef

/* we just pass the char* as a pointer, much cheaper */
%typemap(directorin) char *, char const*, char *const, char const *const, 
                     char const *&, char *const &, char const *const &
  "$input = SWIG_NewPointerObj((void *) $1_name, $descriptor(char*), $owner);"
  /*  "$input = SWIG_PyObj_FromCharPtr((const char*)$1_name);"; */

/* here we need to create a python object, or we lost the 'ANY' dimension */
%typemap(directorin) char [ANY], const char [ANY] 
  "$input = SWIG_PyObj_FromCharArray((const char*)$1_name, $1_dim0);";


/* --- directorout typemaps --- */

%define PY_DIRECTOROUT_TYPEMAP(Type, pyobj_as)
  %typemap(directorargout,fragment=#pyobj_as) Type *DIRECTOROUT
    "*$result = ($basetype) pyobj_as($input);
     if (PyErr_Occurred()) throw Swig::DirectorTypeMismatchException(\"Error converting Python object using pyobj_as\");";
%typemap(directorout,fragment=#pyobj_as) Type
    "$result = ($basetype) pyobj_as($input);
    if (PyErr_Occurred()) throw Swig::DirectorTypeMismatchException(\"Error converting Python object using pyobj_as\");";
%typemap(directorout,fragment=#pyobj_as) const Type&
    "$basetype temp = ($basetype) pyobj_as($input);
     $result = &temp;
     if (PyErr_Occurred()) throw Swig::DirectorTypeMismatchException(\"Error converting Python object using pyobj_as\");";
  %typemap(directorout,fragment=#pyobj_as) Type &DIRECTOROUT = Type
%enddef

/* Char pointer and arrays */
%typemap(directorout) char *, char const*, char *const, char const* const { 
  $result = SWIG_PyObj_AsCharPtr($input, $descriptor(char*));
  if (PyErr_Occurred()) {
    Swig::DirectorTypeMismatchException("Error converting Python object into char*");
  }
 }

%typemap(directorout) char const *&, char *const &, char const *const & { 
  char* temp = SWIG_PyObj_AsCharPtr($input, $descriptor(char*));
  if (PyErr_Occurred()) {
    Swig::DirectorTypeMismatchException("Error converting Python object into char*");
  }
  $result = ($1_ltype) &temp;
}

%typemap(directorout) char [ANY], const char[ANY] (char temp[$result_dim0]) { 
  SWIG_PyObj_AsCharArray($input, $descriptor(char*), temp, $result_dim0);
  if (PyErr_Occurred()) {
    Swig::DirectorTypeMismatchException("Error converting Python object into char[$result_dim0]");
  }
  $result = temp;
}

/* Object returned by value. Convert from a pointer */
%typemap(directorout) SWIGTYPE  ($&ltype argp)
       "if ((SWIG_ConvertPtr($input,(void **) &argp, $&descriptor,SWIG_POINTER_EXCEPTION | $disown )) == -1) throw Swig::DirectorTypeMismatchException(\"Pointer conversion failed.\"); $result = *argp;";

%typemap(directorout) SWIGTYPE *, 
                      SWIGTYPE &, 
                      SWIGTYPE [] 
       "if ((SWIG_ConvertPtr($input,(void **) &$result, $descriptor,SWIG_POINTER_EXCEPTION | $disown )) == -1) throw Swig::DirectorTypeMismatchException(\"Pointer conversion failed.\");";

%typemap(directorout) void * "if ((SWIG_ConvertPtr($input,(void **) &$result, 0, SWIG_POINTER_EXCEPTION | $disown )) == -1) throw Swig::DirectorTypeMismatchException(\"Pointer conversion failed.\");";

/* ------------------------------------------------------------
 * --- Typechecking rules ---
 * ------------------------------------------------------------ */
%define PY_TYPECHECK_TYPEMAP(check, type, pyobj_asorcheck)
%typemap(typecheck,fragment=#pyobj_asorcheck,precedence=SWIG_TYPECHECK_##check) type, const type&
{
  pyobj_asorcheck($input);
  if (PyErr_Occurred()) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = 1;
  }
}
%enddef

%typecheck(SWIG_TYPECHECK_STRING) 
  char *, char const*, char *const, char const *const,
  char const*&, char *const&, char const *const & 
{
  SWIG_PyObj_AsCharPtr($input, $descriptor(char*));
  if (PyErr_Occurred()) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_CHAR_ARRAY) char [ANY], const char[ANY]
{
  char* carray = 0; size_t size = 0;
  SWIG_PyObj_AsCharArray($input, $descriptor(char*), &carray, &size);
  if (PyErr_Occurred()) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = ((carray != 0) && (size <= $input_dim0));
  }
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE *, SWIGTYPE &, SWIGTYPE []
{
  void *ptr;
  if (SWIG_ConvertPtr($input, (void **) &ptr, $1_descriptor, 0) == -1) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE 
{
  void *ptr;
  if (SWIG_ConvertPtr($input, (void **) &ptr, $&1_descriptor, 0) == -1) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_VOIDPTR) void *
{
  void *ptr;
  if (SWIG_ConvertPtr($input, (void **) &ptr, 0, 0) == -1) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = 1;
  }
}

/* ------------------------------------------------------------
 * --- Exception handling ---
 * ------------------------------------------------------------ */

%define PY_THROWS_TYPEMAP(type, pyobj_from)
  %typemap(throws,fragment=#pyobj_from) type {
  PyErr_SetObject(PyExc_RuntimeError, pyobj_from((type)$1));
    SWIG_fail;
  }
%enddef

%typemap(throws) char *, char const*, char * const, char const* const {
  PyErr_SetObject(PyExc_RuntimeError, SWIG_PyObj_FromCharPtr((const char*)$1));
  SWIG_fail;
}

%typemap(throws) char[ANY], const char[ANY] {
  PyErr_SetObject(PyExc_RuntimeError, SWIG_PyObj_FromCharArray((const char*)$1, $1_dim0));
  SWIG_fail;
}

%typemap(throws) SWIGTYPE {
  $&1_ltype temp = new $1_ltype($1);
  if ($&1_descriptor->clientdata) {
    PyErr_SetObject((PyObject *) ($&1_descriptor->clientdata), SWIG_NewPointerObj(temp,$&1_descriptor,1));
  } else {
    PyErr_SetString(PyExc_RuntimeError,"$1_type");
    //PyErr_SetObject(PyExc_RuntimeError, SWIG_NewPointerObj(temp,$&1_descriptor,1));
  }
  SWIG_fail;
}

// This doesn't work, and not sure if it is needed...
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


/* ------------------------------------------------------------
 * PyObject *  - Just pass straight through unmodified
 * ------------------------------------------------------------ */

%typemap(in)   PyObject * "$1 = $input;";
%typemap(out)  PyObject * "$result = $1;";

%typemap(constcode) PyObject * "PyDict_SetItemString(d,\"$symname\", $value);";

%typemap(directorin, parse="O") PyObject * "";
%typemap(directorout) PyObject * "$result = $input;";

%typecheck(SWIG_TYPECHECK_POINTER) PyObject * "$1 = ($input != 0);";

%typemap(throws) PyObject * {
  PyErr_SetObject(PyExc_RuntimeError, $1);
  SWIG_fail;
}

/* ------------------------------------------------------------
 * Basic as/from type specialization
 * ------------------------------------------------------------ */
/*
  typemap definition for types with As/From/Check methods
 */
%define %typemap_asfromcheck(Type, CheckCode, AsType, FromType, CheckType)  
  PY_IN_TYPEMAP(Type, AsType);
  PY_OUT_TYPEMAP(Type, FromType);
  PY_VARIN_TYPEMAP(Type, AsType);
  PY_VAROUT_TYPEMAP(Type, FromType);
  PY_CONSTCODE_TYPEMAP(Type, FromType);
  PY_DIRECTORIN_TYPEMAP(Type, FromType);
  PY_DIRECTOROUT_TYPEMAP(Type, AsType);
  PY_THROWS_TYPEMAP(Type, FromType);
  PY_TYPECHECK_TYPEMAP(CheckCode, Type, CheckType);
%enddef

/*
  typemap definition for types with As/From methods. The cheking is
  performed by calling the As method.
 */
%define %typemap_asfrom(Type, CheckCode, AsType, FromType)  
  PY_IN_TYPEMAP(Type, AsType);
  PY_OUT_TYPEMAP(Type, FromType);
  PY_VARIN_TYPEMAP(Type, AsType);
  PY_VAROUT_TYPEMAP(Type, FromType);
  PY_CONSTCODE_TYPEMAP(Type, FromType);
  PY_DIRECTORIN_TYPEMAP(Type, FromType);
  PY_DIRECTOROUT_TYPEMAP(Type, AsType);
  PY_THROWS_TYPEMAP(Type, FromType);
  PY_TYPECHECK_TYPEMAP(CheckCode, Type, AsType);
%enddef

/*
  typemap for simple types with conversor methods
  named as SWIG_PyObj_As##Name/SWIG_PyObj_From##Name 
*/
%define %typemap_stype(Type, CheckCode, Name)  
%typemap_asfrom(Type, CheckCode, SWIG_PyObj_As##Name,SWIG_PyObj_From##Name)
%enddef

/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

%include "pyprim.swg"

%typemap_stype(bool,               BOOL,    Bool);
%typemap_stype(signed char,        INT8,    SignedChar);
%typemap_stype(unsigned char,      UINT8,   UnsignedChar);
%typemap_stype(short,              INT16,   Short);
%typemap_stype(unsigned short,     UINT16,  UnsignedShort);
%typemap_stype(int,                INT32,   Int);
%typemap_stype(unsigned int,       UINT32,  UnsignedInt);
%typemap_stype(long,               INT64,   Long);
%typemap_stype(unsigned long,      UINT64,  UnsignedLong);
%typemap_stype(long long,          INT128,  LongLong);
%typemap_stype(unsigned long long, UINT128, UnsignedLongLong);
%typemap_stype(float,              FLOAT,   Float);
%typemap_stype(double,             DOUBLE,  Double);
%typemap_stype(char,               CHAR,    Char);

/* ------------------------------------------------------------
 * ---  Enums ---
 * ------------------------------------------------------------ */

%apply int { enum SWIGTYPE };
// this doesn't work very well, you need to redefined it for each enum.
%apply const int& { const enum SWIGTYPE& };


/* ------------------------------------------------------------
 * --- ANSI/Posix C typemaps ---
 * ------------------------------------------------------------ */

%apply unsigned long { size_t };
%apply const unsigned long& { const size_t& };
%apply long { ptrdiff_t };
%apply const long& { const ptrdiff_t& };

#ifdef __cplusplus
%apply unsigned long { std::size_t };
%apply const unsigned long& { const std::size_t& };
%apply long { std::ptrdiff_t };
%apply const long& { const std::ptrdiff_t& };
#endif

/* ------------------------------------------------------------
 * --- String & length ---
 * ------------------------------------------------------------ */

/* Here len doesn't include the '0' terminator */
%typemap(in) (char *STRING, int LENGTH) (char *buf, size_t size) {
  SWIG_PyObj_AsCharPtrAndSize($input, $descriptor(char*), &buf, &size);
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError,"a string is expected");
    SWIG_fail;
  }
  $1 = ($1_ltype) buf;
  $2 = ($2_ltype) (size && (buf[size -1] == 0)) ? size - 1 : size;
}

/* Here size includes the '0' terminator */
%typemap(in) (char *STRING, int SIZE) (char *buf, size_t size) {
  SWIG_PyObj_AsCharPtrAndSize($input, $descriptor(char*), &buf, &size);
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError,"a string is expected");
    SWIG_fail;
  }
  $1 = ($1_ltype) buf;
  $2 = ($2_ltype) size;
}

/* ------------------------------------------------------------
 * --- Argc & Argv ---
 * ------------------------------------------------------------ */
/* This typemap works with either a list or a tuple */
%typemap(in) (int ARGC, char **ARGV) {
  /* Check if is a list */
  int list = PyList_Check($input);
  if (list || PyTuple_Check($input)) {
    int argc = list ? PyList_Size($input) : PyTuple_Size($input);
    char **argv = %swig_new(char*, argc + 1);
    int i = 0;
    for (; i < argc; ++i) {
      PyObject *obj = list ? PyList_GetItem($input,i) : PyTuple_GetItem($input,i);
      argv[i] = SWIG_PyObj_AsCharPtr(obj, $descriptor(char*));
      if (PyErr_Occurred()) {
	PyErr_SetString(PyExc_TypeError,"list or tuple must contain strings only");
	SWIG_fail;
      }
    }
    argv[i] = 0;
    $1 = ($1_ltype) argc;
    $2 = ($2_ltype) argv;
  } else {
    $1 = 0;
    $2 = 0;
    PyErr_SetString(PyExc_TypeError,"a list or tuple is expected");
    SWIG_fail;
  }
}

%typemap(freearg) (int ARGC, char **ARGV) {
  if ($2) %swig_delete($2);
}


/*****************************************************************************
 *
 * End of C++ proxy wrapper typemaps.
 *
 *****************************************************************************/


/* ------------------------------------------------------------
 * Overloaded operator support
 * ------------------------------------------------------------ */

#ifdef __cplusplus
%rename(__add__)      *::operator+;
%rename(__pos__)      *::operator+();
%rename(__pos__)      *::operator+() const;
%rename(__sub__)      *::operator-;
%rename(__neg__)      *::operator-();
%rename(__neg__)      *::operator-() const;
%rename(__mul__)      *::operator*;
%rename(__div__)      *::operator/;
%rename(__mod__)      *::operator%;
%rename(__lshift__)   *::operator<<;
%rename(__rshift__)   *::operator>>;
%rename(__and__)      *::operator&;
%rename(__or__)       *::operator|;
%rename(__xor__)      *::operator^;
%rename(__invert__)   *::operator~;
%rename(__iadd__)     *::operator+=;
%rename(__isub__)     *::operator-=;
%rename(__imul__)     *::operator*=;
%rename(__idiv__)     *::operator/=;
%rename(__imod__)     *::operator%=;
%rename(__ilshift__)  *::operator<<=;
%rename(__irshift__)  *::operator>>=;
%rename(__iand__)     *::operator&=;
%rename(__ior__)      *::operator|=;
%rename(__ixor__)     *::operator^=;
%rename(__lt__)       *::operator<;
%rename(__le__)       *::operator<=;
%rename(__gt__)       *::operator>;
%rename(__ge__)       *::operator>=;
%rename(__eq__)       *::operator==;
%rename(__ne__)       *::operator!=;

/* Special cases */
%rename(__call__)     *::operator();

/* Ignored operators */
%ignorewarn("362:operator= ignored") operator=;
%ignorewarn("383:operator++ ignored") operator++;
%ignorewarn("384:operator-- ignored") operator--;
%ignorewarn("361:operator! ignored") operator!;
%ignorewarn("381:operator&& ignored") operator&&;
%ignorewarn("382:operator|| ignored") operator||;
%ignorewarn("386:operator->* ignored") operator->*;
%ignorewarn("389:operator[] ignored (consider using %extend)") operator[];

#endif

/* Warnings for Python keywords */
%include "pythonkw.swg"

/* The start of the Python initialization function */

%init %{
#ifdef __cplusplus
extern "C"
#endif
SWIGEXPORT(void) SWIG_init(void) {
  static PyObject *SWIG_globals = 0; 
  static int       typeinit = 0;
  PyObject *m, *d;
  int       i;
  if (!SWIG_globals) SWIG_globals = SWIG_newvarlink();
  m = Py_InitModule((char *) SWIG_name, SwigMethods);
  d = PyModule_GetDict(m);

  if (!typeinit) {
     for (i = 0; swig_types_initial[i]; i++) {
        swig_types[i] = SWIG_TypeRegister(swig_types_initial[i]);
     }
     typeinit = 1;
  }
  SWIG_InstallConstants(d,swig_const_table);
%}
