%module typemap_namespace

/* Secret typedefs */
%{
namespace Foo {
   typedef char    Str1;
   typedef char    Str2;
}
%}

namespace Foo {
    struct Str1;
    struct Str2;

    %typemap(in) Str1 * = char *;
    %apply char * { Str2 * };
}

%inline %{
namespace Foo {
    char *test1(Str1 *s) {
          return s;
    }
    char *test2(Str2 *s) {
          return s;
    }
}
%}

    

