/* -----------------------------------------------------------------------------
 * python.swg
 *
 * Python configuration module.
 * ----------------------------------------------------------------------------- */

%insert(runtime) "common.swg";          // Common type-checking code
%insert(runtime) "pyrun.swg";           // Python run-time code

/* Special directive for shadow code */

#define %shadow  %insert("shadow")

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
         if (PyErr_Occurred()) return NULL;";

%typemap(in) long long 
        "$1 = (long long) PyLong_AsLongLong($input);
         if (PyErr_Occurred()) return NULL;";


%typemap(in) unsigned long long 
        "$1 = (unsigned long long) PyLong_AsUnsignedLongLong($input);
         if (PyErr_Occurred()) return NULL;";

%typemap(in,parse="f") float "";
%typemap(in,parse="d") double "";
%typemap(in,parse="c") char "";
%typemap(in,parse="s") char * "";

/* Boolean values.  Have to convert from a long since */
%typemap(in) bool "$1 = (bool) PyInt_AsLong($input);
                   if (PyErr_Occurred()) return NULL;";

/* Enum values. */
%typemap(in,parse="i") enum SWIGTYPE "";

/* Pointers, references, and arrays */

%typemap(in) SWIGTYPE *, 
                    SWIGTYPE &,
                    SWIGTYPE [] 
       "if ((SWIG_ConvertPtr($input,(void **) &$1, $1_descriptor,1)) == -1) return NULL;"

/* Void pointer.  Accepts any kind of pointer */
%typemap(in) void * "if ((SWIG_ConvertPtr($input,(void **) &$1, 0, 1)) == -1) return NULL;"

/* Object passed by value. Convert to a pointer */
%typemap(in) SWIGTYPE ($&1_ltype argp) "if ((SWIG_ConvertPtr($input,(void **) &argp, $&1_descriptor,1) == -1)) return NULL;
                                               $1 = *argp; ";

/* Pointer to a class member */
%typemap(in) SWIGTYPE (CLASS::*) "if ((SWIG_ConvertPacked($input, (void *) &$1, sizeof($1_type), $1_descriptor,1)) == -1) return NULL;";


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
  resultptr = new $1_ltype($1);
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

/* --- Variable input --- */

%typemap(varin) int, unsigned int, short, unsigned short, long, unsigned long, signed char, unsigned char, bool, enum SWIGTYPE
{
  long temp = PyInt_AsLong($input);
  if (PyErr_Occurred()) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = ($1_ltype) temp;
}

%typemap(varin) long long {
   long long temp = PyLong_AsLongLong($input);
   if (PyErr_Occurred()) {
      PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
      return 1;
   }
   $1 = temp;
}

%typemap(varin) unsigned long long {
   unsigned long long temp = PyLong_AsUnsignedLongLong($input);
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
#endif

%typemap(varin) SWIGTYPE [] {
  PyErr_SetString(PyExc_TypeError, "Variable $name is read-only.");
  return 1;
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

%typemap(varin) SWIGTYPE *, SWIGTYPE & {
  void *temp;
  if ((SWIG_ConvertPtr($input,(void **) &temp, $1_descriptor, 1)) == -1) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = ($1_ltype) temp;
}

%typemap(varin) void * {
  void * temp;
  if ((SWIG_ConvertPtr($input,(void **) &temp, 0, 1)) == -1) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = ($1_ltype) temp;
}

%typemap(varin) SWIGTYPE (CLASS::*) {
  char      temp[sizeof($1_type)];
  if ((SWIG_ConvertPacked($input,(void *) temp, sizeof($1_type), $1_descriptor, 1)) == -1) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  memmove((void *) &$1,temp,sizeof($1_type));
}

%typemap(varin) SWIGTYPE {
  $&1_ltype temp;
  if ((SWIG_ConvertPtr($input, (void **) &temp, $&1_descriptor, 1)) == -1) {
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

/* Pointers, references, and arrays */
%typemap(varout) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] "$result = SWIG_NewPointerObj((void *) $1, $1_descriptor, 0);";

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

/* Overloaded operator support */
#ifdef __cplusplus
%rename(__add__)      *::operator+;
%rename(__pos__)      *::operator+();
%rename(__sub__)      *::operator-;
%rename(__neg__)      *::operator-();
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
%ignorewarn("operator= ignored") operator=;
%ignorewarn("operator++ ignored") operator++;
%ignorewarn("operator-- ignored") operator--;
%ignorewarn("operator&& ignored") operator&&;
%ignorewarn("operator|| ignored") operator||;
%ignorewarn("operator-> ignored") operator->;
%ignorewarn("operator->* ignored") operator->*;
%ignorewarn("operator[] ignored (consider using %addmethods)") operator[];

#endif

/* Warnings for certain Python keywords */
#define PYKW(x) %namewarn(#x " is a python keyword")  #x

PYKW(and);
PYKW(assert);
PYKW(break);
PYKW(class);
PYKW(continue);
PYKW(def);
PYKW(del);
PYKW(elif);
PYKW(else);
PYKW(except);
PYKW(exec);
PYKW(finally);
PYKW(for);
PYKW(from);
PYKW(global);
PYKW(if);
PYKW(import);
PYKW(in);
PYKW(is);
PYKW(lambda);
PYKW(not);
PYKW(or);
PYKW(pass);
PYKW(print);
PYKW(raise);
PYKW(return);
PYKW(try);
PYKW(while);


/* The start of the Python initialization function */

%init %{
#ifdef __cplusplus
extern "C"
#endif
SWIGEXPORT(void) SWIG_init(void) {
  static PyObject *SWIG_globals = 0;
  PyObject *m, *d;
  int       i;
  SWIG_globals = SWIG_newvarlink();
  m = Py_InitModule((char *) SWIG_name, SwigMethods);
  d = PyModule_GetDict(m);

  for (i = 0; swig_types_initial[i]; i++) {
    swig_types[i] = SWIG_TypeRegister(swig_types_initial[i]);
  }
  SWIG_InstallConstants(d,swig_const_table);
%}






