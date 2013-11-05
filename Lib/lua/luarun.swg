/* -----------------------------------------------------------------------------
 * luarun.swg
 *
 * This file contains the runtime support for Lua modules
 * and includes code for managing global variables and pointer
 * type checking.
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#endif

#include "lua.h"
#include "lauxlib.h"
#include <stdlib.h>  /* for malloc */
#include <assert.h>  /* for a few sanity tests */

/* -----------------------------------------------------------------------------
 * Lua flavors
 * ----------------------------------------------------------------------------- */

#define SWIG_LUA_FLAVOR_LUA 1
#define SWIG_LUA_FLAVOR_ELUA 2
#define SWIG_LUA_FLAVOR_ELUAC 3

#if !defined(SWIG_LUA_TARGET)
# error SWIG_LUA_TARGET not defined
#endif

#if (SWIG_LUA_TARGET == SWIG_LUA_FLAVOR_ELUA) || (SWIG_LUA_TARGET == SWIG_LUA_FLAVOR_ELUAC)
#  define SWIG_LUA_CONSTTAB_INT(B, C) LSTRKEY(B), LNUMVAL(C)
#  define SWIG_LUA_CONSTTAB_FLOAT(B, C) LSTRKEY(B), LNUMVAL(C)
#  define SWIG_LUA_CONSTTAB_STRING(B, C) LSTRKEY(B), LSTRVAL(C)
#  define SWIG_LUA_CONSTTAB_CHAR(B, C) LSTRKEY(B), LNUMVAL(C)
#else /* SWIG_LUA_FLAVOR_LUA */
#  define SWIG_LUA_CONSTTAB_INT(B, C) SWIG_LUA_INT, (char *)B, (long)C, 0, 0, 0
#  define SWIG_LUA_CONSTTAB_FLOAT(B, C) SWIG_LUA_FLOAT, (char *)B, 0, (double)C, 0, 0
#  define SWIG_LUA_CONSTTAB_STRING(B, C) SWIG_LUA_STRING, (char *)B, 0, 0, (void *)C, 0
#  define SWIG_LUA_CONSTTAB_CHAR(B, C) SWIG_LUA_CHAR, (char *)B, (long)C, 0, 0, 0
#endif

#if (SWIG_LUA_TARGET == SWIG_LUA_FLAVOR_ELUA) || (SWIG_LUA_TARGET == SWIG_LUA_FLAVOR_ELUAC)
#  define LRO_STRVAL(v) {{.p = (char *) v}, LUA_TSTRING}
#  define LSTRVAL LRO_STRVAL
#endif

/* -----------------------------------------------------------------------------
 * compatibility defines
 * ----------------------------------------------------------------------------- */

/* History of Lua C API length functions:  In Lua 5.0 (and before?)
   there was "lua_strlen".  In Lua 5.1, this was renamed "lua_objlen",
   but a compatibility define of "lua_strlen" was added.  In Lua 5.2,
   this function was again renamed, to "lua_rawlen" (to emphasize that
   it doesn't call the "__len" metamethod), and the compatibility
   define of lua_strlen was removed.  All SWIG uses have been updated
   to "lua_rawlen", and we add our own defines of that here for older
   versions of Lua.  */
#if !defined(LUA_VERSION_NUM) || LUA_VERSION_NUM < 501
# define lua_rawlen lua_strlen
#elif LUA_VERSION_NUM == 501
# define lua_rawlen lua_objlen
#endif


/* lua_pushglobaltable is the recommended "future-proof" way to get
   the global table for Lua 5.2 and later.  Here we define
   lua_pushglobaltable ourselves for Lua versions before 5.2.  */
#if !defined(LUA_VERSION_NUM) || LUA_VERSION_NUM < 502
# define lua_pushglobaltable(L) lua_pushvalue(L, LUA_GLOBALSINDEX)
#endif


/* --------------------------------------------------------------------------
 * Helper functions for error handling
 * -------------------------------------------------------------------------- */

/* Push the string STR on the Lua stack, like lua_pushstring, but
   prefixed with the the location of the innermost Lua call-point
   (as formated by luaL_where).  */
SWIGRUNTIME void
SWIG_Lua_pusherrstring (lua_State *L, const char *str)
{
  luaL_where (L, 1);
  lua_pushstring (L, str);
  lua_concat (L, 2);
}

/* Push a formatted string generated from FMT and following args on
   the Lua stack, like lua_pushfstring, but prefixed with the the
   location of the innermost Lua call-point (as formated by luaL_where).  */
SWIGRUNTIME void
SWIG_Lua_pushferrstring (lua_State *L, const char *fmt, ...)
{
  va_list argp;
  va_start(argp, fmt);
  luaL_where(L, 1);
  lua_pushvfstring(L, fmt, argp);
  va_end(argp);
  lua_concat(L, 2);
}


/* -----------------------------------------------------------------------------
 * global swig types
 * ----------------------------------------------------------------------------- */
/* Constant table */
#define SWIG_LUA_INT     1
#define SWIG_LUA_FLOAT   2
#define SWIG_LUA_STRING  3
#define SWIG_LUA_POINTER 4
#define SWIG_LUA_BINARY  5
#define SWIG_LUA_CHAR    6

/* Structure for variable linking table */
typedef struct {
  const char *name;
  lua_CFunction get;
  lua_CFunction set;
} swig_lua_var_info;

/* Constant information structure */
typedef struct {
    int type;
    char *name;
    long lvalue;
    double dvalue;
    void   *pvalue;
    swig_type_info **ptype;
} swig_lua_const_info;

/* TODO:REMOVE
typedef struct {
  const char     *name;
  lua_CFunction   method;
} swig_lua_method;
*/
typedef luaL_Reg swig_lua_method;

typedef struct {
  const char     *name;
  lua_CFunction   getmethod;
  lua_CFunction   setmethod;
} swig_lua_attribute;


struct swig_lua_class;
// Can be used to create namespaces. Currently used to
// wrap class static methods/variables/constants
struct swig_lua_namespace {
  const char            *name;
  swig_lua_method       *ns_methods;
  swig_lua_attribute    *ns_attributes;
  swig_lua_const_info   *ns_constants;
  swig_lua_class        **ns_classes;
  swig_lua_namespace    **ns_namespaces;
};

struct swig_lua_class {
  const char    *name; // Name that this class has in Lua
  const char    *fqname; // Fully qualified name - Scope + class name
  swig_type_info   **type;
  lua_CFunction  constructor;
  void    (*destructor)(void *);
  swig_lua_method   *methods;
  swig_lua_attribute     *attributes;
  swig_lua_namespace    cls_static;
  struct swig_lua_class **bases;
  const char **base_names;
};

/* this is the struct for wrapping all pointers in SwigLua
*/
typedef struct {
  swig_type_info   *type;
  int     own;  /* 1 if owned & must be destroyed */
  void        *ptr;
} swig_lua_userdata;

/* this is the struct for wrapping arbitrary packed binary data
(currently it is only used for member function pointers)
the data ordering is similar to swig_lua_userdata, but it is currently not possible
to tell the two structures apart within SWIG, other than by looking at the type
*/
typedef struct {
  swig_type_info   *type;
  int     own;  /* 1 if owned & must be destroyed */
  char data[1];       /* arbitary amount of data */    
} swig_lua_rawdata;

/* Common SWIG API */
#define SWIG_NewPointerObj(L, ptr, type, owner)       SWIG_Lua_NewPointerObj(L, (void *)ptr, type, owner)
#define SWIG_ConvertPtr(L,idx, ptr, type, flags)    SWIG_Lua_ConvertPtr(L,idx,ptr,type,flags)
#define SWIG_MustGetPtr(L,idx, type,flags, argnum,fnname)  SWIG_Lua_MustGetPtr(L,idx, type,flags, argnum,fnname)
/* for C++ member pointers, ie, member methods */
#define SWIG_ConvertMember(L, idx, ptr, sz, ty)       SWIG_Lua_ConvertPacked(L, idx, ptr, sz, ty)
#define SWIG_NewMemberObj(L, ptr, sz, type)      SWIG_Lua_NewPackedObj(L, ptr, sz, type)

