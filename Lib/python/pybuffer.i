/* Implementing buffer protocol typemaps */

/* %pybuffer_mutable_binary(TYPEMAP, SIZE)
 *
 * Macro for functions accept mutable buffer pointer with a size.
 * This can be used for both input and output. For example:
 * 
 *      %pybuffer_mutable_binary(char *buff, int size);
 *      void foo(char *buff, int size) {
 *        for(int i=0; i<size; ++i)
 *          buff[i]++;  
 *      }
 */

/* Note that in Py_LIMITED_API case we have no choice, but to use deprecated
 * functions, as they provides the only way to access buffer data with limited
 * API, which doesn't include Py_buffer definition. We also disable the
 * warnings about doing this because they're not useful in our case.
 * Unfortunately this only works with python-3.12 and earlier,
 * but the new protocol is only in the stable abi from python-3.11.
 */

%fragment("SWIG_pybuffer", "header") %{
#if !defined(SWIG_NO_PYTHON_OLD_BUFFER_PROTOCOL)
#if defined(Py_LIMITED_API) && Py_LIMITED_API<0x030b0000
#define SWIG_PYTHON_OLD_BUFFER_PROTOCOL
#endif
#endif

#if defined(SWIG_PYTHON_OLD_BUFFER_PROTOCOL) && PY_VERSION_HEX >= 0x030d0000
#if defined(Py_LIMITED_API) && Py_LIMITED_API<0x030b0000
#error "The old Buffer Protocol was removed in python-3.13 and is only part of the stable ABI from python-3.11"
#endif
#endif
%}

%define %pybuffer_mutable_binary(TYPEMAP, SIZE)
%typemap(in, fragment="SWIG_pybuffer") (TYPEMAP, SIZE) {
  int res; Py_ssize_t size = 0; void *buf = 0;
%#if !defined(SWIG_PYTHON_OLD_BUFFER_PROTOCOL)
  Py_buffer view;
  res = PyObject_GetBuffer($input, &view, PyBUF_WRITABLE);
%#else
  %#if defined(__GNUC__) && (__GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 6))
    %#pragma GCC diagnostic push
    %#pragma GCC diagnostic ignored "-Wdeprecated"
    %#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
  %#elif defined(_MSC_VER)
    %#pragma warning(push)
    %#pragma warning(disable: 4996)
  %#endif
  res = PyObject_AsWriteBuffer($input, &buf, &size);
  %#if defined(__GNUC__) && (__GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 6))
    %#pragma GCC diagnostic pop
  %#elif defined(_MSC_VER)
    %#pragma warning(pop)
  %#endif
%#endif
  if (res < 0) {
    PyErr_Clear();
    %argument_fail(res, "(TYPEMAP, SIZE)", $symname, $argnum);
  }
%#if !defined(SWIG_PYTHON_OLD_BUFFER_PROTOCOL)
  size = view.len;
  buf = view.buf;
  PyBuffer_Release(&view);
%#endif
  $1 = ($1_ltype) buf;
  $2 = ($2_ltype) (size/sizeof($*1_type));
}
%enddef

/* %pybuffer_mutable_string(TYPEMAP)
 *
 * Macro for functions accept mutable zero terminated string pointer.
 * This can be used for both input and output. For example:
 * 
 *      %pybuffer_mutable_string(char *str);
 *      void foo(char *str) {
 *        while(*str) {
 *          *str = toupper(*str);
 *          str++;
 *      }
 */

%define %pybuffer_mutable_string(TYPEMAP)
%typemap(in, fragment="SWIG_pybuffer") (TYPEMAP) {
  int res; void *buf = 0;
%#if !defined(SWIG_PYTHON_OLD_BUFFER_PROTOCOL)
  Py_buffer view;
  res = PyObject_GetBuffer($input, &view, PyBUF_WRITABLE);
%#else
  %#if defined(__GNUC__) && (__GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 6))
    %#pragma GCC diagnostic push
    %#pragma GCC diagnostic ignored "-Wdeprecated"
    %#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
  %#elif defined(_MSC_VER)
    %#pragma warning(push)
    %#pragma warning(disable: 4996)
  %#endif
  Py_ssize_t size;
  res = PyObject_AsWriteBuffer($input, &buf, &size);
  %#if defined(__GNUC__) && (__GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 6))
    %#pragma GCC diagnostic pop
  %#elif defined(_MSC_VER)
    %#pragma warning(pop)
  %#endif
%#endif
  if (res < 0) {
    PyErr_Clear();
    %argument_fail(res, "(TYPEMAP)", $symname, $argnum);
  }
%#if !defined(SWIG_PYTHON_OLD_BUFFER_PROTOCOL)
  buf = view.buf;
  PyBuffer_Release(&view);
%#endif
  $1 = ($1_ltype) buf;
}
%enddef

