%module python_bufferinterface

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
      return PyBuffer_FillInfo(view, exporter, &data, sizeof(data), 1, flags);
    };
    static void releasebuffer(PyObject *exporter, Py_buffer *view) {
    };
  };
%}