/* Runtime API */
#define SWIG_GetModule(clientdata) SWIG_Lua_GetModule((lua_State*)(clientdata))
#define SWIG_SetModule(clientdata, pointer) SWIG_Lua_SetModule((lua_State*) (clientdata), pointer)
#define SWIG_MODULE_CLIENTDATA_TYPE lua_State*

/* Contract support */
#define SWIG_contract_assert(expr, msg)  \
  if (!(expr)) { SWIG_Lua_pusherrstring(L, (char *) msg); goto fail; } else


/* helper #defines */
#define SWIG_fail {goto fail;}
#define SWIG_fail_arg(func_name,argnum,type) \
  {SWIG_Lua_pushferrstring(L,"Error in %s (arg %d), expected '%s' got '%s'",\
  func_name,argnum,type,SWIG_Lua_typename(L,argnum));\
  goto fail;}
#define SWIG_fail_ptr(func_name,argnum,type) \
  SWIG_fail_arg(func_name,argnum,(type && type->str)?type->str:"void*")
#define SWIG_check_num_args(func_name,a,b) \
  if (lua_gettop(L)<a || lua_gettop(L)>b) \
  {SWIG_Lua_pushferrstring(L,"Error in %s expected %d..%d args, got %d",func_name,a,b,lua_gettop(L));\
  goto fail;}


#define SWIG_Lua_get_table(L,n) \
  (lua_pushstring(L, n), lua_rawget(L,-2))

#define SWIG_Lua_add_function(L,n,f) \
  (lua_pushstring(L, n), \
      lua_pushcfunction(L, f), \
      lua_rawset(L,-3))

/* special helper for allowing 'nil' for usertypes */
#define SWIG_isptrtype(L,I) (lua_isuserdata(L,I) || lua_isnil(L,I))

#ifdef __cplusplus
/* Special helper for member function pointers 
it gets the address, casts it, then dereferences it */
//#define SWIG_mem_fn_as_voidptr(a)  (*((char**)&(a)))
#endif

