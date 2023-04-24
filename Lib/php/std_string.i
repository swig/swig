/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * SWIG typemaps for std::string types
 * ----------------------------------------------------------------------------- */

%{
#include <string>
%}

/* std::string and const std::string& are converted to/from PHP string
 * automatically.
 *
 * A C++ std::string& parameter is wrapped as a pass-by-reference PHP
 * string parameter by default, but the INPUT/INOUT/OUTPUT typemaps
 * below provide other options (see below).
 *
 * std::string* is not wrapped by default, but INPUT/INOUT/OUTPUT typemaps
 * are provided (see below).
 */

namespace std {

    %naturalvar string;

    class string;

    %typemap(typecheck,precedence=SWIG_TYPECHECK_STRING) string, const string& %{
        $1 = (Z_TYPE($input) == IS_STRING) ? 1 : 0;
    %}

    %typemap(in, phptype="string") string %{
        convert_to_string(&$input);
        $1.assign(Z_STRVAL($input), Z_STRLEN($input));
    %}

    %typemap(directorout) string %{
        convert_to_string($input);
        $result.assign(Z_STRVAL_P($input), Z_STRLEN_P($input));
    %}

    %typemap(out, phptype="string") string %{
        ZVAL_STRINGL($result, $1.data(), $1.size());
    %}

    %typemap(directorin) string, const string& %{
        ZVAL_STRINGL($input, $1.data(), $1.size());
    %}

    %typemap(out, phptype="string") const string& %{
        ZVAL_STRINGL($result, $1->data(), $1->size());
    %}

    %typemap(throws) string, const string& %{
        zend_throw_exception(NULL, $1.c_str(), 0);
        goto fail;
    %}

    %typemap(throws) string*, const string* %{
        zend_throw_exception(NULL, $1->c_str(), 0);
        goto fail;
    %}

    %typemap(in, phptype="string") const string& ($*1_ltype temp) %{
        convert_to_string(&$input);
        temp.assign(Z_STRVAL($input), Z_STRLEN($input));
        $1 = &temp;
    %}

    /*************************************************************************/

    /* These next four typemaps handle a function which takes a non-const
     * reference to a std::string and modifies the string. */
    %typemap(in,byref=1, phptype="string") string& ($*1_ltype temp) %{
        {
          zval * p = Z_ISREF($input) ? Z_REFVAL($input) : &$input;
          convert_to_string(p);
          temp.assign(Z_STRVAL_P(p), Z_STRLEN_P(p));
          $1 = &temp;
        }
    %}

    %typemap(directorout) string& ($*1_ltype *temp) %{
        convert_to_string($input);
        temp = new $*1_ltype(Z_STRVAL_P($input), Z_STRLEN_P($input));
        swig_acquire_ownership(temp);
        $result = temp;
    %}

    %typemap(argout) string& %{
      if (Z_ISREF($input)) {
        ZVAL_STRINGL(Z_REFVAL($input), $1->data(), $1->size());
      }
    %}

    /* SWIG will apply the non-const typemap above to const string& without
     * this more specific typemap. */
    %typemap(argout) const string& ""

    /*************************************************************************/

    /* Alternative ways to handle string& - you can specify how to wrap based
     * on the parameter name, e.g. this handles parameters named `str` as
     * INOUT:
     *
     * %apply (std::string& INOUT) (std::string& str);
     */

    %typemap(in) string& INPUT = const string&;
    %typemap(in, numinputs=0) string& OUTPUT ($*1_ltype temp)
    %{ $1 = &temp; %}
    %typemap(argout,fragment="t_output_helper") string& OUTPUT
    {
      zval o;
      ZVAL_STRINGL(&o, $1->data(), $1->size());
      t_output_helper($result, &o);
    }
    %typemap(in) string& INOUT = const string&;
    %typemap(argout) string& INOUT = string& OUTPUT;

}
