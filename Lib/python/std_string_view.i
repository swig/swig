/* -----------------------------------------------------------------------------
 * std_string_view.i
 *
 * SWIG typemaps for std::string_view types
 * ----------------------------------------------------------------------------- */

%include <exception.i>

%{
#include <string_view>

#if PY_VERSION_HEX < 0x03000000
# error std_string_view.i not supported for Python 2
#endif
%}

namespace std {

    %naturalvar string_view;

    class string_view;

    %typemap(typecheck,precedence=SWIG_TYPECHECK_STRINGVIEW) string_view, const string_view & %{
#ifdef SWIG_PYTHON_STRICT_BYTE_CHAR
        $1 = PyBytes_Check($input);
#else
        $1 = PyUnicode_Check($input) || PyBytes_Check($input);
#endif
    %}

    %typemap(in) string_view (PyObject *bytes = NULL) {
        Py_ssize_t len;
%#ifdef SWIG_PYTHON_STRICT_BYTE_CHAR
        const char *p = PyBytes_AsString($input);
        if (!p) SWIG_fail;
        len = PyBytes_Size($input);
%#else
        const char *p;
        if (PyUnicode_Check($input)) {
          p = SWIG_PyUnicode_AsUTF8AndSize($input, &len, &bytes);
          if (!p) SWIG_fail;
        } else {
          p = PyBytes_AsString($input);
          if (!p) SWIG_fail;
          len = PyBytes_Size($input);
        }
%#endif
        $1 = std::string_view(p, len);
    }

    %typemap(freearg) string_view %{
        SWIG_Py_XDECREF(bytes$argnum);
    %}

    %typemap(in) const string_view & ($*1_ltype temp, PyObject *bytes = NULL) {
        Py_ssize_t len;
%#ifdef SWIG_PYTHON_STRICT_BYTE_CHAR
        const char *p = PyBytes_AsString($input);
        if (!p) SWIG_fail;
        len = PyBytes_Size($input);
%#else
        const char *p;
        if (PyUnicode_Check($input)) {
          p = SWIG_PyUnicode_AsUTF8AndSize($input, &len, &bytes);
          if (!p) SWIG_fail;
        } else {
          p = PyBytes_AsString($input);
          if (!p) SWIG_fail;
          len = PyBytes_Size($input);
        }
%#endif
        temp = std::string_view(p, len);
        $1 = &temp;
    }

    %typemap(freearg) const string_view & %{
        SWIG_Py_XDECREF(bytes$argnum);
    %}

    %typemap(directorout, warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) string_view {
        Py_ssize_t len;
%#ifdef SWIG_PYTHON_STRICT_BYTE_CHAR
        const char *p = PyBytes_AsString($input);
        if (p) len = PyBytes_Size($input);
%#else
        const char *p;
        PyObject *bytes = NULL;
        if (PyUnicode_Check($input)) {
          p = SWIG_PyUnicode_AsUTF8AndSize($input, &len, &bytes);
          // Avoid undefined behaviour (p will be pointing to a temporary
          // if bytes is not NULL which happens when Py_LIMITED_API is defined
          // and < 0x030A0000) and just leak by not calling Py_XDECREF.
          // Py_XDECREF(bytes);
        } else {
          p = PyBytes_AsString($input);
          if (p) len = PyBytes_Size($input);
        }
%#endif
        if (p) $result = std::string_view(p, len);
    }


    %typemap(out) string_view %{
#ifdef SWIG_PYTHON_STRICT_BYTE_CHAR
        $result = PyBytes_FromStringAndSize($1.data(), $1.size());
#else
        $result = PyUnicode_FromStringAndSize($1.data(), $1.size());
#endif
    %}

    %typemap(varout) string_view %{
#ifdef SWIG_PYTHON_STRICT_BYTE_CHAR
        $result = PyBytes_FromStringAndSize($1.data(), $1.size());
#else
        $result = PyUnicode_FromStringAndSize($1.data(), $1.size());
#endif
    %}

    %typemap(directorin) string_view, const string_view & %{
#ifdef SWIG_PYTHON_STRICT_BYTE_CHAR
        $input = PyBytes_FromStringAndSize($1.data(), $1.size());
#else
        $input = PyUnicode_FromStringAndSize($1.data(), $1.size());
#endif
    %}

    %typemap(out) const string_view & %{
#ifdef SWIG_PYTHON_STRICT_BYTE_CHAR
        $result = PyBytes_FromStringAndSize($1->data(), $1->size());
#else
        $result = PyUnicode_FromStringAndSize($1->data(), $1->size());
#endif
    %}

}
