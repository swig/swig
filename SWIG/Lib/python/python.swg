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

%typemap(in,parse="i") int "";
%typemap(in,parse="h") short "";
%typemap(in,parse="l") long "";
%typemap(in,parse="b") signed char "";

%typemap(in) unsigned int, unsigned short, unsigned long, unsigned char 
        "$1 = ($1_ltype) PyInt_AsLong($input);
         if (PyErr_Occurred()) SWIG_fail;";

%typemap(in) long long 
        "$1 = ($1_ltype) PyLong_AsLongLong($input);
         if (PyErr_Occurred()) SWIG_fail;";


%typemap(in) unsigned long long 
        "$1 = ($1_ltype) PyLong_AsUnsignedLongLong($input);
         if (PyErr_Occurred()) SWIG_fail;";

%typemap(in,parse="f") float "";
%typemap(in,parse="d") double "";
%typemap(in,parse="c") char "";
%typemap(in,parse="s") char *, char [ANY] "";

/* Boolean values.  Have to convert from a long since */
%typemap(in) bool "$1 = PyInt_AsLong($input) ? true : false;
                   if (PyErr_Occurred()) SWIG_fail;";

/* Enum values. */
%typemap(in,parse="i") enum SWIGTYPE "";

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

%typemap(in) const int & (int temp),
             const short & (short temp),
             const long  & (long temp),
             const unsigned int & (unsigned int temp),
             const unsigned short & (unsigned short temp),
             const unsigned long & (unsigned long temp),
             const signed char & (signed char temp),
             const unsigned char & (unsigned char temp)
        "temp = ($*1_ltype) PyInt_AsLong($input);
         if (PyErr_Occurred()) SWIG_fail;
         $1 = &temp;";

%typemap(in) const bool & (bool temp)
        "temp = PyInt_AsLong($input) ? true : false;
         if (PyErr_Occurred()) SWIG_fail;
         $1 = &temp;";

%typemap(in) const float & (float temp),
             const double & (double temp)
        "temp = ($*1_ltype) PyFloat_AsDouble($input);
         if (PyErr_Occurred()) SWIG_fail;
         $1 = &temp;";

%typemap(in) const long long & ($*1_ltype temp) 
        "temp = ($*1_ltype) PyLong_AsLongLong($input);
         if (PyErr_Occurred()) SWIG_fail;
         $1 = &temp;";

%typemap(in) const unsigned long long & ($*1_ltype temp) 
        "temp = ($*1_ltype) PyLong_AsUnsignedLongLong($input);
         if (PyErr_Occurred()) SWIG_fail;
         $1 = &temp;";

%typemap(in) const char &(char temp) {
        char *stemp = PyString_AsString($input);
        if (PyErr_Occurred()) SWIG_fail;
        temp = *stemp;
        $1 = &temp;
}

/* --- Output values --- */

%typemap(out)  int, unsigned int,
                      short, unsigned short,
                      long, unsigned long,
                      signed char, unsigned char, 
                      bool, enum SWIGTYPE
       "$result = PyInt_FromLong((long)$1);";

%typemap(out) long long     "$result = PyLong_FromLongLong($1);";
%typemap(out) unsigned long long "$result = PyLong_FromUnsignedLongLong($1);";
%typemap(out) float, double "$result = PyFloat_FromDouble($1);";
%typemap(out) char *        "$result = $1 ? PyString_FromString($1) : Py_BuildValue((char*)\"\");";
%typemap(out) char          "$result = Py_BuildValue((char*)\"c\",$1);";

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

%typemap(out) const int &, const unsigned int &,
              const short &, const unsigned short &,
              const long &, const unsigned long &,
              const signed char &, const unsigned char &,
              const bool &
      "$result = PyInt_FromLong((long) *($1));";

%typemap(out) const float &, const double & 
      "$result = PyFloat_FromDouble((double) *($1));";

%typemap(out) const long long &
      "$result = PyLong_FromLongLong(*($1));";

%typemap(out) const unsigned long long &
      "$result = PyLong_FromUnsignedLongLong(*($1));";

%typemap(out) const char &
      "$result = PyString_FromStringAndSize($1,1);";

/* --- Variable input --- */

%typemap(varin) int, unsigned int, short, unsigned short, long, unsigned long, signed char, unsigned char, enum SWIGTYPE
{
  long temp = PyInt_AsLong($input);
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = ($1_type) temp;
}

%typemap(varin) bool
{
  long temp = PyInt_AsLong($input);
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = temp ? true : false;
}

%typemap(varin) long long {
   $1_type temp = PyLong_AsLongLong($input);
   if (PyErr_Occurred()) {
      PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
      return 1;
   }
   $1 = temp;
}

