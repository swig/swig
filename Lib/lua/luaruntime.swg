/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * luaruntime.swg
 *
 * all the runtime code for .
 * ----------------------------------------------------------------------------- */

%runtime "swigrun.swg";         /* Common C API type-checking code */
%runtime "luarun.swg";          /* Lua runtime stuff */

%insert(initbeforefunc) "swiginit.swg"

%insert(initbeforefunc) %{

/* Forward declaration of where the user's %init{} gets inserted */
#ifdef __cplusplus
extern "C" {
#endif
void SWIG_init_user(lua_State* L );

/* this is the initialization function
	added at the very end of the code
	the function is always called SWIG_init, but an eariler #define will rename it
*/
SWIGEXPORT int SWIG_init(lua_State* L)
{
	int i;

	/* start with global table */
	lua_pushvalue(L,LUA_GLOBALSINDEX);

	SWIG_InitializeModule((void*)L);
	SWIG_PropagateClientData();

	/* invoke user-specific initialization */
	SWIG_init_user(L);

	/* add a global fn */
	SWIG_Lua_add_function(L,"swig_type",SWIG_Lua_type);
	SWIG_Lua_add_function(L,"swig_equals",SWIG_Lua_equal);

	/* begin the module (its a table with the same name as the module) */
	SWIG_Lua_module_begin(L,SWIG_name);
	/* add commands/functions */
	for (i = 0; swig_commands[i].name; i++){
		SWIG_Lua_module_add_function(L,swig_commands[i].name,swig_commands[i].func);
	}
	/*luaL_openlib(L,NULL,swig_commands,0);*/
	/* all in one */
	/*luaL_openlib(L,SWIG_name,swig_commands,0);*/
	/* add variables */
	for (i = 0; swig_variables[i].name; i++){
		SWIG_Lua_module_add_variable(L,swig_variables[i].name,swig_variables[i].get,swig_variables[i].set);
	}

	/* additional registration structs & classes in lua: */
	for (i = 0; swig_types[i]; i++){
		if (swig_types[i]->clientdata){
			SWIG_Lua_class_register(L,(swig_lua_class*)(swig_types[i]->clientdata));
		}
	}

	/* constants */
	SWIG_Lua_InstallConstants(L,swig_constants);

	/* end module */
	/*SWIG_Lua_module_end(L);*/
	lua_pop(L,1);  /* tidy stack (remove module table)*/
	lua_pop(L,1);  /* tidy stack (remove global table)*/

	return 1;
}

/* Lua 5.1 has a different name for importing libraries
luaopen_XXX, where XXX is the name of the module (not capitalised)
this function will allow Lua 5.1 to import correctly.
There is a #define in the wrapper to rename 'SWIG_import' to the correct name
*/

SWIGEXPORT int SWIG_import(lua_State* L)
{
	return SWIG_init(L);
}

#ifdef __cplusplus
}
#endif

%}

/* Note: the initialization function is closed after all code is generated */

