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

/* --- Input arguments --- */


/* Primitive datatypes.  These only supply a parse code to PyTuple_ParseArgs */

%typemap(in,parse="h") short "";
%typemap(in,parse="i") int "";
%typemap(in,parse="l") long "";
%typemap(in,parse="f") float "";
%typemap(in,parse="d") double "";
%typemap(in,parse="c") char "";
%typemap(in,parse="s") char *, char [ANY] "";

%define %typemapin_pyfunc(type, pyfunc)
%typemap(in) type {
  $1 = ($1_type) pyfunc($input);  
  if (PyErr_Occurred()) SWIG_fail;
 }
%enddef

%typemapin_pyfunc(bool,           SPyObj_AsBool);
%typemapin_pyfunc(signed char,    SPyObj_AsSignedChar);
%typemapin_pyfunc(unsigned char,  SPyObj_AsUnsignedChar);
%typemapin_pyfunc(unsigned short, SPyObj_AsUnsignedShort);
%typemapin_pyfunc(unsigned int,   SPyObj_AsUnsignedInt);
%typemapin_pyfunc(unsigned long,  SPyObj_AsUnsignedLong);

%typemapin_pyfunc(long long,          SPyObj_AsLongLong);
%typemapin_pyfunc(unsigned long long, SPyObj_AsUnsignedLongLong);


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

/* Const primitive references.  Passed by value */

%define %typemapin_pyfunc_cr(type, pyfunc)
  %typemap(in) const type& ($*1_ltype temp) {
  temp = ($*1_ltype) pyfunc($input);
    if (PyErr_Occurred()) SWIG_fail;
    $1 = &temp;
  }
%enddef

%typemapin_pyfunc_cr(bool,           SPyObj_AsBool);
%typemapin_pyfunc_cr(signed char,    SPyObj_AsSignedChar);
%typemapin_pyfunc_cr(int,            SPyObj_AsInt);
%typemapin_pyfunc_cr(short,          SPyObj_AsShort);
%typemapin_pyfunc_cr(long,           SPyObj_AsLong);
%typemapin_pyfunc_cr(unsigned char,  SPyObj_AsUnsignedChar);
%typemapin_pyfunc_cr(unsigned short, SPyObj_AsUnsignedShort);
%typemapin_pyfunc_cr(unsigned int,   SPyObj_AsUnsignedInt);
%typemapin_pyfunc_cr(unsigned long,  SPyObj_AsUnsignedLong);

%typemapin_pyfunc_cr(long long,          SPyObj_AsLongLong);
%typemapin_pyfunc_cr(unsigned long long, SPyObj_AsUnsignedLongLong);

%typemapin_pyfunc_cr(float,  SPyObj_AsFloat);
%typemapin_pyfunc_cr(double, SPyObj_AsDouble);

%typemapin_pyfunc_cr(char,  SPyObj_AsChar);
%typemapin_pyfunc_cr(char*, PyString_AsString);


/* --- Output values --- */

%typemap(out) bool,
              signed char,
              short,
              unsigned char,
              unsigned short,
              int,
              long     
       "$result = PyInt_FromLong((long)$1);";

%typemap(out) unsigned int, unsigned long
       "$result = SPyObj_FromUnsignedLong((unsigned long)$1);";

%typemap(out) long long     "$result = SPyObj_FromLongLong($1);";
%typemap(out) unsigned long long "$result = SPyObj_FromUnsignedLongLong($1);";
%typemap(out) float, double "$result = PyFloat_FromDouble($1);";
%typemap(out) char *        "$result = SPyObj_FromCharPtr($1);";
%typemap(out) char          "$result = SPyObj_FromChar($1);";

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
%typemap(out) char [ANY], const char [ANY] "$result = PyString_FromString($1);";

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

/* References to primitive types.  Return by value */

%typemap(out) const bool &,
              const signed char &,
              const short &, 
              const unsigned char &,
              const unsigned short &,
              const int &,
              const long &
      "$result = PyInt_FromLong((long) *($1));";

%typemap(out) const unsigned int &, const unsigned long &
        "$result = SPyObj_FromUnsignedLong((unsigned long) *($1));";

