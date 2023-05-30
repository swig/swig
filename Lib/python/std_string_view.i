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

    %typemap(typecheck,precedence=SWIG_TYPECHECK_STRINGVIEW) string_view, const string_view& %{
#ifdef SWIG_PYTHON_STRICT_BYTE_CHAR
        $1 = PyBytes_Check($input);
#else
        $1 = PyUnicode_Check($input) || PyBytes_Check($input);
#endif
    %}

    %typemap(in) string_view {
        Py_ssize_t len;
%#ifdef SWIG_PYTHON_STRICT_BYTE_CHAR
        const char *p = PyBytes_AsString($input);
        if (!p) SWIG_fail;
        len = PyBytes_Size($input);
%#else
        /* Note: The UTF-8 data is cached in the PyObject so remains valid for
         * the call to C/C++. */
        const char *p = PyUnicode_AsUTF8AndSize($input, &len);
        if (!p) {
          p = PyBytes_AsString($input);
          if (!p) SWIG_fail;
          len = PyBytes_Size($input);
        }
%#endif
        $1 = std::string_view(p, len);
    }

    %typemap(in) const string_view& ($*1_ltype temp) {
        Py_ssize_t len;
#ifdef SWIG_PYTHON_STRICT_BYTE_CHAR
        const char *p = PyBytes_AsString($input);
        if (!p) SWIG_fail;
        len = PyBytes_Size($input);
#else
        /* Note: The UTF-8 data is cached in the PyObject so remains valid for
         * the call to C/C++. */
        const char *p = PyUnicode_AsUTF8AndSize($input, &len);
        if (!p) {
          p = PyBytes_AsString($input);
          if (!p) SWIG_fail;
          len = PyBytes_Size($input);
        }
#endif
        temp = std::string_view(p, len);
        $1 = &temp;
    }

    %typemap(directorout) string_view {
        Py_ssize_t len;
%#ifdef SWIG_PYTHON_STRICT_BYTE_CHAR
        const char *p = PyBytes_AsString($input);
        if (p) len = PyBytes_Size($input);
%#else
        /* Note: The UTF-8 data is cached in the PyObject so remains valid for
         * the call to C/C++. */
        const char *p = PyUnicode_AsUTF8AndSize($input, &len);
        if (!p) {
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

    %typemap(directorin) string_view, const string_view& %{
#ifdef SWIG_PYTHON_STRICT_BYTE_CHAR
        $input = PyBytes_FromStringAndSize($1.data(), $1.size());
#else
        $input = PyUnicode_FromStringAndSize($1.data(), $1.size());
#endif
    %}

    %typemap(out) const string_view& %{
#ifdef SWIG_PYTHON_STRICT_BYTE_CHAR
        $result = PyBytes_FromStringAndSize($1->data(), $1->size());
#else
        $result = PyUnicode_FromStringAndSize($1->data(), $1->size());
#endif
    %}

#if 0
    %typemap(throws) string_view, const string_view& %{
        {
            zval swig_exception;
            ZVAL_STRINGL(&swig_exception, $1.data(), $1.size());
            zend_throw_exception_object(&swig_exception);
            goto fail;
        }
    %}

    %typemap(throws) string_view*, const string_view* %{
        {
            zval swig_exception;
            ZVAL_STRINGL(&swig_exception, $1->data(), $1->size());
            zend_throw_exception_object(&swig_exception);
            goto fail;
        }
    %}

    %typemap(in, phptype="string") const string_view& ($*1_ltype temp) %{
        convert_to_string(&$input);
        temp = std::string_view(Z_STRVAL($input), Z_STRLEN($input));
        $1 = &temp;
    %}
#endif

}