/* pybuffer_binary(TYPEMAP, SIZE)
 *
 * Macro for functions accept read only buffer pointer with a size.
 * This must be used for input. For example:
 * 
 *      %pybuffer_binary(char *buff, int size);
 *      int foo(char *buff, int size) {
 *        int count = 0;
 *        for(int i=0; i<size; ++i)
 *          if (0==buff[i]) count++;
 *        return count;
 *      }
 */

%define %pybuffer_binary(TYPEMAP, SIZE)
%typemap(in, fragment="SWIG_pybuffer") (TYPEMAP, SIZE) {
  int res; Py_ssize_t size = 0; const void *buf = 0;
%#if !defined(SWIG_PYTHON_OLD_BUFFER_PROTOCOL)
  Py_buffer view;
  res = PyObject_GetBuffer($input, &view, PyBUF_CONTIG_RO);
%#else
  %#if defined(__GNUC__) && (__GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 6))
    %#pragma GCC diagnostic push
    %#pragma GCC diagnostic ignored "-Wdeprecated"
    %#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
  %#elif defined(_MSC_VER)
    %#pragma warning(push)
    %#pragma warning(disable: 4996)
  %#endif
  res = PyObject_AsReadBuffer($input, &buf, &size);
  %#if defined(__GNUC__) && (__GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 6))
    %#pragma GCC diagnostic pop
  %#elif defined(_MSC_VER)
    %#pragma warning(pop)
  %#endif
%#endif
  if (res < 0) {
    PyErr_Clear();
    %argument_fail(res, "(TYPEMAP, SIZE)", $symname, $argnum);
  }
%#if !defined(SWIG_PYTHON_OLD_BUFFER_PROTOCOL)
  size = view.len;
  buf = view.buf;
  PyBuffer_Release(&view);
%#endif
  $1 = ($1_ltype) buf;
  $2 = ($2_ltype) (size / sizeof($*1_type));
}
%enddef

/* %pybuffer_string(TYPEMAP)
 *
 * Macro for functions accept read only zero terminated string pointer.
 * This can be used for input. For example:
 * 
 *      %pybuffer_string(char *str);
 *      int foo(char *str) {
 *        int count = 0;
 *        while(*str) {
 *          if (isalnum(*str))
 *            count++;
 *          str++;
 *      }
 */

%define %pybuffer_string(TYPEMAP)
%typemap(in, fragment="SWIG_pybuffer") (TYPEMAP) {
  int res; const void *buf = 0;
%#if !defined(SWIG_PYTHON_OLD_BUFFER_PROTOCOL)
  Py_buffer view;
  res = PyObject_GetBuffer($input, &view, PyBUF_CONTIG_RO);
%#else
  %#if defined(__GNUC__) && (__GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 6))
    %#pragma GCC diagnostic push
    %#pragma GCC diagnostic ignored "-Wdeprecated"
    %#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
  %#elif defined(_MSC_VER)
    %#pragma warning(push)
    %#pragma warning(disable: 4996)
  %#endif
  Py_ssize_t size;
  res = PyObject_AsReadBuffer($input, &buf, &size);
  %#if defined(__GNUC__) && (__GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 6))
    %#pragma GCC diagnostic pop
  %#elif defined(_MSC_VER)
    %#pragma warning(pop)
  %#endif
%#endif
  if (res < 0) {
    PyErr_Clear();
    %argument_fail(res, "(TYPEMAP)", $symname, $argnum);
  }
%#if !defined(SWIG_PYTHON_OLD_BUFFER_PROTOCOL)
  buf = view.buf;
  PyBuffer_Release(&view);
%#endif
  $1 = ($1_ltype) buf;
}
%enddef