%typemap(out) const float &, const double & 
      "$result = PyFloat_FromDouble((double) *($1));";

%typemap(out) const long long &
      "$result = SPyObj_FromLongLong(*($1));";

%typemap(out) const unsigned long long &
      "$result = SPyObj_FromUnsignedLongLong(*($1));";

%typemap(out) const char &
      "$result = SPyObj_FromChar(*($1));";

%typemap(out) const char* &
      "$result = SPyObj_FromCharPtr(*($1));";

/* --- Variable input --- */

%define %typemapvarin_pyfunc(type, pyfunc)
%typemap(varin) type {
  $1_type temp = ($1_type) pyfunc($input);  
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = temp;
 }
%enddef

%typemapvarin_pyfunc(bool,           SPyObj_AsBool);
%typemapvarin_pyfunc(signed char,    SPyObj_AsSignedChar);
%typemapvarin_pyfunc(int,            SPyObj_AsInt);
%typemapvarin_pyfunc(short,          SPyObj_AsShort);
%typemapvarin_pyfunc(long,           SPyObj_AsLong);
%typemapvarin_pyfunc(unsigned char,  SPyObj_AsUnsignedChar);
%typemapvarin_pyfunc(unsigned short, SPyObj_AsUnsignedShort);
%typemapvarin_pyfunc(unsigned int,   SPyObj_AsUnsignedInt);
%typemapvarin_pyfunc(unsigned long,  SPyObj_AsUnsignedLong);

%typemapvarin_pyfunc(long long,          SPyObj_AsLongLong);
%typemapvarin_pyfunc(unsigned long long, SPyObj_AsUnsignedLongLong);

%typemapvarin_pyfunc(float,  SPyObj_AsFloat);
%typemapvarin_pyfunc(double, SPyObj_AsDouble);