/* storing/access of swig_module_info */
SWIGRUNTIME swig_module_info *
SWIG_Lua_GetModule(lua_State* L) {
  swig_module_info *ret = 0;
  lua_pushstring(L,"swig_runtime_data_type_pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME);
  lua_rawget(L,LUA_REGISTRYINDEX);
  if (lua_islightuserdata(L,-1))
    ret=(swig_module_info*)lua_touserdata(L,-1);
  lua_pop(L,1);  /* tidy */
  return ret;
}

SWIGRUNTIME void
SWIG_Lua_SetModule(lua_State* L, swig_module_info *module) {
  /* add this all into the Lua registry: */
  lua_pushstring(L,"swig_runtime_data_type_pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME);
  lua_pushlightuserdata(L,(void*)module);
  lua_rawset(L,LUA_REGISTRYINDEX);
}

/* -----------------------------------------------------------------------------
 * global variable support code: modules
 * ----------------------------------------------------------------------------- */

/* this function is called when trying to set an immutable.
default action is to print an error.
This can removed with a compile flag SWIGLUA_IGNORE_SET_IMMUTABLE */
SWIGINTERN int SWIG_Lua_set_immutable(lua_State* L)
{
/*  there should be 1 param passed in: the new value */
#ifndef SWIGLUA_IGNORE_SET_IMMUTABLE
  lua_pop(L,1);  /* remove it */
  luaL_error(L,"This variable is immutable");
#endif
    return 0;   /* should not return anything */
}

/* the module.get method used for getting linked data */
SWIGINTERN int SWIG_Lua_module_get(lua_State* L)
{
/*  there should be 2 params passed in
  (1) table (not the meta table)
  (2) string name of the attribute
  printf("SWIG_Lua_module_get %p(%s) '%s'\n",
   lua_topointer(L,1),lua_typename(L,lua_type(L,1)),
   lua_tostring(L,2));
*/
  /* get the metatable */
#if ((SWIG_LUA_TARGET == SWIG_LUA_FLAVOR_ELUA) || (SWIG_LUA_TARGET == SWIG_LUA_FLAVOR_ELUAC))
  assert(lua_isrotable(L,1)); /* just in case */
#else
  assert(lua_istable(L,1)); /* default Lua action */
#endif
  lua_getmetatable(L,1);  /* get the metatable */
#if ((SWIG_LUA_TARGET == SWIG_LUA_FLAVOR_ELUA) || (SWIG_LUA_TARGET == SWIG_LUA_FLAVOR_ELUAC))
  assert(lua_isrotable(L,-1));  /* just in case */
#else
  assert(lua_istable(L,-1));
#endif
  SWIG_Lua_get_table(L,".get");  /* get the .get table */
  lua_remove(L,3);  /* remove metatable */
#if ((SWIG_LUA_TARGET == SWIG_LUA_FLAVOR_ELUA) || (SWIG_LUA_TARGET == SWIG_LUA_FLAVOR_ELUAC))
  if (lua_isrotable(L,-1))
#else
  if (lua_istable(L,-1))
#endif
  {
    /* look for the key in the .get table */
    lua_pushvalue(L,2);  /* key */
    lua_rawget(L,-2);
    lua_remove(L,3);  /* remove .get */
    if (lua_iscfunction(L,-1))
    {  /* found it so call the fn & return its value */
      lua_call(L,0,1);
      return 1;
    }
    lua_pop(L,1);  /* remove the top */
  }
  lua_pop(L,1);  /* remove the .get */
  lua_pushnil(L);  /* return a nil */
  return 1;
}

/* the module.set method used for setting linked data */
SWIGINTERN int SWIG_Lua_module_set(lua_State* L)
{
/*  there should be 3 params passed in
  (1) table (not the meta table)
  (2) string name of the attribute
  (3) any for the new value
*/
  /* get the metatable */
#if ((SWIG_LUA_TARGET == SWIG_LUA_FLAVOR_ELUA) || (SWIG_LUA_TARGET == SWIG_LUA_FLAVOR_ELUAC))
  assert(lua_isrotable(L,1));  /* just in case */
#else
  assert(lua_istable(L,1)); /* default Lua action */
#endif
  lua_getmetatable(L,1);  /* get the metatable */
#if ((SWIG_LUA_TARGET == SWIG_LUA_FLAVOR_ELUA) || (SWIG_LUA_TARGET == SWIG_LUA_FLAVOR_ELUAC))
  assert(lua_isrotable(L,-1));  /* just in case */
#else
  assert(lua_istable(L,-1));
#endif
  SWIG_Lua_get_table(L,".set");  /* get the .set table */
  lua_remove(L,4);  /* remove metatable */
#if ((SWIG_LUA_TARGET == SWIG_LUA_FLAVOR_ELUA) || (SWIG_LUA_TARGET == SWIG_LUA_FLAVOR_ELUAC))
  if (lua_isrotable(L,-1))
#else
  if (lua_istable(L,-1))
#endif
  {
    /* look for the key in the .set table */
    lua_pushvalue(L,2);  /* key */
    lua_rawget(L,-2);
    lua_remove(L,4);  /* remove .set */
    if (lua_iscfunction(L,-1))
    {  /* found it so call the fn & return its value */
      lua_pushvalue(L,3);  /* value */
      lua_call(L,1,0);
      return 0;
    }
#if (SWIG_LUA_TARGET == SWIG_LUA_FLAVOR_ELUA) 
    else {
      return 0; // Exits stoically if an invalid key is initialized.
    }
#endif
  }
  lua_settop(L,3);  /* reset back to start */
  /* we now have the table, key & new value, so just set directly */
  lua_rawset(L,1);  /* add direct */
  return 0;
}

#if ((SWIG_LUA_TARGET != SWIG_LUA_FLAVOR_ELUA) && (SWIG_LUA_TARGET != SWIG_LUA_FLAVOR_ELUAC))
/* registering a module in lua. Pushes the module table on the stack. */
SWIGINTERN void  SWIG_Lua_module_begin(lua_State* L,const char* name)
{
  assert(lua_istable(L,-1));  /* just in case */
  lua_pushstring(L,name);
  lua_newtable(L);   /* the table */
  /* add meta table */
  lua_newtable(L);    /* the meta table */
  SWIG_Lua_add_function(L,"__index",SWIG_Lua_module_get);
  SWIG_Lua_add_function(L,"__newindex",SWIG_Lua_module_set);
  lua_pushstring(L,".get");
  lua_newtable(L);    /* the .get table */
  lua_rawset(L,-3);  /* add .get into metatable */
  lua_pushstring(L,".set");
  lua_newtable(L);    /* the .set table */
  lua_rawset(L,-3);  /* add .set into metatable */
  lua_setmetatable(L,-2);  /* sets meta table in module */
#ifdef SWIG_LUA_MODULE_GLOBAL
  /* If requested, install the module directly into the global namespace. */
  lua_rawset(L,-3);        /* add module into parent */
  SWIG_Lua_get_table(L,name);   /* get the table back out */
#else
  /* Do not install the module table as global name. The stack top has
     the module table with the name below. We pop the top and replace
     the name with it. */
  lua_replace(L,-2);
#endif
}

/* ending the register */
SWIGINTERN void  SWIG_Lua_module_end(lua_State* L)
{
  lua_pop(L,1);       /* tidy stack (remove module) */
}

/* adding a linked variable to the module */
SWIGINTERN void SWIG_Lua_module_add_variable(lua_State* L,const char* name,lua_CFunction getFn,lua_CFunction setFn)
{
  assert(lua_istable(L,-1));  /* just in case */
  lua_getmetatable(L,-1);  /* get the metatable */
  assert(lua_istable(L,-1));  /* just in case */
  SWIG_Lua_get_table(L,".get"); /* find the .get table */
  assert(lua_istable(L,-1));  /* should be a table: */
  SWIG_Lua_add_function(L,name,getFn);
  lua_pop(L,1);       /* tidy stack (remove table) */
  if (setFn)  /* if there is a set fn */
  {
    SWIG_Lua_get_table(L,".set"); /* find the .set table */
    assert(lua_istable(L,-1));  /* should be a table: */
    SWIG_Lua_add_function(L,name,setFn);
    lua_pop(L,1);       /* tidy stack (remove table) */
  }
  lua_pop(L,1);       /* tidy stack (remove meta) */
}
#endif

/* adding a function module */
SWIGINTERN void  SWIG_Lua_module_add_function(lua_State* L,const char* name,lua_CFunction fn)
{
  SWIG_Lua_add_function(L,name,fn);
}

/* -----------------------------------------------------------------------------
 * global variable support code: namespaces
 * ----------------------------------------------------------------------------- */

SWIGINTERN int SWIG_Lua_namespace_get(lua_State* L)
{
/*  there should be 2 params passed in
  (1) table (not the meta table)
  (2) string name of the attribute
*/
  assert(lua_istable(L,-2));  /* just in case */
  lua_getmetatable(L,-2);
  assert(lua_istable(L,-1));
  SWIG_Lua_get_table(L,".get"); /* find the .get table */
  assert(lua_istable(L,-1));
  /* look for the key in the .get table */
  lua_pushvalue(L,2);  /* key */
  lua_rawget(L,-2);
  lua_remove(L,-2); /* stack tidy, remove .get table */
  if (lua_iscfunction(L,-1))
  {  /* found it so call the fn & return its value */
    lua_call(L,0,1);  /* 1 value in (userdata),1 out (result) */
    lua_remove(L,-2); /* stack tidy, remove metatable */
    return 1;
  }
  lua_pop(L,1);  /* remove whatever was there */
  /* ok, so try the .fn table */
  SWIG_Lua_get_table(L,".fn"); /* find the .get table */
  assert(lua_istable(L,-1));  /* just in case */
  lua_pushvalue(L,2);  /* key */
  lua_rawget(L,-2);  /* look for the fn */
  lua_remove(L,-2); /* stack tidy, remove .fn table */
  if (lua_isfunction(L,-1)) /* note: whether it's a C function or lua function */
  {  /* found it so return the fn & let lua call it */
    lua_remove(L,-2); /* stack tidy, remove metatable */
    return 1;
  }
  lua_pop(L,1);  /* remove whatever was there */
  return 0;
}

SWIGINTERN int SWIG_Lua_namespace_set(lua_State* L)
{
/*  there should be 3 params passed in
  (1) table (not the meta table)
  (2) string name of the attribute
  (3) any for the new value
*/

  assert(lua_istable(L,1));
  lua_getmetatable(L,1);    /* get the meta table */
  assert(lua_istable(L,-1));

  SWIG_Lua_get_table(L,".set"); /* find the .set table */
  if (lua_istable(L,-1))
  {
    /* look for the key in the .set table */
    lua_pushvalue(L,2);  /* key */
    lua_rawget(L,-2);
    if (lua_iscfunction(L,-1))
    {  /* found it so call the fn & return its value */
      lua_pushvalue(L,3);  /* value */
      lua_call(L,1,0);
      return 0;
    }
    lua_pop(L,1);  /* remove the value */
  }
  lua_pop(L,1);  /* remove the value .set table */
  return 0;
}

SWIGINTERN void SWIG_Lua_InstallConstants(lua_State* L, swig_lua_const_info constants[]); // forward declaration
SWIGINTERN void  SWIG_Lua_add_variable(lua_State* L,const char* name,lua_CFunction getFn,lua_CFunction setFn); // forward declaration
SWIGINTERN void  SWIG_Lua_class_register(lua_State* L,swig_lua_class* clss);

/* helper function - register namespace methods and attributes into namespace */
SWIGINTERN int SWIG_Lua_add_namespace_details(lua_State* L, swig_lua_namespace* ns)
{
  int i = 0;
  /* There must be namespace table (not metatable) at the top of the stack */
  assert(lua_istable(L,-1));
  SWIG_Lua_InstallConstants(L, ns->ns_constants);

  lua_getmetatable(L,-1);

  /* add fns */
  for(i=0;ns->ns_attributes[i].name;i++){
    SWIG_Lua_add_variable(L,ns->ns_attributes[i].name,ns->ns_attributes[i].getmethod,ns->ns_attributes[i].setmethod);
  }

  /* add methods to the metatable */
  SWIG_Lua_get_table(L,".fn"); /* find the .fn table */
  assert(lua_istable(L,-1));  /* just in case */
  for(i=0;ns->ns_methods[i].name;i++){
    SWIG_Lua_add_function(L,ns->ns_methods[i].name,ns->ns_methods[i].func);
  }
  lua_pop(L,1);

  /* clear stack - remove metatble */
  lua_pop(L,1);
  return 0;
}

/* Register all classes in the namespace
 */
SWIGINTERN void SWIG_Lua_add_namespace_classes(lua_State* L, swig_lua_namespace* ns)
{
  // There must be module/namespace table at the top of the stack
  assert(lua_istable(L,-1));

  swig_lua_class** classes = ns->ns_classes;

  if( classes != 0 ) {
    while(*classes != 0) {
      SWIG_Lua_class_register(L, *classes);
      classes++;
    }
  }
}

/* helper function. creates namespace table and add it to module table
   if 'reg' is true, then will register namespace table to parent one (must be on top of the stack
   when function is called)
   Function always returns newly registered table on top of the stack
*/
SWIGINTERN int SWIG_Lua_namespace_register(lua_State* L, swig_lua_namespace* ns, bool reg)
{
  int begin = lua_gettop(L);
  assert(lua_istable(L,-1)); /* just in case. This is supposed to be module table or parent namespace table */
  lua_checkstack(L,5);
  lua_newtable(L); /* namespace itself */
  lua_newtable(L); /* metatable for namespace */

  /* add a table called ".get" */
  lua_pushstring(L,".get");
  lua_newtable(L);
  lua_rawset(L,-3);
  /* add a table called ".set" */
  lua_pushstring(L,".set");
  lua_newtable(L);
  lua_rawset(L,-3);
  /* add a table called ".fn" */
  lua_pushstring(L,".fn");
  lua_newtable(L);
  lua_rawset(L,-3);

  /* add accessor fns for using the .get,.set&.fn */
  SWIG_Lua_add_function(L,"__index",SWIG_Lua_namespace_get);
  SWIG_Lua_add_function(L,"__newindex",SWIG_Lua_namespace_set);

  lua_setmetatable(L,-2); /* set metatable */

  // Register all functions, variables etc
  SWIG_Lua_add_namespace_details(L,ns);
  // Register classes
  SWIG_Lua_add_namespace_classes(L,ns);

  swig_lua_namespace** sub_namespace = ns->ns_namespaces;
  if( sub_namespace != 0) {
    while(*sub_namespace != 0) {
      SWIG_Lua_namespace_register(L, *sub_namespace, true);
      lua_pop(L,1); // removing sub-namespace table
      sub_namespace++;
    }
  }

  if (reg) {
    lua_pushstring(L,ns->name);
    lua_pushvalue(L,-2);
    lua_rawset(L,-4); /* add namespace to module table */
  }
  assert(lua_gettop(L) == begin+1);
}
/* -----------------------------------------------------------------------------
 * global variable support code: classes
 * ----------------------------------------------------------------------------- */

/* the class.get method, performs the lookup of class attributes
 * Method can be called from Lua directly and recursively from itself. Thats why
 * we can't use absolute stack positions
 */
SWIGINTERN int  SWIG_Lua_class_get(lua_State* L)
{
/*  there should be 2 params passed in
  (1) userdata (not the meta table)
  (2) string name of the attribute
*/
  int base = lua_gettop(L)-2;
  lua_checkstack(L,5);
  assert(lua_isuserdata(L,-2));  /* just in case */
  lua_getmetatable(L,-2);    /* get the meta table */
  assert(lua_istable(L,-1));  /* just in case */
  SWIG_Lua_get_table(L,".get"); /* find the .get table */
  assert(lua_istable(L,-1));  /* just in case */
  /* look for the key in the .get table */
  lua_pushvalue(L,base+2);  /* key */
  lua_rawget(L,-2);
  lua_remove(L,-2); /* stack tidy, remove .get table */
  if (lua_iscfunction(L,-1))
  {  /* found it so call the fn & return its value */
    lua_pushvalue(L,base+1);  /* the userdata */
    lua_call(L,1,1);  /* 1 value in (userdata),1 out (result) */
    lua_remove(L,-2); /* stack tidy, remove metatable */
    return 1;
  }
  lua_pop(L,1);  /* remove whatever was there */
  /* ok, so try the .fn table */
  SWIG_Lua_get_table(L,".fn"); /* find the .fn table */
  assert(lua_istable(L,-1));  /* just in case */
  lua_pushvalue(L,base+2);  /* key */
  lua_rawget(L,-2);  /* look for the fn */
  lua_remove(L,-2); /* stack tidy, remove .fn table */
  if (lua_isfunction(L,-1)) /* note: if its a C function or lua function */
  {  /* found it so return the fn & let lua call it */
    lua_remove(L,-2); /* stack tidy, remove metatable */
    return 1;
  }
  lua_pop(L,1);  /* remove whatever was there */
  /* NEW: looks for the __getitem() fn
  this is a user provided get fn */
  SWIG_Lua_get_table(L,"__getitem"); /* find the __getitem fn */
  if (lua_iscfunction(L,-1))  /* if its there */
  {  /* found it so call the fn & return its value */
    lua_pushvalue(L,base+1);  /* the userdata */
    lua_pushvalue(L,base+2);  /* the parameter */
    lua_call(L,2,1);  /* 2 value in (userdata),1 out (result) */
    lua_remove(L,-2); /* stack tidy, remove metatable */
    return 1;
  }
  lua_pop(L,1);
  // Search in base classes
  // TODO: Different for elua_ltr
  SWIG_Lua_get_table(L,".bases");
  assert(lua_istable(L,-1));
  int bases_count = lua_rawlen(L,-1);
  if(bases_count>0)
  {
    int original_metatable = lua_absindex(L,-2);
    int i;
    int ret = 0; // Number of returned values
    lua_pushvalue(L,base+1); // push userdata
    lua_pushvalue(L,base+2); // Push key again
    // Trick: temporaly replacing original metatable
    // with metatable for base class and call getter
    for(i=0;i<bases_count;i++) {
      lua_rawgeti(L,-3,i+1); // get base metatable here
      assert(lua_istable(L,-1));
      assert(lua_isuserdata(L,-3));
      lua_setmetatable(L,-3); // Set new metatable
      assert(lua_isuserdata(L,-2));
      ret = SWIG_Lua_class_get(L); // Forward call
      assert(ret==0||ret==1);
      if(ret>0)
        break;
    }
    // Return original metatable back
    lua_pushvalue(L,original_metatable);
    lua_setmetatable(L,base+1);
    if(ret>0)
    {
      // tidy stack. Stack currently is:
      // --base--
      // userdata
      // key
      // metatable
      // .bases table
      // userdata
      // key : -2
      // return value : -1
      lua_remove(L,-2); // remove key
      lua_remove(L,-2); // remove userdata
      lua_remove(L,-2); // remove .bases
      lua_remove(L,-2); // remove metatable
      return 1;
    } else {
      lua_pop(L,2); // remove key and userdata
    }
  }
  // Tidy stack:
  // --base--
  // userdata
  // key
  // metatable
  // .bases table
  lua_pop(L,2);
  assert(lua_gettop(L)==base+2);
  return 0;  /* sorry not known */
}

/* helper for the class.set method, performs the lookup of class attributes
 * Method can be called from SWIG_Lua_class_set or recursively from itself
 */
SWIGINTERN int  SWIG_Lua_class_do_set(lua_State* L)
{
/*  there should be 3 params passed in
  (1) table (not the meta table)
  (2) string name of the attribute
  (3) any for the new value
printf("SWIG_Lua_class_set %p(%s) '%s' %p(%s)\n",
      lua_topointer(L,-3),lua_typename(L,lua_type(L,-3)),
      lua_tostring(L,-2),
      lua_topointer(L,-1),lua_typename(L,lua_type(L,-1)));*/

  int base = lua_gettop(L) - 3;
  lua_checkstack(L,5);
  assert(lua_isuserdata(L,base+1));  /* just in case */
  lua_getmetatable(L,base+1);    /* get the meta table */
  assert(lua_istable(L,-1));  /* just in case */

  SWIG_Lua_get_table(L,".set"); /* find the .set table */
  if (lua_istable(L,-1))
  {
    /* look for the key in the .set table */
    lua_pushvalue(L,base+2);  /* key */
    lua_rawget(L,-2);
    lua_remove(L,-2); /* tidy stack, remove .set table */
    if (lua_iscfunction(L,-1))
    {  /* found it so call the fn & return its value */
      lua_pushvalue(L,base+1);  /* userdata */
      lua_pushvalue(L,base+3);  /* value */
      lua_call(L,2,0);
      lua_remove(L,base+4); /*remove metatable*/
      assert(lua_gettop(L) == base+3); // TODO:REMOVE
      return 0;
    }
    lua_pop(L,1);  /* remove the value */
  } else {
    lua_pop(L,1);  /* remove the answer for .set table request*/
  }
  assert(lua_gettop(L) == base + 4); // TODO: REMOVE
  /* NEW: looks for the __setitem() fn
  this is a user provided set fn */
  SWIG_Lua_get_table(L,"__setitem"); /* find the fn */
  if (lua_iscfunction(L,-1))  /* if its there */
  {  /* found it so call the fn & return its value */
    lua_pushvalue(L,base+1);  /* the userdata */
    lua_pushvalue(L,base+2);  /* the parameter */
    lua_pushvalue(L,base+3);  /* the value */
    lua_call(L,3,0);  /* 3 values in ,0 out */
    lua_remove(L,-2); /* stack tidy, remove metatable */
    return 0;
  }
  lua_pop(L,1); // remove value
  assert(lua_gettop(L) == base + 4); // TODO: REMOVE

  // Search among bases
  int original_metatable = base+4;
  assert(lua_gettop(L) == original_metatable); // Check that stack is correct
  SWIG_Lua_get_table(L,".bases");
  assert(lua_istable(L,-1));
  int bases_count = lua_rawlen(L,-1);
  if(bases_count>0)
  {
    int i = 0;
    int ret = 0;
    lua_pushvalue(L,base+1); // push userdata
    lua_pushvalue(L,base+2); // Push key again
    lua_pushvalue(L,base+3); // Push value again
    // Trick: temporaly replacing original metatable
    // with metatable for base class and call getter
    for(i=0;i<bases_count;i++) {
      lua_rawgeti(L,-4,i+1); // get base metatable here
      assert(lua_istable(L,-1));
      assert(lua_isuserdata(L,-4));
      lua_setmetatable(L,-4); // Set new metatable
      assert(lua_isuserdata(L,-3));
      ret = SWIG_Lua_class_do_set(L); // Forward call
      assert(ret==0||ret==-1);
      if(ret==0)
        break;
    }
    // Return original metatable back
    lua_pushvalue(L,original_metatable);
    lua_setmetatable(L,base+1);
    if(ret==0)
    {
      // tidy stack. Stack currently is:
      // --base--
      // userdata
      // key
      // value
      // metatable
      // .bases table
      // userdata
      // key : -2
      // value: -1
      lua_pop(L,5);
      return 0;
    } else {
      lua_pop(L,3); // remove userdata, key and value
    }
  }
  lua_pop(L,1); // remove .bases_table

  lua_pop(L,1); // remove metatable
  assert(lua_gettop(L) == base+3);
  return -1; // Indicator that search failed
}

/* This is actuall method exported to Lua. It calls SWIG_Lua_class_do_set and correctly
 * handlers return value
 */
SWIGINTERN int  SWIG_Lua_class_set(lua_State* L)
{
  int ret= SWIG_Lua_class_do_set(L);
  if(ret==0)
    return 0;
  else if(ret==-1) {
   SWIG_Lua_pushferrstring(L,"Assignment not possible. No setter/member with this name. For custom assignments implement __setitem method");
   lua_error(L);
  } else {
    assert(0); // Internal implementation error
    return 0;
  }
}

/* the class.destruct method called by the interpreter */
SWIGINTERN int  SWIG_Lua_class_destruct(lua_State* L)
{
/*  there should be 1 params passed in
  (1) userdata (not the meta table) */
  swig_lua_userdata* usr;
  swig_lua_class* clss;
  assert(lua_isuserdata(L,-1));  /* just in case */
  usr=(swig_lua_userdata*)lua_touserdata(L,-1);  /* get it */
  /* if must be destroyed & has a destructor */
  if (usr->own) /* if must be destroyed */
  {
    clss=(swig_lua_class*)usr->type->clientdata;  /* get the class */
    if (clss && clss->destructor)  /* there is a destroy fn */
    {
      clss->destructor(usr->ptr);  /* bye bye */
    }
  }
  return 0;
}

/* the class.__tostring method called by the interpreter and print */
SWIGINTERN int  SWIG_Lua_class_tostring(lua_State* L)
{
/*  there should be 1 param passed in
  (1) userdata (not the metatable) */
  assert(lua_isuserdata(L,1));  /* just in case */
  unsigned long userData = (unsigned long)lua_touserdata(L,1); /* get the userdata address for later */
  lua_getmetatable(L,1);    /* get the meta table */
  assert(lua_istable(L,-1));  /* just in case */

  lua_getfield(L, -1, ".type");
  const char* className = lua_tostring(L, -1);

  char output[256];
  snprintf(output, 255, "<%s userdata: %lX>", className, userData);

  lua_pushstring(L, (const char*)output);
  return 1;
}

/* to manually disown some userdata */
SWIGINTERN int  SWIG_Lua_class_disown(lua_State* L)
{
/*  there should be 1 params passed in
  (1) userdata (not the meta table) */
  swig_lua_userdata* usr;
  assert(lua_isuserdata(L,-1));  /* just in case */
  usr=(swig_lua_userdata*)lua_touserdata(L,-1);  /* get it */
  
  usr->own = 0; /* clear our ownership */
  return 0;
}

/* gets the swig class registry (or creates it) */
SWIGINTERN void  SWIG_Lua_get_class_registry(lua_State* L)
{
  /* add this all into the swig registry: */
  lua_pushstring(L,"SWIG");
  lua_rawget(L,LUA_REGISTRYINDEX);  /* get the registry */
  if (!lua_istable(L,-1))  /* not there */
  {  /* must be first time, so add it */
    lua_pop(L,1);  /* remove the result */
    lua_pushstring(L,"SWIG");
    lua_newtable(L);
    lua_rawset(L,LUA_REGISTRYINDEX);
    /* then get it */
    lua_pushstring(L,"SWIG");
    lua_rawget(L,LUA_REGISTRYINDEX);
  }
}

/* helper fn to get the classes metatable from the register */
SWIGINTERN void  SWIG_Lua_get_class_metatable(lua_State* L,const char* cname)
{
  SWIG_Lua_get_class_registry(L);  /* get the registry */
  lua_pushstring(L,cname);  /* get the name */
  lua_rawget(L,-2);    /* get it */
  lua_remove(L,-2);    /* tidy up (remove registry) */
}

/* helper add a variable to a registered class */
SWIGINTERN void  SWIG_Lua_add_variable(lua_State* L,const char* name,lua_CFunction getFn,lua_CFunction setFn)
{
  assert(lua_istable(L,-1));  /* just in case */
  SWIG_Lua_get_table(L,".get"); /* find the .get table */
  assert(lua_istable(L,-1));  /* just in case */
  SWIG_Lua_add_function(L,name,getFn);
  lua_pop(L,1);       /* tidy stack (remove table) */
  if (setFn)
  {
    SWIG_Lua_get_table(L,".set"); /* find the .set table */
    assert(lua_istable(L,-1));  /* just in case */
    SWIG_Lua_add_function(L,name,setFn);
    lua_pop(L,1);       /* tidy stack (remove table) */
  }
}

/* helper to recursively add class static details (static attributes, operations and constants) */
SWIGINTERN void SWIG_Lua_add_class_static_details(lua_State* L, swig_lua_class* clss)
{
  int i = 0;
  /* The class namespace table must be on the top of the stack */
  assert(lua_istable(L,-1));
  /* call all the base classes first: we can then override these later: */
  for(i=0;clss->bases[i];i++)
  {
    SWIG_Lua_add_class_static_details(L,clss->bases[i]);
  }

  SWIG_Lua_add_namespace_details(L, &clss->cls_static);
}

/* helper to recursively add class details (attributes & operations) */
SWIGINTERN void  SWIG_Lua_add_class_instance_details(lua_State* L,swig_lua_class* clss)
{
  int i;
  // Add bases to .bases table
  SWIG_Lua_get_table(L,".bases");
  assert(lua_istable(L,-1));  /* just in case */
  int bases_count = 0;
  for(i=0;clss->bases[i];i++)
  {
    SWIG_Lua_get_class_metatable(L,clss->bases[i]->fqname);
    // Base class must be already registered
    assert(lua_istable(L,-1));
    lua_rawseti(L,-2,i+1); // In lua indexing starts from 1
    bases_count++;
  }
  assert(lua_rawlen(L,-1) == bases_count);
  lua_pop(L,1); // remove .bases table
  /* add attributes */
  for(i=0;clss->attributes[i].name;i++){
    SWIG_Lua_add_variable(L,clss->attributes[i].name,clss->attributes[i].getmethod,clss->attributes[i].setmethod);
  }
  /* add methods to the metatable */
  SWIG_Lua_get_table(L,".fn"); /* find the .fn table */
  assert(lua_istable(L,-1));  /* just in case */
  for(i=0;clss->methods[i].name;i++){
    SWIG_Lua_add_function(L,clss->methods[i].name,clss->methods[i].func);
  }
  lua_pop(L,1);       /* tidy stack (remove table) */
  /*   add operator overloads
    these look ANY method which start with "__" and assume they
    are operator overloads & add them to the metatable
    (this might mess up if someone defines a method __gc (the destructor)*/
  for(i=0;clss->methods[i].name;i++){
    if (clss->methods[i].name[0]=='_' && clss->methods[i].name[1]=='_'){
      SWIG_Lua_add_function(L,clss->methods[i].name,clss->methods[i].func);
    }
  }
}

/* set up the base classes pointers.
Each class structure has a list of pointers to the base class structures.
This function fills them.
It cannot be done at compile time, as this will not work with hireachies
spread over more than one swig file. 
Therefore it must be done at runtime, querying the SWIG type system.
*/
SWIGINTERN void SWIG_Lua_init_base_class(lua_State* L,swig_lua_class* clss)
{
  int i=0;
  swig_module_info* module=SWIG_GetModule(L);
  for(i=0;clss->base_names[i];i++)
  {
    if (clss->bases[i]==0) /* not found yet */
    {
      /* lookup and cache the base class */
      swig_type_info *info = SWIG_TypeQueryModule(module,module,clss->base_names[i]);
      if (info) clss->bases[i] = (swig_lua_class *) info->clientdata;
    }
  }
}

/* Register class static methods,attributes etc as well as constructor proxy */
SWIGINTERN void SWIG_Lua_class_register_static(lua_State* L, swig_lua_class* clss)
{
  int begin = lua_gettop(L);
  lua_checkstack(L,5); /* just in case */
  assert(lua_istable(L,-1));  /* just in case */
  assert(strcmp(clss->name, clss->cls_static.name) == 0); /* in class those 2 must be equal */

  SWIG_Lua_namespace_register(L,&clss->cls_static, true);

  assert(lua_istable(L,-1)); /* just in case */

  /*  add its constructor to module with the name of the class
  so you can do MyClass(...) as well as new_MyClass(...)
  BUT only if a constructor is defined
  (this overcomes the problem of pure virtual classes without constructors)*/
  if (clss->constructor)
  {
    lua_getmetatable(L,-1);
    assert(lua_istable(L,-1)); /* just in case */
    SWIG_Lua_add_function(L,"__call", clss->constructor);
    lua_pop(L,1);
  }

  assert(lua_istable(L,-1)); /* just in case */
  SWIG_Lua_add_class_static_details(L, clss);

  /* clear stack */
  lua_pop(L,1);
  assert( lua_gettop(L) == begin );
}

/* performs the instance(non-static) class registration process. Metatable for class is created
 * and added to the class registry.
 */
SWIGINTERN void  SWIG_Lua_class_register_instance(lua_State* L,swig_lua_class* clss)
{
  int begin = lua_gettop(L);
  // if name already there (class is already registered) then do nothing
  SWIG_Lua_get_class_registry(L);  /* get the registry */
  lua_pushstring(L,clss->fqname);  /* get the name */
  lua_rawget(L,-2);
  if(!lua_isnil(L,-1)) {
    lua_pop(L,2);
    assert(lua_gettop(L)==begin);
    return;
  }
  lua_pop(L,2); // tidy stack
  // Recursively initialize all bases
  int i = 0;
  for(i=0;clss->bases[i];i++)
  {
    SWIG_Lua_class_register_instance(L,clss->bases[i]);
  }
  // Again, get registry and push name
  SWIG_Lua_get_class_registry(L);  /* get the registry */
  lua_pushstring(L,clss->fqname);  /* get the name */
  lua_newtable(L);    /* create the metatable */
  /* add string of class name called ".type" */
  lua_pushstring(L,".type");
  lua_pushstring(L,clss->fqname);
  lua_rawset(L,-3);
  /* add a table called bases */
  lua_pushstring(L,".bases");
  lua_newtable(L);
  lua_rawset(L,-3);
  /* add a table called ".get" */
  lua_pushstring(L,".get");
  lua_newtable(L);
  lua_rawset(L,-3);
  /* add a table called ".set" */
  lua_pushstring(L,".set");
  lua_newtable(L);
  lua_rawset(L,-3);
  /* add a table called ".fn" */
  lua_pushstring(L,".fn");
  lua_newtable(L);
  /* add manual disown method */
  SWIG_Lua_add_function(L,"__disown",SWIG_Lua_class_disown);
  lua_rawset(L,-3);
  /* add accessor fns for using the .get,.set&.fn */
  SWIG_Lua_add_function(L,"__index",SWIG_Lua_class_get);
  SWIG_Lua_add_function(L,"__newindex",SWIG_Lua_class_set);
  SWIG_Lua_add_function(L,"__gc",SWIG_Lua_class_destruct);
  /* add tostring method for better output */
  SWIG_Lua_add_function(L,"__tostring",SWIG_Lua_class_tostring);
  /* add it */
  lua_rawset(L,-3);  /* metatable into registry */
  lua_pop(L,1);      /* tidy stack (remove registry) */
  assert(lua_gettop(L)==begin);

  SWIG_Lua_get_class_metatable(L,clss->fqname);
  SWIG_Lua_add_class_instance_details(L,clss);  /* recursive adding of details (atts & ops) */
  lua_pop(L,1);      /* tidy stack (remove class metatable) */
  assert( lua_gettop(L) == begin );
}

SWIGINTERN void  SWIG_Lua_class_register(lua_State* L,swig_lua_class* clss)
{
  assert(lua_istable(L,-1)); /* This is table(module or namespace) where class will be added */
  SWIG_Lua_class_register_instance(L,clss);
  SWIG_Lua_class_register_static(L,clss);

  /* Add links from static part to instance part and vice versa */
  /* [SWIG registry]                                   [Module]
   *    "MyClass" ----> [MyClass metatable] <=====     "MyClass" -+> [static part]
   *                     ".get" ----> ...        |                |     getmetatable()----|
   *                     ".set" ----> ...        |                |                       |
   *                     ".static" --------------)----------------/           [static part metatable]
   *                                             |                                ".get" --> ...
   *                                             |                                ".set" --> ....
   *                                             |=============================== ".instance"
   */
  int begin = lua_gettop(L);
  lua_pushstring(L,clss->cls_static.name);
  lua_rawget(L,-2); /* get class static table */
  assert(lua_istable(L,-1));
  lua_getmetatable(L,-1);
  assert(lua_istable(L,-1)); /* get class static metatable */
  lua_pushstring(L,".instance"); /* prepare key */

  SWIG_Lua_get_class_metatable(L,clss->fqname); /* get class metatable */
  assert(lua_istable(L,-1));
  lua_pushstring(L,".static"); /* prepare key */
  lua_pushvalue(L, -4); /* push static class TABLE */
  assert(lua_istable(L,-1));
  lua_rawset(L,-3); /* assign static class table(!NOT metatable) as ".static" member of class metatable */
  lua_rawset(L,-3); /* assign class metatable as ".instance" member of class static METATABLE */
  lua_pop(L,2);
  assert(lua_gettop(L) == begin);
}

/* -----------------------------------------------------------------------------
 * Class/structure conversion fns
 * ----------------------------------------------------------------------------- */

/* helper to add metatable to new lua object */
SWIGINTERN void _SWIG_Lua_AddMetatable(lua_State* L,swig_type_info *type)
{
  if (type->clientdata)  /* there is clientdata: so add the metatable */
  {
    SWIG_Lua_get_class_metatable(L,((swig_lua_class*)(type->clientdata))->fqname);
    if (lua_istable(L,-1))
    {
      lua_setmetatable(L,-2);
    }
    else
    {
      lua_pop(L,1);
    }
  }
}

/* pushes a new object into the lua stack */
SWIGRUNTIME void SWIG_Lua_NewPointerObj(lua_State* L,void* ptr,swig_type_info *type, int own)
{
  swig_lua_userdata* usr;
  if (!ptr){
    lua_pushnil(L);
    return;
  }
  usr=(swig_lua_userdata*)lua_newuserdata(L,sizeof(swig_lua_userdata));  /* get data */
  usr->ptr=ptr;  /* set the ptr */
  usr->type=type;
  usr->own=own;
#if (SWIG_LUA_TARGET != SWIG_LUA_FLAVOR_ELUAC)
  _SWIG_Lua_AddMetatable(L,type); /* add metatable */
#endif
}

/* takes a object from the lua stack & converts it into an object of the correct type
 (if possible) */
SWIGRUNTIME int  SWIG_Lua_ConvertPtr(lua_State* L,int index,void** ptr,swig_type_info *type,int flags)
{
  swig_lua_userdata* usr;
  swig_cast_info *cast;
  if (lua_isnil(L,index)){*ptr=0; return SWIG_OK;}    /* special case: lua nil => NULL pointer */
  usr=(swig_lua_userdata*)lua_touserdata(L,index);  /* get data */
  if (usr)
  {
    if (flags & SWIG_POINTER_DISOWN) /* must disown the object */
    {
        usr->own=0;
    }
    if (!type)            /* special cast void*, no casting fn */
    {
      *ptr=usr->ptr;
      return SWIG_OK; /* ok */
    }
    cast=SWIG_TypeCheckStruct(usr->type,type); /* performs normal type checking */
    if (cast)
    {
      int newmemory = 0;
      *ptr=SWIG_TypeCast(cast,usr->ptr,&newmemory);
      assert(!newmemory); /* newmemory handling not yet implemented */
      return SWIG_OK;  /* ok */
    }
  }
  return SWIG_ERROR;  /* error */
}

SWIGRUNTIME void* SWIG_Lua_MustGetPtr(lua_State* L,int index,swig_type_info *type,int flags,
       int argnum,const char* func_name){
  void* result;
  if (!SWIG_IsOK(SWIG_ConvertPtr(L,index,&result,type,flags))){
    luaL_error (L,"Error in %s, expected a %s at argument number %d\n",
		func_name,(type && type->str)?type->str:"void*",argnum);
  }
  return result;
}

/* pushes a packed userdata. user for member fn pointers only */
SWIGRUNTIME void SWIG_Lua_NewPackedObj(lua_State* L,void* ptr,size_t size,swig_type_info *type)
{
  swig_lua_rawdata* raw;
  assert(ptr); /* not acceptable to pass in a NULL value */
  raw=(swig_lua_rawdata*)lua_newuserdata(L,sizeof(swig_lua_rawdata)-1+size);  /* alloc data */
  raw->type=type;
  raw->own=0;
  memcpy(raw->data,ptr,size); /* copy the data */
  _SWIG_Lua_AddMetatable(L,type); /* add metatable */
}
    
/* converts a packed userdata. user for member fn pointers only */
SWIGRUNTIME int  SWIG_Lua_ConvertPacked(lua_State* L,int index,void* ptr,size_t size,swig_type_info *type)
{
  swig_lua_rawdata* raw;
  raw=(swig_lua_rawdata*)lua_touserdata(L,index);  /* get data */
  if (!raw) return SWIG_ERROR;  /* error */
  if (type==0 || type==raw->type) /* void* or identical type */
  {
    memcpy(ptr,raw->data,size); /* copy it */
    return SWIG_OK; /* ok */
  }
  return SWIG_ERROR;  /* error */
}

/* a function to get the typestring of a piece of data */
SWIGRUNTIME const char *SWIG_Lua_typename(lua_State *L, int tp)
{
  swig_lua_userdata* usr;
  if (lua_isuserdata(L,tp))
  {
    usr=(swig_lua_userdata*)lua_touserdata(L,tp);  /* get data */
    if (usr && usr->type && usr->type->str)
      return usr->type->str;
    return "userdata (unknown type)";
  }
  return lua_typename(L,lua_type(L,tp));
}

/* lua callable function to get the userdata's type */
SWIGRUNTIME int SWIG_Lua_type(lua_State* L)
{
  lua_pushstring(L,SWIG_Lua_typename(L,1));
  return 1;
}

/* lua callable function to compare userdata's value
the issue is that two userdata may point to the same thing
but to lua, they are different objects */
SWIGRUNTIME int SWIG_Lua_equal(lua_State* L)
{
  int result;
  swig_lua_userdata *usr1,*usr2;
  if (!lua_isuserdata(L,1) || !lua_isuserdata(L,2))  /* just in case */
    return 0;  /* nil reply */
  usr1=(swig_lua_userdata*)lua_touserdata(L,1);  /* get data */
  usr2=(swig_lua_userdata*)lua_touserdata(L,2);  /* get data */
  /*result=(usr1->ptr==usr2->ptr && usr1->type==usr2->type); only works if type is the same*/
  result=(usr1->ptr==usr2->ptr);
   lua_pushboolean(L,result);
  return 1;
}

/* -----------------------------------------------------------------------------
 * global variable support code: class/struct typemap functions
 * ----------------------------------------------------------------------------- */

#if ((SWIG_LUA_TARGET != SWIG_LUA_FLAVOR_ELUA) && (SWIG_LUA_TARGET != SWIG_LUA_FLAVOR_ELUAC))
/* Install Constants */
SWIGINTERN void
SWIG_Lua_InstallConstants(lua_State* L, swig_lua_const_info constants[]) {
  int i;
  for (i = 0; constants[i].type; i++) {
    switch(constants[i].type) {
    case SWIG_LUA_INT:
      lua_pushstring(L,constants[i].name);
      lua_pushnumber(L,(lua_Number)constants[i].lvalue);
      lua_rawset(L,-3);
      break;
    case SWIG_LUA_FLOAT:
      lua_pushstring(L,constants[i].name);
      lua_pushnumber(L,(lua_Number)constants[i].dvalue);
      lua_rawset(L,-3);
      break;
    case SWIG_LUA_CHAR:
      lua_pushstring(L,constants[i].name);
      lua_pushfstring(L,"%c",(char)constants[i].lvalue);
      lua_rawset(L,-3);
      break;
    case SWIG_LUA_STRING:
      lua_pushstring(L,constants[i].name);
      lua_pushstring(L,(char *) constants[i].pvalue);
      lua_rawset(L,-3);
      break;
    case SWIG_LUA_POINTER:
      lua_pushstring(L,constants[i].name);
      SWIG_NewPointerObj(L,constants[i].pvalue, *(constants[i]).ptype,0);
      lua_rawset(L,-3);
      break;
    case SWIG_LUA_BINARY:
      lua_pushstring(L,constants[i].name);
      SWIG_NewMemberObj(L,constants[i].pvalue,constants[i].lvalue,*(constants[i]).ptype);
      lua_rawset(L,-3);
      break;
    default:
      break;
    }
  }
}
#endif

/* -----------------------------------------------------------------------------
 * executing lua code from within the wrapper
 * ----------------------------------------------------------------------------- */

#ifndef SWIG_DOSTRING_FAIL /* Allows redefining of error function */
#define SWIG_DOSTRING_FAIL(S) fprintf(stderr,"%s\n",S)
#endif
/* Executes a C string in Lua which is a really simple way of calling lua from C
Unfortunately lua keeps changing its APIs, so we need a conditional compile
In lua 5.0.X its lua_dostring()
In lua 5.1.X its luaL_dostring()
*/
SWIGINTERN int 
SWIG_Lua_dostring(lua_State *L, const char* str) {
  int ok,top;
  if (str==0 || str[0]==0) return 0; /* nothing to do */
  top=lua_gettop(L); /* save stack */
#if (defined(LUA_VERSION_NUM) && (LUA_VERSION_NUM>=501))
  ok=luaL_dostring(L,str);	/* looks like this is lua 5.1.X or later, good */
#else
  ok=lua_dostring(L,str);	/* might be lua 5.0.x, using lua_dostring */
#endif
  if (ok!=0) {
    SWIG_DOSTRING_FAIL(lua_tostring(L,-1));
  }
  lua_settop(L,top); /* restore the stack */
  return ok;
}    

#ifdef __cplusplus
}
#endif

/* -----------------------------------------------------------------------------
 * runtime class manipulation
 * ----------------------------------------------------------------------------- */
 
#if ((SWIG_LUA_TARGET != SWIG_LUA_FLAVOR_ELUA) && (SWIG_LUA_TARGET != SWIG_LUA_FLAVOR_ELUAC))
/* Set of functions that allow manipulating class bindings from C/C++ and from lua
 */

SWIGINTERN bool
SWIG_Lua_metaclass_add_table(lua_State *L, int metatable_index, const char *class_name, const char *metatable_name,
    const char *metaclass_name)
{
  /* Table to add new field must be on to of the stack */
  assert(lua_istable(L,-1));
  lua_pushstring(L,metaclass_name);
  lua_pushvalue(L,metatable_index);
  lua_pushstring(L,metatable_name);
  lua_rawget(L,-2);
  if(!lua_istable(L,-1)) {
    SWIG_Lua_pushferrstring(L,"Class %s metatable is corrupt. Table %s is missing or not a table", class_name, metatable_name);
    return false;
  }
  lua_rawset(L,-2);
  return true;
}

SWIGRUNTIME int
SWIG_Lua_get_class_metaclass(lua_State *L)
{
  /* One argument:
   *  - SWIG name of class as string
   *  - or instance of class
   *  - or class entry point in module
   * metaclass( "MyClass<int,double>" )
   * metaclass( myvar_of_type_MyClass_int_double )
   * metaclass( module.MyClass_int_double )
   */
  const char *class_name = 0;
  int metatable_index = 0;
  int static_metatable_index = 0;
  int static_table_index = 0;
  int answer_index = 0;
  SWIG_check_num_args("SWIG_Lua_metaclass", 1, 1);
  lua_checkstack(L,15);
  if(lua_type(L,1) == LUA_TSTRING) { // class name is given
    class_name = lua_tostring(L,1);
    SWIG_Lua_get_class_registry(L); /* get the registry */
    assert(lua_istable(L,-1));
    lua_pushvalue(L,1);
    lua_rawget(L,-2); /* get class metatable */
    if(!lua_istable(L,-1)) {
      SWIG_Lua_pushferrstring(L,"There is no registered class with name %s", class_name );
      SWIG_fail
    }
    metatable_index = lua_gettop(L);
  } else if(lua_isuserdata(L,1)) { // class instance is given
    /* We don't check that class is registered in SWIG because it can be user-created-in-lua class */
    lua_getmetatable(L,1);
    if(!lua_istable(L,-1)) {
      SWIG_Lua_pushferrstring(L,"Userdata is passed, but it is not SWIG-wrapped class. There is no metatable.");
      SWIG_fail;
    }
    metatable_index = lua_gettop(L);
    lua_getfield(L,-1,".type");
    if(lua_type(L,-1) != LUA_TSTRING) {
      SWIG_Lua_pushferrstring(L,"Userdata is passed, but it is not SWIG-wrapped class. Metatable has different structure.");
      SWIG_fail;
    }
    class_name = lua_tostring(L,-1);
  } else { // class entry is given. Well, it is supposed to be a class entry :)
    lua_getmetatable(L,1); /* get metatable */
    if(!lua_istable(L,-1)) {
      SWIG_Lua_pushferrstring(L, "Table is passed but it is not SWIG class entry point. There is no metatable");
      SWIG_fail;
    }
    lua_getfield(L,-1, ".instance"); /* get class metatable */
    if(lua_isnil(L,-1)) {
      SWIG_Lua_pushferrstring(L, "Table is passed but it is not SWIG class entry point.  Metatable has different structure.");
      SWIG_fail;
    }
    metatable_index = lua_gettop(L);
    lua_getfield(L,-1,".type");
    if(lua_type(L,-1) != LUA_TSTRING) {
      SWIG_Lua_pushferrstring(L,"Userdata is passed, but it is not SWIG-wrapped class. Metatable has different structure.");
      SWIG_fail;
    }
    class_name = lua_tostring(L,-1);
  }

  /* Get static table */
  lua_getfield(L,metatable_index,".static");
  assert(!lua_isnil(L,-1));
  static_table_index = lua_gettop(L);
  /* Get static metatable */
  lua_getmetatable(L,-1);
  assert(!lua_isnil(L,-1));
  static_metatable_index = lua_gettop(L);
  /* This will be our answer */
  lua_newtable(L);
  answer_index = lua_gettop(L);
  /* Adding instance member manipulators
   * .bases can't be edited
   */
  if(!SWIG_Lua_metaclass_add_table(L,metatable_index,class_name, ".fn", "methods") )
    SWIG_fail;
  if(!SWIG_Lua_metaclass_add_table(L,metatable_index,class_name, ".get", "getters") )
    SWIG_fail;
  if(!SWIG_Lua_metaclass_add_table(L,metatable_index,class_name, ".set", "setters") )
    SWIG_fail;
  /* Adding static members manipulators */
  if(!SWIG_Lua_metaclass_add_table(L,static_metatable_index,class_name, ".get", "static_getters") )
    SWIG_fail;
  if(!SWIG_Lua_metaclass_add_table(L,static_metatable_index,class_name, ".set", "static_setters") )
    SWIG_fail;
  lua_pushstring(L, "static_methods");
  lua_pushvalue(L, static_table_index);
  lua_rawset(L,-3);

  lua_pushstring(L, "static_constants");
  lua_pushvalue(L, static_table_index);
  lua_rawset(L,-3);

  assert(lua_gettop(L) == answer_index);
  return 1;

fail:
  lua_error(L);
  return 0;
}

/* Creates new class in lua. Must inherit existing SWIG class */
SWIGRUNTIME int
SWIG_Lua_new_class(lua_State *L) {
  SWIG_check_num_args("SWIG_Lua_new_class", 1, 1);
  return 0;

fail:
  lua_error(L);
  return 0;

}
#endif

/* ------------------------------ end luarun.swg  ------------------------------ */
