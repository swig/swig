/* -----------------------------------------------------------------------------
 * swigfragments.swg
 *
 * Common fragments
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * Fragments for C header files
 * ----------------------------------------------------------------------------- */

%fragment("<errno.h>", "header") %{
#include <errno.h>
%}

%fragment("<float.h>", "header") %{
#include <float.h>
%}

/* Default compiler options for gcc allow long_long but not LLONG_MAX. 
 * Define SWIG_NO_LLONG_MAX if this added limits support is not wanted. */
%fragment("<limits.h>", "header") %{
#include <limits.h>
#if !defined(SWIG_NO_LLONG_MAX)
# if !defined(LLONG_MAX) && defined(__GNUC__) && defined (__LONG_LONG_MAX__)
#   define LLONG_MAX __LONG_LONG_MAX__
#   define LLONG_MIN (-LLONG_MAX - 1LL)
#   define ULLONG_MAX (LLONG_MAX * 2ULL + 1ULL)
# endif
#endif
%}

%fragment("<math.h>", "header") %{
#include <math.h>
%}

%fragment("<string.h>", "header") %{
#include <string.h>
%}

%fragment("<stddef.h>", "header") %{
#include <stddef.h>
%}

%fragment("<stdio.h>", "header") %{
#include <stdio.h>
#if (defined(_MSC_VER) && (_MSC_VER < 1900)) || defined(__BORLANDC__) || defined(_WATCOM)
# ifndef snprintf
#  define snprintf _snprintf
# endif
#endif
%}

%fragment("<stdlib.h>", "header") %{
#include <stdlib.h>
#ifdef _MSC_VER
# ifndef strtoull
#  define strtoull _strtoui64
# endif
# ifndef strtoll
#  define strtoll _strtoi64
# endif
#endif
%}

%fragment("<wchar.h>", "header") %{
#include <wchar.h>
#include <limits.h>
#ifndef WCHAR_MIN
#  define WCHAR_MIN 0
#endif
#ifndef WCHAR_MAX
#  define WCHAR_MAX 65535
#endif
%}

/* -----------------------------------------------------------------------------
 * Fragments for C++ header files
 * ----------------------------------------------------------------------------- */

%fragment("<algorithm>", "header") %{
#include <algorithm>
%}

%fragment("<memory>", "header") %{
#include <memory>
%}

%fragment("<stdexcept>", "header") %{
#include <stdexcept>
%}

%fragment("<string>", "header") %{
#include <string>
%}

%fragment("<string_view>", "header") %{
#include <string_view>
%}

%fragment("<type_traits>", "header") %{
#include <type_traits>
%}

%fragment("<iostream>", "header") %{
#include <iostream>
%}

/* -----------------------------------------------------------------------------
 * Other common fragments
 * ----------------------------------------------------------------------------- */

%fragment("long_check_wordsize32", "header", fragment="<limits.h>") %{
#if !defined(SWIG_NO_WORDSIZE32_CHECK)
#if (__WORDSIZE == 64) || (LONG_MAX != INT_MAX)
# error "SWIG generated code is invalid on this 64-bit architecture, please regenerate without defining SWIGWORDSIZE32 or define SWIGWORDSIZE64"
#endif
#endif
%}

%fragment("long_check_wordsize64", "header", fragment="<limits.h>") %{
#if !defined(SWIG_NO_WORDSIZE64_CHECK)
#if (__WORDSIZE == 32) || (LONG_MAX == INT_MAX)
# error "SWIG generated code is invalid on this 32-bit architecture, please regenerate without defining SWIGWORDSIZE64 or define SWIGWORDSIZE32"
#endif
#endif
%}

#ifdef SWIGWORDSIZE64
%fragment("long_check_wordsize", "header", fragment="long_check_wordsize64") {}
#else
%fragment("long_check_wordsize", "header", fragment="long_check_wordsize32") {}
#endif

/* Copy the 'len' chars at 'str' into the char array 'buf' of 'size' elements and zero pad the rest of 'buf'. This is
 * strncpy, except that exactly 'len' chars are copied, so embedded NULs are kept. Returns 0, copying nothing, if 'str'
 * is too long. It fits if there is also room for a NUL terminator, except that a single char fills a char[1]. A NULL
 * 'buf' only checks that 'str' fits. Provides SWIG_CopyCharArray for char and SWIG_CopyWCharArray as the wchar_t version. */
%define %_copy_char_array_fragment(Char, CharName, CharHeader)
%fragment("SWIG_Copy" #CharName "Array", "header", fragment="<string.h>", fragment=CharHeader) {
SWIGINTERN int SWIG_Copy##CharName##Array(Char *buf, size_t size, const Char *str, size_t len) {
  if (len > size || (len == size && size != 1))
    return 0;
  if (buf) {
    if (len)
      memcpy(buf, str, len * sizeof(Char));
    memset(buf + len, 0, (size - len) * sizeof(Char));
  }
  return 1;
}
}
%enddef

%_copy_char_array_fragment(char, Char, "<stddef.h>")
%_copy_char_array_fragment(wchar_t, WChar, "<wchar.h>")

/* The length of the string in the char array 'buf' of 'size' elements, which has no NUL terminator when it is full. */
%fragment("SWIG_CharArrayLength", "header", fragment="<string.h>") {
SWIGINTERN size_t SWIG_CharArrayLength(const char *buf, size_t size) {
  const char *nul = (const char *)memchr(buf, 0, size);
  return nul ? (size_t)(nul - buf) : size;
}
}

/* The string in the char array 'buf' of 'size' elements as a NUL terminated string, for an API that needs one: 'buf'
 * itself, unless the array is full and so has no NUL terminator, when it is a copy. Release it with
 * SWIG_DeleteCharArrayString. */
%fragment("SWIG_CharArrayString", "header", fragment="<stdlib.h>", fragment="<string.h>") {
SWIGINTERN const char *SWIG_CharArrayString(const char *buf, size_t size) {
  char *str;
  if (!buf || memchr(buf, 0, size))
    return buf;
  str = (char *)malloc(size + 1);
  if (str) {
    memcpy(str, buf, size);
    str[size] = 0;
  }
  return str;
}

SWIGINTERN void SWIG_DeleteCharArrayString(const char *str, const char *buf) {
  if (str != buf)
    free((char *)str);
}
}

