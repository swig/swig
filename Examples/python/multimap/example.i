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
  $1 = (int)PyList_Size($input);
  if ($1 == 0) {
    SWIG_exception(SWIG_ValueError, "List must contain at least 1 element");
  }
  $2 = (char **) malloc(($1+1)*sizeof(char *));
  for (i = 0; i < $1; i++) {
    PyObject *s = PyList_GetItem($input,i);
    if (!PyUnicode_Check(s)) 
    {
      free($2);
      SWIG_exception(SWIG_ValueError, "List items must be strings");
    }
    {
      PyObject *utf8str = PyUnicode_AsUTF8String(s);
      const char *strtmp = 0;
      if (!utf8str) {
        SWIG_fail;
      }
      strtmp = PyBytes_AsString(utf8str);
      $2[i] = (char *)malloc(strlen(strtmp) + 1);
      if ($2[i])
        strcpy($2[i], strtmp);
      Py_DECREF(utf8str);
    }
  }
  $2[i] = 0;
}

%typemap(freearg) (int argc, char *argv[]) {
  int i;
  for (i = 0; i < $1; i++) {
    free($2[i]);
  }
}

extern int gcdmain(int argc, char *argv[]);

%typemap(in) (char *bytes, int len) {
  char *cstr;
  Py_ssize_t len;
  PyObject *utf8str;
  if (!PyUnicode_Check($input)) {
    PyErr_SetString(PyExc_ValueError,"Expected a string");
    SWIG_fail;
  }
  utf8str = PyUnicode_AsUTF8String($input);
  if (!utf8str) {
    SWIG_fail;
  }
  PyBytes_AsStringAndSize(utf8str, &cstr, &len);
  $1 = strncpy((char *)malloc(len+1), cstr, (size_t)len);
  $2 = (int)len;
  Py_DECREF(utf8str);
}

%typemap(freearg) (char *bytes, int len) {
  free($1);
}

extern int count(char *bytes, int len, char c);


/* This example shows how to wrap a function that mutates a string */

/* Since str is modified, we make a copy of the Python object
   so that we don't violate its mutability */

%typemap(in) (char *str, int len) {
  char *cstr;
  Py_ssize_t len;
  PyObject *utf8str = PyUnicode_AsUTF8String($input);
  if (!utf8str) {
    SWIG_fail;
  }
  PyBytes_AsStringAndSize(utf8str, &cstr, &len);
  $1 = strncpy((char *)malloc(len+1), cstr, (size_t)len);
  $2 = (int)len;
  Py_DECREF(utf8str);
}

/* Return the mutated string as a new object.  The t_output_helper
   function takes an object and appends it to the output object
   to create a tuple */

%typemap(argout) (char *str, int len) {
   PyObject *o = PyUnicode_FromStringAndSize($1,$2);
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


