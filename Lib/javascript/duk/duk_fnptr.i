/* -----------------------------------------------------------------------------
 * lua_fnptr.i
 *
 * SWIG Library file containing the main typemap code to support Lua modules.
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 *                          Basic function pointer support
 * ----------------------------------------------------------------------------- */
/*
The structure: SWIGDUK_FN provides a simple (local only) wrapping for a function.

For example if you wanted to have a C/C++ function take a lua function as a parameter.
You could declare it as:
  int my_func(int a, int b, SWIGDUK_FN fn);
note: it should be passed by value, not byref or as a pointer.

The SWIGDUK_FN holds a pointer to the lua_State, and the stack index where the function is held.
The macro SWIGDUK_FN_GET() will put a copy of the lua function at the top of the stack.
After that its fairly simple to write the rest of the code (assuming know how to use lua),
just push the parameters, call the function and return the result.

  int my_func(int a, int b, SWIGDUK_FN fn)
  {
    SWIGDUK_FN_GET(fn);
    lua_pushnumber(fn.L,a);
    lua_pushnumber(fn.L,b);
    lua_call(fn.L,2,1);    // 2 in, 1 out
    return luaL_checknumber(fn.L,-1);
  }

SWIG will automatically performs the wrapping of the arguments in and out.

However: if you wish to store the function between calls, look to the SWIGDUK_REF below.

*/
// this is for the C code only, we don't want SWIG to wrapper it for us.
%{
typedef struct{
  duk_context *ctx; /* the state */
  duk_idx_t idx;      /* the index on the stack */
} SWIGDUK_FN;

#define SWIGDUK_FN_GET(fn) {lua_pushvalue(fn.ctx,fn.idx);}
%}

// the actual typemap
%typemap(in,checkfn="duk_is_function") SWIGDUK_FN
%{  $1.ctx=ctx; $1.idx=$input; %}

/* -----------------------------------------------------------------------------
 *                          Storing Duktape object support
 * ----------------------------------------------------------------------------- */
/*
The structure: SWIGDUK_REF provides a mechanism to store object (usually functions)
between calls to the interpreter.

For example if you wanted to have a C/C++ function take a lua function as a parameter.
Then call it later, You could declare it as:
  SWIGDUK_REF myref;
  void set_func(SWIGDUK_REF ref);
  SWIGDUK_REF get_func();
  void call_func(int val);
note: it should be passed by value, not byref or as a pointer.

The SWIGDUK_REF holds a pointer to the lua_State, and an integer reference to the object.
Because it holds a permanent ref to an object, the SWIGDUK_REF must be handled with a bit more care.
It should be initialised to {0,0}. The function swigduk_ref_set() should be used to set it.
swigduk_ref_clear() should be used to clear it when not in use, and swigduk_ref_get() to get the
data back.

Note: the typemap does not check that the object is in fact a function,
if you need that you must add it yourself.


  int my_func(int a, int b, SWIGDUK_FN fn)
  {
    SWIGDUK_FN_GET(fn);
    lua_pushnumber(fn.L,a);
    lua_pushnumber(fn.L,b);
    lua_call(fn.L,2,1);    // 2 in, 1 out
    return luaL_checknumber(fn.L,-1);
  }

SWIG will automatically performs the wrapping of the arguments in and out.

However: if you wish to store the function between calls, look to the SWIGDUK_REF below.

*/

%{
typedef struct{
  duk_context *ctx; /* the state */
  duk_idx_t ref;      /* a ref in the lua global index */
}SWIGDUK_REF;


void swigduk_ref_clear(SWIGDUK_REF* pref){
 	if (pref->L!=0 && pref->ref!=LUA_NOREF && pref->ref!=LUA_REFNIL){
		luaL_unref(pref->L,LUA_REGISTRYINDEX,pref->ref);
	}
	pref->L=0; pref->ref=0;
}

void swigduk_ref_set(SWIGDUK_REF* pref,duk_context *ctx,duk_idx_t idx){
	pref->ctx=ctx;
	lua_pushvalue(ctx,idx);                 /* copy obj to top */
	pref->ref=luaL_ref(L,LUA_REGISTRYINDEX); /* remove obj from top & put into registry */
}

void swigduk_ref_get(SWIGDUK_REF* pref){
	if (pref->L!=0)
		lua_rawgeti(pref->L,LUA_REGISTRYINDEX,pref->ref);
}

%}

%typemap(in) SWIGDUK_REF
%{  swigduk_ref_set(&$1,L,$input); %}

%typemap(out) SWIGDUK_REF
%{  if ($1.L!=0)  {swigduk_ref_get(&$1);} else {lua_pushnil(L);}
  SWIG_arg++; %}

