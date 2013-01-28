%module python_varargs_typemap

 /* The typemap and action are taken from the "Variable length arguments"
  * chapter of the SWIG manual.
  */

%{
%}

%typemap(in) (...)(char *args[10]) {
  int i;
  int argc;
  for (i = 0; i < 10; i++) args[i] = 0;
  argc = PyTuple_Size(varargs);
  if (argc > 10) {
    PyErr_SetString(PyExc_ValueError, "Too many arguments");
    return NULL;
  }
  for (i = 0; i < argc; i++) {
    PyObject *pyobj = PyTuple_GetItem(varargs, i);
    char *str = 0;
%#if PY_VERSION_HEX>=0x03000000
    PyObject *pystr;
    if (!PyUnicode_Check(pyobj)) {
       PyErr_SetString(PyExc_ValueError, "Expected a string");
       return NULL;
    }
    pystr = PyUnicode_AsUTF8String(pyobj);
    str = PyBytes_AsString(pystr);
    Py_XDECREF(pystr);
%#else  
    if (!PyString_Check(pyobj)) {
       PyErr_SetString(PyExc_ValueError, "Expected a string");
       return NULL;
    }
    str = PyString_AsString(pyobj);
%#endif
    args[i] = str;
  }
  $1 = (void *) args;
}

%feature("action") testfunc {
  char **args = (char **) arg3;
  result = testfunc(arg1, arg2, args[0], args[1], args[2], args[3], args[4],
                    args[5],args[6],args[7],args[8],args[9], NULL);
}

%inline {
char* testfunc (int arg1, double arg2, ...)
{
  va_list ap;
  char *c;
  va_start(ap, arg2);
  c = va_arg(ap, char*);
  va_end(ap);
  return c;
}
}

%inline %{
char *doublecheck(char *inputval) { return inputval; }
%}

