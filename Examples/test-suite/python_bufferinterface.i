%module python_bufferinterface

%feature("python:bf_getbuffer", functype="getbufferproc")
    Buffer "Buffer::getbuffer";
%feature("python:bf_releasebuffer", functype="releasebufferproc")
    Buffer "Buffer::releasebuffer";

%inline %{
#ifdef SWIGPYTHON_BUILTIN
  bool is_python_builtin() { return true; }
#else
  bool is_python_builtin() { return false; }
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