%typemap(varin) unsigned long long {
   $1_type temp = PyLong_AsUnsignedLongLong($input);
   if (PyErr_Occurred()) {
      PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
      return 1;
   }
   $1 = temp;
}
   
%typemap(varin) float, double {
  double temp = PyFloat_AsDouble($input);
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = ($1_ltype) temp;
}

/* A single character */
%typemap(varin) char {
  char *temp = PyString_AsString($input);
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = *temp;
}

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

%typemap(varout)      int, unsigned int,
                      short, unsigned short,
                      long, unsigned long,
                      signed char, unsigned char, 
                      bool, enum SWIGTYPE
       "$result = PyInt_FromLong((long)$1);";

%typemap(varout) long long     "$result = PyLong_FromLongLong($1);";
%typemap(varout) unsigned long long "$result = PyLong_FromUnsignedLongLong($1);";
%typemap(varout) float, double "$result = PyFloat_FromDouble($1);";
%typemap(varout) char *        "$result = $1 ? PyString_FromString($1) : Py_BuildValue((char*)\"\");";
%typemap(varout) char          "$result = Py_BuildValue((char*)\"c\",$1);";

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

%typemap(consttab) int, unsigned int, short, unsigned short, long, unsigned long, unsigned char, signed char, bool, enum SWIGTYPE
       { SWIG_PY_INT,     (char *)"$symname", (long) $value, 0, 0, 0}

%typemap(consttab) float, double
       { SWIG_PY_FLOAT,   (char*)"$symname", 0, (double) $value, 0, 0}

%typemap(consttab) char, char *
       { SWIG_PY_STRING,  (char*)"$symname", 0, 0, (void *)"$value", 0}

%typemap(consttab) SWIGTYPE *, SWIGTYPE &, SWIGTYPE []
       { SWIG_PY_POINTER, (char*)"$symname", 0, 0, (void *)$value, &$1_descriptor}

%typemap(consttab) SWIGTYPE (CLASS::*) 
       { SWIG_PY_BINARY,  (char *)"$symname", sizeof($type), 0, (void *)&$value, &$1_descriptor}

%typemap(constcode) long long "PyDict_SetItemString(d,\"$symname\", PyLong_FromLongLong($value));";
%typemap(constcode) unsigned long long "PyDict_SetItemString(d,\"$symname\", PyLong_FromUnsignedLongLong($value));";



/*****************************************************************************
 *
 * Inverse argument typemaps are for marshaling C/C++ parameters to call Python
 * methods from C++ proxy wrapper classes.
 *
 *****************************************************************************/

/* directorin typemaps */

/* Primitive datatypes.  These only supply a parse code to PyObject_CallMethod */

%typemap(directorin,parse="i") int "";
%typemap(directorin,parse="h") short "";
%typemap(directorin,parse="l") long "";
%typemap(directorin,parse="b") signed char "";
%typemap(directorin,parse="f") float "";
%typemap(directorin,parse="d") double "";
%typemap(directorin,parse="s") char* "";
%typemap(directorin,parse="i") bool "";
%typemap(directorin,parse="i") enum SWIGTYPE "";

%typemap(directorin,parse="l") unsigned int, unsigned short, 
  unsigned long, unsigned char "(long) $1_name";

        
%typemap(directorin) long long 
  "$input = PyLong_FromLongLong($1_name);";
%typemap(directorin) unsigned long long 
  "$input = PyLong_FromUnsignedLongLong($1_name);";

%typemap(directorin,parse="i") const int& "";
%typemap(directorin,parse="h") const short& "";
%typemap(directorin,parse="l") const long& "";
%typemap(directorin,parse="b") const signed char& "";
%typemap(directorin,parse="f") const float& "";
%typemap(directorin,parse="d") const double& "";
%typemap(directorin,parse="i") const bool& "";

%typemap(directorin,parse="l") const unsigned int&, 
  const unsigned short&,  const unsigned long&,
  const unsigned char& "(long) $1_name";

        
%typemap(directorin) const long long& 
  "$input = PyLong_FromLongLong($1_name);";
%typemap(directorin) const unsigned long long& 
  "$input = PyLong_FromUnsignedLongLong($1_name);";


%typemap(directorin, parse="l") int *DIRECTORIN, long* DIRECTORIN, 
                         unsigned int *DIRECTORIN, unsigned long *DIRECTORIN, 
                         short *DIRECTORIN, unsigned short *DIRECTORIN, 
                         char *DIRECTORIN, unsigned char *DIRECTORIN
                         "(long) *$1_name";
