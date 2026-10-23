// Tests the Python specific director method arguments, that is the
// swig::SwigPtr_PyObject and swig::SwigVar_PyObject smart pointers, both by
// value and by const reference. These are %applied from PyObject * and so are
// subject to the same reference counting as a plain PyObject * argument, which
// is covered by the director_langobj test. A null PyObject * argument is tested
// here too, as null is not meaningful for the other languages.

%module(directors="1") python_director_pyobject

%feature("director") Callback;

%inline %{
struct Callback {
  virtual void callback(PyObject *param1) = 0;
  virtual void callback_ptr(swig::SwigPtr_PyObject param1) = 0;
  virtual void callback_ptr_ref(swig::SwigPtr_PyObject const &param1) = 0;
  virtual void callback_var(swig::SwigVar_PyObject param1) = 0;
  virtual void callback_var_ref(swig::SwigVar_PyObject const &param1) = 0;
  virtual ~Callback() {}
};

/* Each caller below must be reference count neutral on param1 so that the test
   measures the director upcall alone. SwigPtr_PyObject adds a reference when
   constructed and so is neutral already, but SwigVar_PyObject takes ownership of
   an existing reference without adding one, hence the SWIG_Py_XINCREF. */

void call_callback_ptr(Callback *handler, PyObject *param1) {
  swig::SwigPtr_PyObject ptr = param1;
  handler->callback_ptr(ptr);
}

void call_callback_ptr_ref(Callback *handler, PyObject *param1) {
  swig::SwigPtr_PyObject ptr = param1;
  handler->callback_ptr_ref(ptr);
}

void call_callback_var(Callback *handler, PyObject *param1) {
  SWIG_Py_XINCREF(param1);
  swig::SwigVar_PyObject var = param1;
  handler->callback_var(var);
}

void call_callback_var_ref(Callback *handler, PyObject *param1) {
  SWIG_Py_XINCREF(param1);
  swig::SwigVar_PyObject var = param1;
  handler->callback_var_ref(var);
}

/* A null PyObject * argument must not crash, hence SWIG_Py_XINCREF rather than
   SWIG_Py_INCREF in the directorin typemap. The upcall itself still fails as the
   null terminates the argument list early, so swallow the director error. */
bool call_callback_null(Callback *handler) {
  try {
    handler->callback(NULL);
  } catch (Swig::DirectorException &) {
    PyErr_Clear();
    return false;
  }
  return true;
}
%}
