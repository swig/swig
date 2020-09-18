%module lua_lightuserdata

%native(get_lightuserdata) int get_lightuserdata(lua_State* L);
%{
static int foo;
int get_lightuserdata(lua_State* L)
{
  lua_pushlightuserdata(L, &foo);
  return 1;
}
%}

%inline %{
bool check_lighuserdata(const void* d) {
  return d == &foo;
}
%}
