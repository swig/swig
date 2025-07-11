%module python_bufferinterface

%begin %{
#if defined(Py_LIMITED_API) && Py_LIMITED_API+0 < 0x030b0000
#undef Py_LIMITED_API // Py_buffer is not defined in Py_LIMITED_API < 3.11
#endif
%}

%feature("python:bf_getbuffer", functype="getbufferproc")
    Buffer "Buffer::getbuffer";
%feature("python:bf_releasebuffer", functype="releasebufferproc")
    Buffer "Buffer::releasebuffer";

%inline %{
#ifndef SWIGPYTHON_BUILTIN
  bool should_work() { return false; }
#else
#ifndef Py_LIMITED_API
  bool should_work() { return true; }
#else
#if Py_LIMITED_API+0 >= 0x030b0000
  bool should_work() { return true; }
#else
  bool should_work() { return false; }
#endif
#endif
#endif

  static char data[1024];

  class Buffer {
  public:
    static int getbuffer(PyObject *exporter, Py_buffer *view, int flags) {
#if defined(Py_LIMITED_API) && Py_LIMITED_API+0 < 0x030b0000
      PyErr_SetNone(PyExc_BufferError);
      view->obj = NULL;
      return -1;
#else
      return PyBuffer_FillInfo(view, exporter, &data, sizeof(data), 1, flags);
#endif
    };
    static void releasebuffer(PyObject *exporter, Py_buffer *view) {
    };
  };
%}
