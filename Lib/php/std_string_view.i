/* -----------------------------------------------------------------------------
 * std_string_view.i
 *
 * SWIG typemaps for std::string_view types
 * ----------------------------------------------------------------------------- */

%include <exception.i>

%{
#include <string_view>
%}

namespace std {

    %naturalvar string_view;

    class string_view;

    %typemap(typecheck,precedence=SWIG_TYPECHECK_STRINGVIEW) string_view, const string_view& %{
        $1 = (Z_TYPE($input) == IS_STRING) ? 1 : 0;
    %}

    %typemap(in, phptype="string") string_view %{
        convert_to_string(&$input);
        $1 = std::string_view(Z_STRVAL($input), Z_STRLEN($input));
    %}

    %typemap(in, phptype="string") const string_view& ($*1_ltype temp) %{
        convert_to_string(&$input);
        temp = std::string_view(Z_STRVAL($input), Z_STRLEN($input));
        $1 = &temp;
    %}

    %typemap(directorout, warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) string_view %{
        convert_to_string($input);
        $result = std::string_view(Z_STRVAL_P($input), Z_STRLEN_P($input));
    %}

    %typemap(out, phptype="string") string_view %{
        ZVAL_STRINGL($result, $1.data(), $1.size());
    %}

    %typemap(directorin) string_view, const string_view& %{
        ZVAL_STRINGL($input, $1.data(), $1.size());
    %}

    %typemap(out, phptype="string") const string_view& %{
        ZVAL_STRINGL($result, $1->data(), $1->size());
    %}

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

}
