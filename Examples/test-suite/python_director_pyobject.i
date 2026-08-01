// Tests that a PyObject * director method argument does not have its reference
// count decremented on each director upcall. The wrapper variable holding the
// argument DECREFs on scope exit, so the borrowed argument must be INCREFed.

%module(directors="1") python_director_pyobject

%feature("director") Callback;

%inline %{
struct Callback {
  virtual void callback(PyObject *param1) = 0;
  virtual void callback_ptr(swig::SwigPtr_PyObject param1) = 0;
  virtual void callback_var(swig::SwigVar_PyObject param1) = 0;
  virtual ~Callback() {}
};

void call_callback(Callback *handler, PyObject *param1) {
  handler->callback(param1);
}

void call_callback_ptr(Callback *handler, PyObject *param1) {
  handler->callback_ptr(param1);
}

void call_callback_var(Callback *handler, PyObject *param1) {
  handler->callback_var(param1);
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
