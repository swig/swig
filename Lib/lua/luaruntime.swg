/* -----------------------------------------------------------------------------
 * luaruntime.swg
 *
 * all the runtime code for .
 * ----------------------------------------------------------------------------- */

%runtime "swigrun.swg"          /* Common C API type-checking code */
%runtime "swigerrors.swg"       /* SWIG errors */
%runtime "luarun.swg"           /* Lua runtime stuff */

%insert(initbeforefunc) "swiginit.swg"

%insert(initbeforefunc) %{

/* Forward declaration of where the user's %init{} gets inserted */
void SWIG_init_user(lua_State* L );

#ifdef __cplusplus
extern "C" {
#endif
/* this is the initialization function
  added at the very end of the code
  the function is always called SWIG_init, but an earlier #define will rename it
*/
SWIGEXPORT int SWIG_init(lua_State* L) /* default Lua action */
{
  int i;
  int globalRegister = 0;
  /* start with global table */
  lua_pushglobaltable (L);
  /* SWIG's internal initialisation */
  SWIG_InitializeModule((void*)L);
  SWIG_PropagateClientData();

  /* add a global fn */
  SWIG_Lua_add_function(L,"swig_type",SWIG_Lua_type);
  SWIG_Lua_add_function(L,"swig_equals",SWIG_Lua_class_equal);
#ifdef SWIG_DIRECTORS
  /* add director helper functions */
  SWIG_Lua_add_function(L,"swig_override",SWIG_Lua_director_override);
  SWIG_Lua_add_function(L,"swig_get_override",SWIG_Lua_director_get_override);
  SWIG_Lua_add_function(L,"swig_derive",SWIG_Lua_director_derive);
#endif

  /* set up base class pointers (the hierarchy) */
  for (i = 0; swig_types[i]; i++){
    if (swig_types[i]->clientdata){
      SWIG_Lua_init_base_class(L,(swig_lua_class*)(swig_types[i]->clientdata));
    }
  }
#ifdef SWIG_LUA_MODULE_GLOBAL
  globalRegister = 1;
#endif

  SWIG_Lua_namespace_register(L,&swig_SwigModule, globalRegister);

  /* invoke user-specific initialization */
  SWIG_init_user(L);
  /* end module */
  /* Note: We do not clean up the stack here (Lua will do this for us). At this
     point, we have the globals table and out module table on the stack. Returning
     one value makes the module table the result of the require command. */
  return 1;
}

#ifdef __cplusplus
}
#endif

%}

/* Note: the initialization function is closed after all code is generated */

