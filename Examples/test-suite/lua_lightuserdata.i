%module lua_lightuserdata

%native(get_lightuserdata) int get_lightuserdata(lua_State* L);
%{
int get_lightuserdata(lua_State* L)
{
  lua_pushlightuserdata(L, reinterpret_cast<void*>(0x123456));
  return 1;
}
%}

%inline %{
bool check_lighuserdata(const void* d) {
  return reinterpret_cast<void*>(0x123456) == d;
}
%}
