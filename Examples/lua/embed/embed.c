/* embed.c a simple test for an embedded interpreter

The idea is that we wrapper a few simple function (example.c)
and write our own app to call it.

What it will do is load the wrapped lib, load runme.lua and then call some functions.
To make life easier, all the printf's have either [C] or [Lua] at the start
so you can see where they are coming from.

*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

/* the SWIG wrapped library */
extern int luaopen_example(lua_State*L);

/* a really simple way of calling lua from C
 just give it a lua state & a string to execute
*/
int dostring(lua_State *L, char* str) {
  int ok = luaL_dostring(L,str);
  if (ok != LUA_OK)
    printf("[C] ERROR in dostring: %s\n",lua_tostring(L,-1));
  return ok;
}

int main(int argc,char* argv[]) {
  lua_State *L;
  int ok;
  printf("[C] Welcome to the simple embedded lua example\n");
  printf("[C] We are in C\n");
  printf("[C] opening a lua state & loading the libraries\n");
  L=luaL_newstate();
  luaopen_base(L);
  luaopen_string(L);
  luaopen_math(L);
  printf("[C] now loading the SWIG wrapped library\n");
  luaopen_example(L);
  printf("[C] all looks ok\n");
  printf("\n");
  if (argc != 2 || argv[1] == NULL || strlen(argv[1]) == 0) {
    printf("[C] ERROR: no lua file given on command line\n");
    exit(3);
  }
  printf("[C] let's load the file '%s'\n", argv[1]);
  printf("[C] any lua code in this file will be executed\n");
  if (luaL_loadfile(L, argv[1]) || lua_pcall(L, 0, 0, 0)) {
    printf("[C] ERROR: cannot run lua file: %s",lua_tostring(L, -1));
    exit(3);
  }
  printf("[C] We are now back in C, all looks ok\n");
  printf("\n");
  printf("[C] let's call the function 'do_tests()'\n");
  ok=dostring(L,"do_tests()");
  printf("[C] We are back in C, the dostring() function returned %d\n",ok);
  printf("\n");
  printf("[C] Let's call lua again, but create an error\n");
  ok=dostring(L,"no_such_function()");
  printf("[C] We are back in C, the dostring() function returned %d\n",ok);
  printf("[C] it should also have returned 1 and printed an error message\n");
  printf("\n");
  printf("[C] Let's call lua again, calling the greeting function\n");
  ok=dostring(L,"call_greeting()");
  printf("[C] This was C=>Lua=>C (getting a bit complex)\n");
  printf("\n");
  printf("[C] all finished, closing the lua state\n");
  lua_close(L);
  return 0;
}
