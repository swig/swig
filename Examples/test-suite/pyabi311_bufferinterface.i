%module pyabi311_bufferinterface

%begin %{
#if defined(Py_LIMITED_API) && Py_LIMITED_API+0 < 0x030b0000
// Examples/tests-suite/python/Makefile should only run this test with Py_LIMITED_API >= 3.11
#error testcase misconfiguration - Py_buffer is not defined in Py_LIMITED_API < 3.11
#endif
%}

#ifdef SWIGPYTHON_BUILTIN
%feature("python:bf_getbuffer", functype="getbufferproc") ReadOnlyData "ReadOnlyData::getbuffer";
%feature("python:bf_releasebuffer", functype="releasebufferproc") ReadOnlyData "ReadOnlyData::releasebuffer";

%feature("python:bf_getbuffer", functype="getbufferproc") ReadWriteData "ReadWriteData::getbuffer";
%feature("python:bf_releasebuffer", functype="releasebufferproc") ReadWriteData "ReadWriteData::releasebuffer";
#endif

/* swig Python objects can only "expose" a Python buffer if the following
 * conditions are met:
 * 1/ SWIGPYTHON_BUILTIN is set
 * and
 * 2a/ Py_LIMITED_API is not set
 * or
 * 2b/ Py_LIMITED_API is 3.11 or greater
 * 
 * or
 * 
 * 1/ SWIGPYTHON_BUILTIN is not set
 * and
 * 2/ Python version is 3.12 or higher
 */
%inline %{
#ifdef SWIGPYTHON_BUILTIN
  #ifdef Py_LIMITED_API
    #if Py_LIMITED_API+0 >= 0x030b0000
      bool buffers_supported() { return true; }
    #else
      bool buffers_supported() { return false; }
    #endif
  #else // Py_LIMITED_API
    bool buffers_supported() { return true; }
  #endif // Py_LIMITED_API
#else // SWIGPYTHON_BUILTIN
  #if PY_VERSION_HEX >= 0x030c0000
    bool buffers_supported() { return true; }
  #else
    bool buffers_supported() { return false; }
  #endif
#endif // SWIGPYTHON_BUILTIN
%}

%inline %{
  class BaseClassData {
  private:
    char data[1024];
  public:
    bool released; // public so runme.py can use it as a diagnostic
    BaseClassData() {
      released = true;
      strcpy(data, "This string represents a large block of memory.");
    };
#ifdef SWIGPYTHON_BUILTIN
    static int getbuffer(PyObject *exporter, Py_buffer *view, int flags, bool readonly) {
#if defined(Py_LIMITED_API) && Py_LIMITED_API+0 < 0x030b0000
      goto fail;
#endif
      BaseClassData *self = 0;
      if (!SWIG_IsOK(SWIG_ConvertPtr(exporter, (void**)&self, SWIGTYPE_p_BaseClassData, 0)))
        goto fail;
      self->released = false;
      return PyBuffer_FillInfo(view, exporter, &self->data, sizeof(self->data), readonly ? 1 : 0, flags);
fail:
      PyErr_SetNone(PyExc_BufferError);
      view->obj = NULL;
      return -1;
    };
    static void releasebuffer(PyObject *exporter, Py_buffer *view) {
      BaseClassData *self = 0;
      if (!SWIG_IsOK(SWIG_ConvertPtr(exporter, (void**)&self, SWIGTYPE_p_BaseClassData, 0)))
        return;
      self->released = true;
    };
#else
    PyObject* __buffer__(int flags, bool readonly) {
      Py_buffer view;
      if (PyBuffer_FillInfo(&view, NULL, data, sizeof(data), readonly ? 1 : 0, flags)) {
        PyErr_SetNone(PyExc_BufferError);
        return NULL;
      }
      released = false;
      return PyMemoryView_FromBuffer(&view);
    };
    void __release_buffer__(PyObject* buffer) {
      released = true;
    };
#endif
  };

  class ReadOnlyData: public BaseClassData {
  public:
#ifdef SWIGPYTHON_BUILTIN
    static int getbuffer(PyObject *exporter, Py_buffer *view, int flags) {
      return BaseClassData::getbuffer(exporter, view, flags, true);
    };
#else
    PyObject* __buffer__(int flags) {
      return BaseClassData::__buffer__(flags, true);
    };
#endif
  };

  class ReadWriteData: public BaseClassData {
  public:
#ifdef SWIGPYTHON_BUILTIN
    static int getbuffer(PyObject *exporter, Py_buffer *view, int flags) {
      return BaseClassData::getbuffer(exporter, view, flags, false);
    };
#else
    PyObject* __buffer__(int flags) {
      return BaseClassData::__buffer__(flags, false);
    };
#endif
  };
%}
