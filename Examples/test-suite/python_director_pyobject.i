// Tests that a PyObject * director method argument is passed through to Python
// unchanged and does not have its reference count altered by the upcall. The
// wrapper variable holding the argument DECREFs on scope exit, so the borrowed
// argument must be INCREFed. Covers the const reference forms too, which had no
// directorin typemap at all and so were wrapped as an opaque proxy object.

%module(directors="1") python_director_pyobject

%feature("director") Callback;

%inline %{
struct Callback {
  virtual void callback(PyObject *param1) = 0;
  virtual void callback_ref(PyObject *const &param1) = 0;
  virtual void callback_ptr(swig::SwigPtr_PyObject param1) = 0;
  virtual void callback_ptr_ref(swig::SwigPtr_PyObject const &param1) = 0;
  virtual void callback_var(swig::SwigVar_PyObject param1) = 0;
  virtual void callback_var_ref(swig::SwigVar_PyObject const &param1) = 0;
  virtual ~Callback() {}
};

/* Each caller below must be reference count neutral on param1 so that the test
   measures the director upcall alone. SwigPtr_PyObject adds a reference when
   constructed and so is neutral already, but SwigVar_PyObject takes ownership
   of an existing reference without adding one, hence the SWIG_Py_XINCREF. */

void call_callback(Callback *handler, PyObject *param1) {
  handler->callback(param1);
}

void call_callback_ref(Callback *handler, PyObject *param1) {
  handler->callback_ref(param1);
}

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
   SWIG_Py_INCREF in the directorin typemap. The upcall itself still fails as
   the null terminates the argument list early, so swallow the director error. */
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