/* A single character */
%typemapvarin_pyfunc(char, SPyObj_AsChar);

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
%typemap(varin) char [ANY] {
  char *temp = (char *) PyString_AsString($input);
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  strncpy($1,temp,$1_dim0);
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

/* --- Variable output --- */

%typemap(varout) bool,
                 signed char,
                 short,
                 unsigned char,
                 unsigned short,
                 int,
                 long
       "$result = PyInt_FromLong((long)$1);";

%typemap(varout) unsigned int, unsigned long
       "$result = SPyObj_FromUnsignedLong((unsigned long)$1);";

%typemap(varout) long long     "$result = SPyObj_FromLongLong($1);";
%typemap(varout) unsigned long long "$result = SPyObj_FromUnsignedLongLong($1);";
%typemap(varout) float, double "$result = PyFloat_FromDouble($1);";
%typemap(varout) char *        "$result = SPyObj_FromCharPtr($1);";
%typemap(varout) char          "$result = SPyObj_FromChar($1);";

/* Pointers and arrays */
%typemap(varout) SWIGTYPE *, SWIGTYPE [] "$result = SWIG_NewPointerObj((void *) $1, $1_descriptor, 0);";

/* References */
%typemap(varout) SWIGTYPE & "$result = SWIG_NewPointerObj((void *) &$1, $1_descriptor, 0);";

/* Member pointer */
%typemap(varout) SWIGTYPE (CLASS::*) "$result = SWIG_NewPackedObj((void *) &$1, sizeof($1_type), $1_descriptor);";

/* Void */
%typemap(varout) void "Py_INCREF(Py_None); $result = Py_None;";

/* Special typemap for character array return values */
%typemap(varout) char [ANY], const char [ANY] "$result = PyString_FromString($1);";

%typemap(varout) SWIGTYPE "$result = SWIG_NewPointerObj((void *) &$1, $&1_descriptor, 0);";

/* --- Constants --- */

%typemap(consttab) bool, signed char, short, int, long, unsigned char, unsigned short
       { SWIG_PY_INT,     (char *)"$symname", (long) $value, 0, 0, 0}

%typemap(consttab) float, double
       { SWIG_PY_FLOAT,   (char*)"$symname", 0, (double) $value, 0, 0}

%typemap(consttab) char, char *
       { SWIG_PY_STRING,  (char*)"$symname", 0, 0, (void *)"$value", 0}

%typemap(consttab) SWIGTYPE *, SWIGTYPE &, SWIGTYPE []
       { SWIG_PY_POINTER, (char*)"$symname", 0, 0, (void *)$value, &$1_descriptor}

%typemap(consttab) SWIGTYPE (CLASS::*) 
       { SWIG_PY_BINARY,  (char *)"$symname", sizeof($type), 0, (void *)&$value, &$1_descriptor}

%typemap(constcode) unsigned int, unsigned long
        "PyDict_SetItemString(d,\"$symname\", SPyObj_FromUnsignedLong($value));";

%typemap(constcode) long long 
        "PyDict_SetItemString(d,\"$symname\", SPyObj_FromLongLong($value));";

%typemap(constcode) unsigned long long 
        "PyDict_SetItemString(d,\"$symname\", SPyObj_FromUnsignedLongLong($value));";



/*****************************************************************************
 *
 * Inverse argument typemaps are for marshaling C/C++ parameters to call Python
 * methods from C++ proxy wrapper classes.
 *
 *****************************************************************************/

/* directorin typemaps */

/* Primitive datatypes.  These only supply a parse code to PyObject_CallMethod */
%define %typemapdirectorin_pyfunc(type, _pyfunc)
%typemap(directorin) _type "$input = _pyfunc(($1_ltype) $1_name);";
%typemap(directorin) _type "$input = _pyfunc(($*1_ltype) $1_name);";
%enddef

%define %typemapdirectorin_parse(_type, _parse)
  %typemap(directorin,parse=_parse) _type "($1_ltype) $1_name";
  %typemap(directorin,parse=_parse) const _type& "($*1_ltype) $1_name";
%enddef

%typemapdirectorin_parse(bool,           "i");
%typemapdirectorin_parse(signed char,    "i");
%typemapdirectorin_parse(unsigned char,  "i");
%typemapdirectorin_parse(short,          "i");
%typemapdirectorin_parse(unsigned short, "i");
%typemapdirectorin_parse(int,            "i");
%typemapdirectorin_parse(long,           "l");

%typemapdirectorin_parse(float,  "f");
%typemapdirectorin_parse(double, "d");
%typemapdirectorin_parse(char,   "c");
%typemapdirectorin_parse(char*,  "s");

%typemapdirectorin_pyfunc(unsigned int, SPyObj_FromUnsignedLong);
%typemapdirectorin_pyfunc(unsigned long, SPyObj_FromUnsignedLong);
%typemapdirectorin_pyfunc(long long, SPyObj_FromLongLong);
%typemapdirectorin_pyfunc(unsigned long long, SPyObj_FromUnsignedLongLong);


%typemap(directorin, parse="l") bool *DIRECTORIN, 
                                signed char *DIRECTORIN,
                                unsigned char *DIRECTORIN,
                                short *DIRECTORIN,
                                unsigned short *DIRECTORIN,
                                int *DIRECTORIN, 
                                long *DIRECTORIN "(long) *$1_name";

%typemap(directorin) unsigned int *DIRECTORIN, 
                     unsigned long *DIRECTORIN
        "$input = SPyObj_FromUnsignedLong((unsigned long) *$1_name);";

%typemap(directorin,parse="f") float *DIRECTORIN "*$1_name";
%typemap(directorin,parse="d") double *DIRECTORIN "*$1_name";
%typemap(directorin,parse="c") char *DIRECTORIN "*$1_name";
%typemap(directorin,parse="s") char **DIRECTORIN "*$1_name";

%typemap(directorin,parse="O") PyObject* "";

/* // this is rather dangerous
%typemap(directorin) SWIGTYPE  {
{
  $input = SWIG_NewPointerObj((void *) &$1_name, $&1_descriptor, $owner);
}
}
*/

/* no can do... see python.cxx
%typemap(directorin) DIRECTORTYPE * {
        {
                SwigDirector::$1_ltype proxy = dynamic_cast<SwigDirector::$1_ltype>($1_name);
                if (!proxy) {
                        $input = SWIG_NewPointerObj((void *) $1_name, $1_descriptor, 0);
                } else {
                        $input = proxy->swig_get_self();
                }
        }
}
%typemap(directorin) SWIGTYPE * {
                $input = SWIG_NewPointerObj((void *) $1_name, $1_descriptor, 0);
}
*/

/* // not currently needed, see python.cxx
%typemap(directorin) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] {
        $input = SWIG_NewPointerObj((void *) $1_name, $1_descriptor, $owner);
}
%typemap(directorin, parse="s") void "0";
*/


/* --- directorout typemaps --- */

%define DIRECTOROUT_TYPEMAP(type, converter)
%typemap(directorargout) type *DIRECTOROUT
   "*$result = ($ltype) converter($input);
   if (PyErr_Occurred()) throw Swig::DirectorTypeMismatchException(\"Error converting Python object using converter\");";
%typemap(directorout) type 
   "$result = ($ltype) converter($input);
   if (PyErr_Occurred()) throw Swig::DirectorTypeMismatchException(\"Error converting Python object using converter\");";
%typemap(directorout) type &DIRECTOROUT = type
%enddef

DIRECTOROUT_TYPEMAP(signed char, SPyObj_AsSignedChar);
DIRECTOROUT_TYPEMAP(short,       SPyObj_AsShort);
DIRECTOROUT_TYPEMAP(int,         SPyObj_AsInt);
DIRECTOROUT_TYPEMAP(long,        SPyObj_AsLong);
DIRECTOROUT_TYPEMAP(long long,   SPyObj_AsLongLong);

DIRECTOROUT_TYPEMAP(unsigned char,      SPyObj_AsUnsignedChar);
DIRECTOROUT_TYPEMAP(unsigned short,     SPyObj_AsUnsignedShort);
DIRECTOROUT_TYPEMAP(unsigned int,       SPyObj_AsUnsignedInt);
DIRECTOROUT_TYPEMAP(unsigned long,      SPyObj_AsUnsignedLong);
DIRECTOROUT_TYPEMAP(unsigned long long, SPyObj_AsUnsignedLongLong);

DIRECTOROUT_TYPEMAP(float,  SPyObj_AsFloat);
DIRECTOROUT_TYPEMAP(double, SPyObj_AsDouble);
DIRECTOROUT_TYPEMAP(bool,   SPyObj_AsBool);
DIRECTOROUT_TYPEMAP(char,   SPyObj_AsChar);
DIRECTOROUT_TYPEMAP(char *, PyString_AsString);
DIRECTOROUT_TYPEMAP(PyObject *, );

/* Object returned by value. Convert from a pointer */
%typemap(directorout) SWIGTYPE  ($&ltype argp)
       "if ((SWIG_ConvertPtr($input,(void **) &argp, $&descriptor,SWIG_POINTER_EXCEPTION | $disown )) == -1) throw Swig::DirectorTypeMismatchException(\"Pointer conversion failed.\"); $result = *argp;";

%typemap(directorout) SWIGTYPE *, 
                      SWIGTYPE &, 
                      SWIGTYPE [] 
       "if ((SWIG_ConvertPtr($input,(void **) &$result, $descriptor,SWIG_POINTER_EXCEPTION | $disown )) == -1) throw Swig::DirectorTypeMismatchException(\"Pointer conversion failed.\");";

%typemap(directorout) void * "if ((SWIG_ConvertPtr($input,(void **) &$result, 0, SWIG_POINTER_EXCEPTION | $disown )) == -1) throw Swig::DirectorTypeMismatchException(\"Pointer conversion failed.\");";



/*****************************************************************************
 *
 * End of C++ proxy wrapper typemaps.
 *
 *****************************************************************************/

/* ------------------------------------------------------------
 * String & length
 * ------------------------------------------------------------ */

%typemap(in) (char *STRING, int LENGTH) {
    $1 = ($1_ltype) PyString_AsString($input);
    $2 = ($2_ltype) PyString_Size($input);
}

/* ------------------------------------------------------------
 * Enums
 * ------------------------------------------------------------ */

%apply int { enum SWIGTYPE };
%apply const int& { const enum SWIGTYPE& };

/* ------------------------------------------------------------
 * ANSI C typemaps
 * ------------------------------------------------------------ */

%apply unsigned long { size_t };
%apply const unsigned long& { const size_t& };


#ifdef __cplusplus
%apply unsigned long { std::size_t };
%apply const unsigned long& { const std::size_t& };
#endif

/* ------------------------------------------------------------
 * PyObject *  - Just pass straight through unmodified
 * ------------------------------------------------------------ */

%typemap(in)   PyObject * "$1 = $input;";
%typemap(out)  PyObject * "$result = $1;";

/* ------------------------------------------------------------
 * Typechecking rules
 * ------------------------------------------------------------ */
%define %typecheck_pyfunc(check, type, pyfunc)
%typecheck(SWIG_TYPECHECK_##check) type, const type&
{
  pyfunc($input);
  if (PyErr_Occurred()) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = 1;
  }
}
%enddef

%typecheck_pyfunc(BOOL,    bool,               SPyObj_AsBool);
%typecheck_pyfunc(INT8,    signed char,        SPyObj_AsSignedChar);
%typecheck_pyfunc(UINT8,   unsigned char,      SPyObj_AsUnsignedChar);
%typecheck_pyfunc(INT16,   short,              SPyObj_AsShort);
%typecheck_pyfunc(UINT16,  unsigned short,     SPyObj_AsUnsignedShort);
%typecheck_pyfunc(INT32,   int,                SPyObj_AsInt);
%typecheck_pyfunc(UINT32,  unsigned int,       SPyObj_AsUnsignedInt);
%typecheck_pyfunc(INTEGER, unsigned long,      SPyObj_AsUnsginedLong);
%typecheck_pyfunc(INTEGER, unsigned long long, SPyObj_AsUnsignedLongLong);
%typecheck_pyfunc(CHAR,    char,               SPyObj_AsChar);
%typecheck_pyfunc(FLOAT,   float,              SPyObj_AsFloat);

%typecheck(SWIG_TYPECHECK_INTEGER) 
  long, const long &,
  long long, const long long &
{
  $1 = (PyInt_Check($input) || PyLong_Check($input)) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_DOUBLE) double, const double &
{
  $1 = (PyFloat_Check($input) || PyInt_Check($input) || PyLong_Check($input)) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_STRING) char * {
  $1 = PyString_Check($input) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] {
  void *ptr;
  if (SWIG_ConvertPtr($input, (void **) &ptr, $1_descriptor, 0) == -1) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE {
  void *ptr;
  if (SWIG_ConvertPtr($input, (void **) &ptr, $&1_descriptor, 0) == -1) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_VOIDPTR) void * {
  void *ptr;
  if (SWIG_ConvertPtr($input, (void **) &ptr, 0, 0) == -1) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_POINTER) PyObject *
{
  $1 = ($input != 0);
}

/* ------------------------------------------------------------
 * Exception handling
 * ------------------------------------------------------------ */

%typemap(throws) bool,
                 signed char, 
                 unsigned short,
                 short,
                 unsigned char,
                 int,
                 long {
  PyErr_SetObject(PyExc_RuntimeError, PyInt_FromLong($1));
  SWIG_fail;
}

%typemap(throws) unsigned int, unsigned long {
  PyErr_SetObject(PyExc_RuntimeError, SPyObj_FromUnsignedLong($1));
  SWIG_fail;
}

%typemap(throws) long long {
  PyErr_SetObject(PyExc_RuntimeError, SPyObj_FromLongLong($1));
  SWIG_fail;
}

%typemap(throws) unsigned long long {
  PyErr_SetObject(PyExc_RuntimeError, SPyObj_FromUnsignedLongLong($1));
  SWIG_fail;
}

%typemap(throws) char {
  PyErr_SetObject(PyExc_RuntimeError, SPyObj_FromChar($1));
  SWIG_fail;
}

%typemap(throws) char * {
  PyErr_SetString(PyExc_RuntimeError, $1);
  SWIG_fail;
}

%typemap(throws) float, double {
  PyErr_SetObject(PyExc_RuntimeError, PyFloat_FromDouble($1));
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

/*
%typemap(throws) SWIGTYPE {
  PyErr_SetString(PyExc_RuntimeError,"$1_type");
  SWIG_fail;
}
*/

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






