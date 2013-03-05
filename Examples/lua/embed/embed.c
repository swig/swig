/* embed.c a simple test for an embeded interpreter
 
The idea is that we wrapper a few simple function (example.c)
and write our own app to call it.
 
What it will do is load the wrappered lib, load runme.lua and then call some functions.
To make life easier, all the printf's have either [C] or [Lua] at the start
so you can see where they are coming from.
 
We will be using the luaL_dostring()/lua_dostring() function to call into lua 
 
*/

#include <stdlib.h>
#include <stdio.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

/* the SWIG wrappered library */
extern int luaopen_example(lua_State*L);

/* a really simple way of calling lua from C
 just give it a lua state & a string to execute
Unfortunately lua keeps changing its API's.
In lua 5.0.X its lua_dostring()
In lua 5.1.X its luaL_dostring()
so we have a few extra compiles
*/
int dostring(lua_State *L, char* str) {
  int ok;
#if (defined(LUA_VERSION_NUM) && (LUA_VERSION_NUM>=501))

  ok=luaL_dostring(L,str);	/* looks like this is lua 5.1.X or later, good */
#else

  ok=lua_dostring(L,str);	/* might be lua 5.0.x, using lua_dostring */
#endif

  if (ok!=0)
    printf("[C] ERROR in dostring: %s\n",lua_tostring(L,-1));
  return ok;
}


int main(int argc,char* argv[]) {
  lua_State *L;
  int ok;
  printf("[C] Welcome to the simple embedded lua example\n");
  printf("[C] We are in C\n");
  printf("[C] opening a lua state & loading the libraries\n");
  L=lua_open();
  luaopen_base(L);
  luaopen_string(L);
  luaopen_math(L);
  printf("[C] now loading the SWIG wrappered library\n");
  luaopen_example(L);
  printf("[C] all looks ok\n");
  printf("\n");
  printf("[C] lets load the file 'runme.lua'\n");
  printf("[C] any lua code in this file will be executed\n");
  if (luaL_loadfile(L, "runme.lua") || lua_pcall(L, 0, 0, 0)) {
    printf("[C] ERROR: cannot run lua file: %s",lua_tostring(L, -1));
    exit(3);
  }
  printf("[C] We are now back in C, all looks ok\n");
  printf("\n");
  printf("[C] lets call the function 'do_tests()'\n");
  ok=dostring(L,"do_tests()");
  printf("[C] We are back in C, the dostring() function returned %d\n",ok);
  printf("\n");
  printf("[C] Lets call lua again, but create an error\n");
  ok=dostring(L,"no_such_function()");
  printf("[C] We are back in C, the dostring() function returned %d\n",ok);
  printf("[C] it should also have returned 1 and printed an error message\n");
  printf("\n");
  printf("[C] Lets call lua again, calling the greeting function\n");
  ok=dostring(L,"call_greeting()");
  printf("[C] This was C=>Lua=>C (getting a bit complex)\n");
  printf("\n");
  printf("[C] all finished, closing the lua state\n");
  lua_close(L);
  return 0;
}
