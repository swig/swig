/* ------------------------------------------------------------
 * PyObject *  - Just pass straight through unmodified
 * ------------------------------------------------------------ */

%typemap(in)   PyObject * "$1 = $input;";
%typemap(out)  PyObject * "$result = $1;";

%typemap(constcode) PyObject * "PyDict_SetItemString(d,\"$symname\", $value);";

%typemap(directorin, parse="O") PyObject * "";
%typemap(directorout) PyObject * "$result = $input;";

%typecheck(SWIG_TYPECHECK_POINTER) PyObject * "$1 = ($input != 0);";

%typemap(throws) PyObject *
  "PyErr_SetObject(PyExc_RuntimeError, $1);
   SWIG_fail;";
