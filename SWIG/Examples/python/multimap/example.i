/* File : example.i */
%module example
%include exception.i
%include typemaps.i

extern int    gcd(int x, int y);

%typemap(python,in) (int argc, char *argv[]) {
  int i;
  if (!PyList_Check($source)) {
    SWIG_exception(SWIG_ValueError, "Expecting a list");
    return NULL;
  }
  $0 = PyList_Size($source);
  if ($0 == 0) {
    SWIG_exception(SWIG_ValueError, "List must contain at least 1 element");
    return NULL;
  }
  $1 = (char **) malloc(($0+1)*sizeof(char *));
  for (i = 0; i < $0; i++) {
    PyObject *s = PyList_GetItem($source,i);
    if (!PyString_Check(s)) {
      SWIG_exception(SWIG_ValueError, "List items must be strings");
      free($1);
      return NULL;
    }
    $1[i] = PyString_AsString(s);
  }
  $1[i] = 0;
}

extern int gcdmain(int argc, char *argv[]);

%typemap(python,in) (char *bytes, int len) {
  if (!PyString_Check($source)) {
    PyErr_SetString(PyExc_ValueError,"Expected a string");
    return NULL;
  }
  $0 = PyString_AsString($source);
  $1 = PyString_Size($source);
}

extern int count(char *bytes, int len, char c);


/* This example shows how to wrap a function that mutates a string */

/* Since str is modified, we make a copy of the Python object
   so that we don't violate it's mutability */

%typemap(python,in) (char *str, int len) {
   $1 = PyString_Size($arg);
   $0 = (char *) malloc($1+1);
   memmove($0,PyString_AsString($arg),$1);
}

/* Return the mutated string as a new object.  The t_output_helper
   function takes an object and appends it to the output object
   to create a tuple */

%typemap(python,argout) (char *str, int len) {
   PyObject *o;
   o = PyString_FromStringAndSize($0,$1);
   $target = t_output_helper($target,o);
   free($0);
}   

extern void capitalize(char *str, int len);

/* A multi-valued constraint.  Force two arguments to lie
   inside the unit circle */

%typemap(check) (double cx, double cy) {
   double a = $0*$0 + $1*$1;
   if (a > 1.0) {
	SWIG_exception(SWIG_ValueError,"$0_name and $1_name must be in unit circle");
        return NULL;
   }
}

extern void circle(double cx, double cy);