%typemap(directorin, parse="f") float *DIRECTORIN "*$1_name";
%typemap(directorin, parse="d") double *DIRECTORIN "*$1_name";

%typemap(directorin, parse="O") PyObject* "";

%typemap(directorin, parse="l") std::size_t, const std::size_t& "(long) $input";

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
   "*$result = (type) converter($input);
   if (PyErr_Occurred()) throw Swig::DirectorTypeMismatchException(\"Error converting Python object using converter\");";
%typemap(directorout) type 
   "$result = (type) converter($input);
   if (PyErr_Occurred()) throw Swig::DirectorTypeMismatchException(\"Error converting Python object using converter\");";
%typemap(directorout) type &DIRECTOROUT = type
%enddef

DIRECTOROUT_TYPEMAP(char, PyInt_AsLong);
DIRECTOROUT_TYPEMAP(unsigned char, PyInt_AsLong);
DIRECTOROUT_TYPEMAP(short, PyInt_AsLong);
DIRECTOROUT_TYPEMAP(unsigned short, PyInt_AsLong);
DIRECTOROUT_TYPEMAP(int, PyInt_AsLong);
DIRECTOROUT_TYPEMAP(unsigned int, PyInt_AsLong);
DIRECTOROUT_TYPEMAP(long, PyInt_AsLong);
DIRECTOROUT_TYPEMAP(unsigned long, PyInt_AsLong);
DIRECTOROUT_TYPEMAP(long long, PyLong_AsLongLong);
DIRECTOROUT_TYPEMAP(unsigned long long, PyLong_AsUnsignedLongLong);
DIRECTOROUT_TYPEMAP(float, PyFloat_AsDouble);
DIRECTOROUT_TYPEMAP(double, PyFloat_AsDouble);
DIRECTOROUT_TYPEMAP(bool, PyInt_AsLong);
DIRECTOROUT_TYPEMAP(PyObject *, );
DIRECTOROUT_TYPEMAP(char *, PyString_AsString);
DIRECTOROUT_TYPEMAP(std::size_t, PyInt_AsLong);

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
 * ANSI C typemaps
 * ------------------------------------------------------------ */

%typemap(in)     size_t "$1 = (size_t) PyInt_AsLong($input);
                         if (PyErr_Occurred()) SWIG_fail;";

%typemap(out)      size_t = long;
%typemap(varin)    size_t = long;
%typemap(varout)   size_t = long;
%typemap(consttab) size_t = long;

/* ------------------------------------------------------------
 * PyObject *  - Just pass straight through unmodified
 * ------------------------------------------------------------ */

%typemap(in)   PyObject * "$1 = $input;";
%typemap(out)  PyObject * "$result = $1;";

/* ------------------------------------------------------------
 * Typechecking rules
 * ------------------------------------------------------------ */

%typecheck(SWIG_TYPECHECK_INTEGER)
         int, short, long,
         unsigned int, unsigned short, unsigned long,
         signed char, unsigned char,
         long long, unsigned long long,
         const int &, const short &, const long &,
         const unsigned int &, const unsigned short &, const unsigned long &,
         const long long &, const unsigned long long &,
         enum SWIGTYPE,
         bool, const bool & 
{
  $1 = (PyInt_Check($input) || PyLong_Check($input)) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_DOUBLE)
        float, double,
        const float &, const double &
{
  $1 = (PyFloat_Check($input) || PyInt_Check($input) || PyLong_Check($input)) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_CHAR) char {
  $1 = (PyString_Check($input) && (PyString_Size($input) == 1)) ? 1 : 0;
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

%typemap(throws) int, 
                  long, 
                  short, 
                  unsigned int, 
                  unsigned long, 
                  unsigned short {
  PyErr_SetObject(PyExc_RuntimeError, PyInt_FromLong((long) $1));
  SWIG_fail;
}

%typemap(throws) SWIGTYPE CLASS {
  $&1_ltype temp = new $1_ltype($1);
  if ($&1_descriptor->clientdata) {
    PyErr_SetObject((PyObject *) ($&1_descriptor->clientdata), SWIG_NewPointerObj(temp,$&1_descriptor,1));
  } else {
    PyErr_SetObject(PyExc_RuntimeError, SWIG_NewPointerObj(temp,$&1_descriptor,1));
  }
  SWIG_fail;
}

%typemap(throws) SWIGTYPE {
  PyErr_SetString(PyExc_RuntimeError,"$1_type");
  SWIG_fail;
}

%typemap(throws) char * {
  PyErr_SetString(PyExc_RuntimeError, $1);
  SWIG_fail;
}

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






