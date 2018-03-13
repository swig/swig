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

FORT_COPY_TYPEMAPS_AND_DECL(const std::string &NATIVE, const std::string &);
FORT_COPY_TYPEMAPS_AND_DECL(std::string NATIVE, std::string);

/* vim: set ts=2 sw=2 sts=2 tw=129 : */
