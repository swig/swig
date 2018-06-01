/* -------------------------------------------------------------------------
 * std_string.i
 *
 * This header file simply applies native Fortran character string wrapping to
 * the std::string class. Strings are returned as
 *   character(kind=C_CHAR, len=:), allocatable
 * and input as
 *   character(kind=C_CHAR, len=*)
 *
 * ------------------------------------------------------------------------- */

%include <forstring.swg>
%{
#include <string>
%}

%apply const std::string &NATIVE { const std::string & };
%apply std::string NATIVE        { std::string };
%apply std::string *NATIVE { std::string * };

