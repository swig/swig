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

/* -----------------------------------------------------------------------------
 *                          standard typemaps
 * ----------------------------------------------------------------------------- */

/* --- macro to expand a given typemap macro using the As methods --- */
%define %expand_primitives_as(typemap)
  typemap(bool,               SPyObj_AsBool);
  typemap(signed char,        SPyObj_AsSignedChar);
  typemap(int,                SPyObj_AsInt);
  typemap(short,              SPyObj_AsShort);
  typemap(long,               SPyObj_AsLong);
  typemap(unsigned char,      SPyObj_AsUnsignedChar);
  typemap(unsigned short,     SPyObj_AsUnsignedShort);
  typemap(unsigned int,       SPyObj_AsUnsignedInt);
  typemap(unsigned long,      SPyObj_AsUnsignedLong);
  typemap(long long,          SPyObj_AsLongLong);
  typemap(unsigned long long, SPyObj_AsUnsignedLongLong);
  typemap(float,              SPyObj_AsFloat);
  typemap(double,             SPyObj_AsDouble);
  typemap(char,               SPyObj_AsChar);
%enddef

/* --- macro to expand a given typemap macro using the From methods --- */
%define %expand_primitives_from(typemap)
  typemap(bool,               PyInt_FromLong);
  typemap(signed char,        PyInt_FromLong);
  typemap(int,                PyInt_FromLong);
  typemap(short,              PyInt_FromLong);
  typemap(long,               PyInt_FromLong);
  typemap(unsigned char,      PyInt_FromLong);
  typemap(unsigned short,     PyInt_FromLong);
  typemap(unsigned int,       SPyObj_FromUnsignedLong);
  typemap(unsigned long,      SPyObj_FromUnsignedLong);
  typemap(long long,          SPyObj_FromLongLong);
  typemap(unsigned long long, SPyObj_FromUnsignedLongLong);
  typemap(float,              PyFloat_FromDouble);
  typemap(double,             PyFloat_FromDouble);
  typemap(char,               SPyObj_FromChar);
%enddef


/* -----------------------------------------------------------------------------
 * --- Input arguments --- 
 * ----------------------------------------------------------------------------- */

/* Primitive datatypes.  */

%define PY_IN_TYPEMAP(type, pyobj_as)
 %typemap(in) type {
  $1 = ($1_type) pyobj_as($input);  
  if (PyErr_Occurred()) SWIG_fail;
 }
 %typemap(in) const type& ($basetype temp) {
   temp = ($basetype) pyobj_as($input);
   if (PyErr_Occurred()) SWIG_fail;
   $1 = &temp;
 }
%enddef

%expand_primitives_as(PY_IN_TYPEMAP);

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
%typemap(in) char *
{
  $1 = PyString_AsString($input);
  if (PyErr_Occurred()) SWIG_fail;
}

%typemap(in) char [ANY] (char temp[$1_dim0])
{  
  SPyObj_AsCharArray($input, temp, $1_dim0);
  if (PyErr_Occurred()) SWIG_fail;
  $1 = temp;
}


/* -----------------------------------------------------------------------------
 * --- Outnput arguments --- 
 * ----------------------------------------------------------------------------- */

/* Primitive types */
%define PY_OUT_TYPEMAP(type, pyobj_from)
  %typemap(out) type "$result = pyobj_from((type)$1);";
  %typemap(out) const type& "$result = pyobj_from((type) *($1));";
%enddef

%expand_primitives_from(PY_OUT_TYPEMAP);

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
%typemap(out) char *, const char * "$result = SPyObj_FromCharPtr((const char*)$1);";

%typemap(out) char [ANY], const char [ANY] "$result = SPyObj_FromCharArray((const char*)$1, $1_dim0);";

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
  %typemap(varin) type {
    $1_type temp = ($1_type) pyobj_as($input);  
    if (PyErr_Occurred()) {
      PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
      return 1;
    }
    $1 = temp;
  }
%enddef

%expand_primitives_as(PY_VARIN_TYPEMAP);

/* A string */
#ifdef __cplusplus

%typemap(varin) char * {
  char *temp = (char *) PyString_AsString($input);
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  if ($1) delete [] $1;
  $1 = ($type) new char[strlen(temp)+1];
  strcpy((char*)$1,temp);
}

%typemap(varin,warning="451:Setting const char * variable may leak memory") const char * {
  char *temp = (char *) PyString_AsString($input);
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = ($type) new char[strlen(temp)+1];
  strcpy((char*)$1,temp);
}

