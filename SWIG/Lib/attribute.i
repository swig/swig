/* we use a simple exception warning here */
%{
#include <stdio.h>
%}
#define %attribute_exception(code,msg) printf("%s\n",msg)

#ifndef %arg
#define %arg(x) x
#endif

#ifndef %mange
#define %mangle(Type...)  #@Type
#endif

%include <typemaps/attribute.swg>
