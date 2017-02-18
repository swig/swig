%{
#ifdef __cplusplus
extern "C" {
#endif

#ifdef HAVE_RUBY_ENCODING_H
#include "ruby/encoding.h"
#endif

#ifdef __cplusplus
}
#endif
%}

%include <rubywstrings.swg>
%include <typemaps/std_wstring.swg>

