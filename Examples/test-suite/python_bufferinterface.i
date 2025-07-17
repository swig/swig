%module python_bufferinterface

%begin %{
#if defined(Py_LIMITED_API) && Py_LIMITED_API+0 < 0x030b0000
#undef Py_LIMITED_API // Py_buffer is not defined in Py_LIMITED_API < 3.11
#endif
%}

%feature("python:bf_getbuffer", functype="getbufferproc") ReadOnlyData "ReadOnlyData::getbuffer";
%feature("python:bf_releasebuffer", functype="releasebufferproc") ReadOnlyData "ReadOnlyData::releasebuffer";

%feature("python:bf_getbuffer", functype="getbufferproc") ReadWriteData "ReadWriteData::getbuffer";
%feature("python:bf_releasebuffer", functype="releasebufferproc") ReadWriteData "ReadWriteData::releasebuffer";

/* swig Python objects can only "expose" a Python buffer if the following
 * conditions are met:
 * 1/ SWIGPYTHON_BUILTIN is set
 * and
 * 2a/ Py_LIMITED_API is not set
 * or
 * 2b/ Py_LIMITED_API is 3.11 or greater
 */
%inline %{
#ifndef SWIGPYTHON_BUILTIN
  bool buffers_supported() { return false; }
#else
#ifndef Py_LIMITED_API
  bool buffers_supported() { return true; }
#else
#if Py_LIMITED_API+0 >= 0x030b0000
  bool buffers_supported() { return true; }
#else
  bool buffers_supported() { return false; }
#endif
#endif
#endif
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
    static int getbuffer(PyObject *exporter, Py_buffer *view, int flags,
                         bool readonly) {
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
  };

  class ReadOnlyData: public BaseClassData {
  public:
    static int getbuffer(PyObject *exporter, Py_buffer *view, int flags) {
      return BaseClassData::getbuffer(exporter, view, flags, true);
    };
  };

  class ReadWriteData: public BaseClassData {
  public:
    static int getbuffer(PyObject *exporter, Py_buffer *view, int flags) {
      return BaseClassData::getbuffer(exporter, view, flags, false);
    };
  };
%}
