/* File : example.i */
%module example

%{
extern int gcd(int x, int y);
extern int gcdmain(int argc, char *argv[]);
extern int count(char *bytes, int len, char c);
extern void capitalize (char *str, int len);
extern void circle (double cx, double cy);
extern int squareCubed (int n, int *OUTPUT);
%}

%include exception.i
%include typemaps.i

extern int    gcd(int x, int y);

%typemap(in,fragment="t_output_helper") (int argc, char *argv[]) {
  int i;
  if (!PyList_Check($input)) {
    SWIG_exception(SWIG_ValueError, "Expecting a list");
  }
  $1 = PyList_Size($input);
  if ($1 == 0) {
    SWIG_exception(SWIG_ValueError, "List must contain at least 1 element");
  }
  $2 = (char **) malloc(($1+1)*sizeof(char *));
  for (i = 0; i < $1; i++) {
    PyObject *s = PyList_GetItem($input,i);
%#if PY_VERSION_HEX >= 0x03000000
    if (!PyUnicode_Check(s)) 
%#else
    if (!PyString_Check(s)) 
%#endif
    {
      free($2);
      SWIG_exception(SWIG_ValueError, "List items must be strings");
    }
%#if PY_VERSION_HEX >= 0x03000000
    {
    int l;
    $2[i] = PyUnicode_AsStringAndSize(s, &l);
    }
%#else
    $2[i] = PyString_AsString(s);
%#endif

  }
  $2[i] = 0;
}

extern int gcdmain(int argc, char *argv[]);

%typemap(in) (char *bytes, int len) {

%#if PY_VERSION_HEX >= 0x03000000
  if (!PyUnicode_Check($input)) {
    PyErr_SetString(PyExc_ValueError,"Expected a string");
    return NULL;
  }
  $1 = PyUnicode_AsStringAndSize($input, &$2);
%#else
  if (!PyString_Check($input)) {
    PyErr_SetString(PyExc_ValueError,"Expected a string");
    return NULL;
  }
  $1 = PyString_AsString($input);
  $2 = PyString_Size($input);
%#endif
}

extern int count(char *bytes, int len, char c);


/* This example shows how to wrap a function that mutates a string */

/* Since str is modified, we make a copy of the Python object
   so that we don't violate it's mutability */

%typemap(in) (char *str, int len) {
%#if PY_VERSION_HEX >= 0x03000000
   $2 = PyUnicode_GetSize($input);
   $1 = (char *) malloc($2+1);
   memmove($1,PyUnicode_AsString($input),$2);
%#else
   $2 = PyString_Size($input);
   $1 = (char *) malloc($2+1);
   memmove($1,PyString_AsString($input),$2);
%#endif
}

/* Return the mutated string as a new object.  The t_output_helper
   function takes an object and appends it to the output object
   to create a tuple */

%typemap(argout) (char *str, int len) {
   PyObject *o;
%#if PY_VERSION_HEX >= 0x03000000
   o = PyUnicode_FromStringAndSize($1,$2);
%#else
   o = PyString_FromStringAndSize($1,$2);
%#endif
   $result = t_output_helper($result,o);
   free($1);
}   

extern void capitalize(char *str, int len);

/* A multi-valued constraint.  Force two arguments to lie
   inside the unit circle */

%typemap(check) (double cx, double cy) {
   double a = $1*$1 + $2*$2;
   if (a > 1.0) {
	SWIG_exception(SWIG_ValueError,"$1_name and $2_name must be in unit circle");
   }
}

extern void circle(double cx, double cy);


