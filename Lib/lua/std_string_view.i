/* -----------------------------------------------------------------------------
 * std_string_view.i
 *
 * std::string_view typemaps for LUA
 * ----------------------------------------------------------------------------- */

%{
#include <string_view>
%}

namespace std {

%naturalvar string_view;

%typemap(in,checkfn="lua_isstring") string_view
{
  size_t len;
  const char *ptr = lua_tolstring(L, $input, &len);
  $1 = std::string_view(ptr, len);
}

%typemap(out) string_view
%{ lua_pushlstring(L,$1.data(),$1.size()); SWIG_arg++;%}

%typemap(in,checkfn="lua_isstring") const string_view& ($*1_ltype temp)
{
  size_t len;
  const char *ptr = lua_tolstring(L, $input, &len);
  temp = std::string_view(ptr, len);
  $1=&temp;
}

%typemap(out) const string_view&
%{ lua_pushlstring(L,$1->data(),$1->size()); SWIG_arg++;%}

// for throwing of any kind of string_view, string_view ref's and string_view pointers
// we convert all to lua strings
%typemap(throws) string_view, string_view&, const string_view&
%{ lua_pushlstring(L,$1.data(),$1.size()); SWIG_fail;%}

%typemap(throws) string_view*, const string_view*
%{ lua_pushlstring(L,$1->data(),$1->size()); SWIG_fail;%}

%typecheck(SWIG_TYPECHECK_STRINGVIEW) string_view, const string_view& {
  $1 = lua_isstring(L,$input);
}

class string_view;

}