#else

%typemap(varin) char * {
  char *temp = (char *) PyString_AsString($input);
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  if ($1) free((char*) $1);
  $1 = ($type) malloc(strlen(temp)+1);
  strcpy((char*)$1,temp);
}

%typemap(varin,warning="451:Setting const char * variable may leak memory") const char * {
  char *temp = (char *) PyString_AsString($input);
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = ($type) malloc(strlen(temp)+1);
  strcpy((char*)$1,temp);
}

#endif

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

/* Special case for string array variables */
%typemap(varin) char* {
  $1 = PyString_AsString($input);
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
}

%typemap(varin) char [ANY] {
  SPyObj_AsCharArray($input, $1, $1_dim0);
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
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
  %typemap(varout) type, const type&  "$result = pyobj_from((type)$1);";
%enddef

%expand_primitives_from(PY_VAROUT_TYPEMAP);

/* Pointers and arrays */
%typemap(varout) SWIGTYPE *, SWIGTYPE [] "$result = SWIG_NewPointerObj((void *) $1, $1_descriptor, 0);";

/* References */
%typemap(varout) SWIGTYPE & "$result = SWIG_NewPointerObj((void *) &$1, $1_descriptor, 0);";

/* Member pointer */
%typemap(varout) SWIGTYPE (CLASS::*) "$result = SWIG_NewPackedObj((void *) &$1, sizeof($1_type), $1_descriptor);";

/* Void */
%typemap(varout) void "Py_INCREF(Py_None); $result = Py_None;";

/* Special typemap for character array return values */
%typemap(varout) char *, const char * "$result = SPyObj_FromCharPtr((const char*)$1);";

%typemap(varout) char [ANY], const char [ANY] "$result = SPyObj_FromCharArray((const char*)$1, $1_dim0);";

%typemap(varout) SWIGTYPE "$result = SWIG_NewPointerObj((void *) &$1, $&1_descriptor, 0);";

/* -----------------------------------------------------------------------------
 * --- Constants --- *
 * ----------------------------------------------------------------------------- */

/* Primitive types */
%define PY_CONSTCODE_TYPEMAP(type, pyobj_from)
  %typemap(constcode) type 
     "PyDict_SetItemString(d,\"$symname\", pyobj_from((type)$value));";
%enddef

%expand_primitives_from(PY_CONSTCODE_TYPEMAP);


/* Pointers, arrays, objects */
%typemap(consttab) char *, const char *
    { SWIG_PY_STRING,  (char*)"$symname", 0, 0, (void *)$value, 0}

%typemap(consttab) char [ANY], const char [ANY]
    { SWIG_PY_STRING,  (char*)"$symname", 0, 0, (void *)$value, 0}

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
  %typemap(directorin) type *DIRECTORIN "$input = pyobj_from((type) *$1_name);";
  %typemap(directorin) type, const type& "$input = pyobj_from((type) $1_name);";
%enddef

%expand_primitives_from(PY_DIRECTORIN_TYPEMAP);


/* Special typemap for character array return values */

%typemap(directorin) char*, const char * "$input = SPyObj_FromCharPtr((const char*)$1_name);";

%typemap(directorin) char [ANY], const char [ANY] "$input = SPyObj_FromCharArray((const char*)$1_name, $1_dim0);";


/* --- directorout typemaps --- */

%define PY_DIRECTOROUT_TYPEMAP(Type, pyobj_as)
  %typemap(directorargout) Type *DIRECTOROUT
    "*$result = ($ltype) pyobj_as($input);
     if (PyErr_Occurred()) throw Swig::DirectorTypeMismatchException(\"Error converting Python object using pyobj_as\");";
%typemap(directorout) Type
    "$result = ($ltype) pyobj_as($input);
    if (PyErr_Occurred()) throw Swig::DirectorTypeMismatchException(\"Error converting Python object using pyobj_as\");";
%typemap(directorout) const Type&
    "$basetype temp = ($basetype) pyobj_as($input);
     $result = &temp;
     if (PyErr_Occurred()) throw Swig::DirectorTypeMismatchException(\"Error converting Python object using pyobj_as\");";
  %typemap(directorout) Type &DIRECTOROUT = Type
%enddef

%expand_primitives_as(PY_DIRECTOROUT_TYPEMAP);

/* Char pointer and arrays */
%typemap(directorout) char * { 
  $result = PyString_AsString($input);
  if (PyErr_Occurred()) {
    Swig::DirectorTypeMismatchException("Error converting Python object into char*");
  }
}

%typemap(directorout) char [ANY] { 
  SPyObj_AsCharArray($input, $result, $result_dim0);
  if (PyErr_Occurred()) {
    Swig::DirectorTypeMismatchException("Error converting Python object into char[ANY]");
  }
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
%define PY_TYPECHECK_TYPEMAP(check, type, pyobj_as)
%typecheck(SWIG_TYPECHECK_##check) type, const type&
{
  pyobj_as($input);
  if (PyErr_Occurred()) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = 1;
  }
}
%enddef

PY_TYPECHECK_TYPEMAP(BOOL,    bool,               SPyObj_AsBool);
PY_TYPECHECK_TYPEMAP(INT8,    signed char,        SPyObj_AsSignedChar);
PY_TYPECHECK_TYPEMAP(UINT8,   unsigned char,      SPyObj_AsUnsignedChar);
PY_TYPECHECK_TYPEMAP(INT16,   short,              SPyObj_AsShort);
PY_TYPECHECK_TYPEMAP(UINT16,  unsigned short,     SPyObj_AsUnsignedShort);
PY_TYPECHECK_TYPEMAP(INT32,   int,                SPyObj_AsInt);
PY_TYPECHECK_TYPEMAP(UINT32,  unsigned int,       SPyObj_AsUnsignedInt);
PY_TYPECHECK_TYPEMAP(INT64,   long,               SPyObj_AsLong);
PY_TYPECHECK_TYPEMAP(UINT64,  unsigned long,      SPyObj_AsUnsignedLong);
PY_TYPECHECK_TYPEMAP(INT128,  long long,          SPyObj_AsLongLong);
PY_TYPECHECK_TYPEMAP(UINT128, unsigned long long, SPyObj_AsUnsignedLongLong);
PY_TYPECHECK_TYPEMAP(FLOAT,   float,              SPyObj_AsFloat);
PY_TYPECHECK_TYPEMAP(DOUBLE,  double,             SPyObj_AsDouble);
PY_TYPECHECK_TYPEMAP(CHAR,    char,               SPyObj_AsChar);


%typecheck(SWIG_TYPECHECK_STRING) char *
{
  $1 = PyString_Check($input) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_STRING) char [ANY]
{
  $1 = (PyString_Check($input) 
	&& (PyString_Size($input) <= $input_dim0)) ? 1 : 0;
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
  %typemap(throws) type {
  PyErr_SetObject(PyExc_RuntimeError, pyobj_from((type)$1));
    SWIG_fail;
  }
%enddef

%expand_primitives_from(PY_THROWS_TYPEMAP);

%typemap(throws) char *, const char * {
  PyErr_SetObject(PyExc_RuntimeError, SPyObj_FromCharPtr((const char*)$1));
  SWIG_fail;
}

%typemap(throws) char[ANY], const char[ANY] {
  PyErr_SetObject(PyExc_RuntimeError, SPyObj_FromCharArray((const char*)$1, $1_dim0));
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

%typemap(in) (char *STRING, int LENGTH) {
    $1 = ($1_ltype) PyString_AsString($input);
    $2 = ($2_ltype) PyString_Size($input);
}

/* ------------------------------------------------------------
 * --- Argc & Argv ---
 * ------------------------------------------------------------ */

%typemap(in) (int ARGC, char **ARGV) {
  /* Check if is a list */
  if (PyList_Check($input)) {
    int i = 0;
    int size = PyList_Size($input);
    $1 = ($1_ltype) size;
#ifdef __cplusplus
    $2 = ($2_ltype) new char*[(size + 1)];
#else
    $2 = ($2_ltype) malloc((size + 1)*sizeof(char *));
#endif
    for (; i < size; ++i) {
      PyObject *o = PyList_GetItem($input,i);
      if (PyString_Check(o))
	$2[i] = PyString_AsString(PyList_GetItem($input,i));
      else {
	PyErr_SetString(PyExc_TypeError,"list must contain strings");
	SWIG_fail;
      }
    }
    $2[i] = 0;
  } else {
    PyErr_SetString(PyExc_TypeError,"argument is not a python list");
    SWIG_fail;
  }
}

#ifdef __cplusplus
%typemap(freearg) (int ARGC, char **ARGV) "if ($2) delete[] $2;";
#else
%typemap(freearg) (int ARGC, char **ARGV) "if ($2) free((char *) $2);";
#endif
  

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
