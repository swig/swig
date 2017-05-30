%{
#ifdef __cplusplus
extern "C" {
#endif

#ifdef HAVE_RUBY_ENCODING_H
#include "ruby/encoding.h"
#endif

/**
 *  The internal encoding of std::wstring is defined based on
 *  the size of wchar_t. If it is not appropriate for your library,
 *  SWIG_RUBY_WSTRING_ENCODING must be given when compiling.
 */
#ifndef SWIG_RUBY_WSTRING_ENCODING

#if WCHAR_MAX == 0x7fff || WCHAR_MAX == 0xffff
#define SWIG_RUBY_WSTRING_ENCODING "UTF-16"
#elif WCHAR_MAX == 0x7fffffff || WCHAR_MAX == 0xffffffff
#define SWIG_RUBY_WSTRING_ENCODING "UTF-32"
#else
#error unsupported wchar_t size. SWIG_RUBY_WSTRING_ENCODING must be given.
#endif

#endif

/**
 *  If Encoding.default_internal is nil, this encoding will be used
 *  when coverting from std::wstring to String object in Ruby.
 */
#ifndef SWIG_RUBY_INTERNAL_ENCODING
#define SWIG_RUBY_INTERNAL_ENCODING "UTF-8"
#endif

#ifdef __cplusplus
}
#endif
%}

%include <rubywstrings.swg>
%include <typemaps/std_wstring.swg>

