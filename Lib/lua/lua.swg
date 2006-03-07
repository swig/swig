/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * lua.swg
 *
 * SWIG Configuration File for Lua.
 * This file is parsed by SWIG before reading any other interface file.
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 *                          includes
 * ----------------------------------------------------------------------------- */

%runtime "swigrun.swg";         /* Common C API type-checking code */
%runtime "luarun.swg";          /* Lua runtime stuff */

/* -----------------------------------------------------------------------------
 *                          standard typemaps
 * ----------------------------------------------------------------------------- */
/* NEW LANGUAGE NOTE:
   the 'checkfn' param is something that I added for typemap(in)
   it is an optional fn call to check the type of the lua object
   the fn call must be of the form
     int checkfn(lua_State *L, int index);
   and return 1/0 depending upon if this is the correct type
   For the typemap(out), an additional SWIG_arg parmeter must be incremented
   to reflect the number of values returned (normally SWIG_arg++; will do)
*/
// numbers
%typemap(in,checkfn="lua_isnumber") int,short,long,
             unsigned int,unsigned short,unsigned long,
             signed char,unsigned char,
             float,double
%{$1 = ($type)lua_tonumber(L, $input);%}

%typemap(out) int,short,long,
             unsigned int,unsigned short,unsigned long,
             signed char,unsigned char,
             float,double
%{  lua_pushnumber(L, (lua_Number) $1); SWIG_arg++;%}

/* enums have to be handled slightly differently
	VC++ .net will not allow a cast from double to enum directly
	therefore cast to an int first.
	Thanks to Jason Rego <JasonR@rainbowstudios.com> for finding this.
*/
%typemap(in,checkfn="lua_isnumber") enum SWIGTYPE
%{$1 = ($type)(int)lua_tonumber(L, $input);%}

%typemap(out) enum SWIGTYPE
%{  lua_pushnumber(L, (lua_Number)(int)($1)); SWIG_arg++;%}

// boolean (which is a special type in lua)
// note: 1 & 0 are not booleans in lua, only true & false
%typemap(in,checkfn="lua_isboolean") bool
%{$1 = (bool)lua_toboolean(L, $input);%}

%typemap(out) bool, const bool&
%{  lua_pushboolean(L,(int)$1); SWIG_arg++;%}

// for const bool&, SWIG treats this as a const bool* so we must dereference it
%typemap(in,checkfn="lua_isboolean") const bool& (bool temp)
%{temp=(bool)lua_toboolean(L, $input); $1=&temp;%}

%typemap(out) const bool&
%{  lua_pushboolean(L,(int)*$1); SWIG_arg++;%}

// strings (char* and char[])
%typemap(in,checkfn="lua_isstring") const char*, char*, const char[ANY], char[ANY]
%{$1 = (char*)lua_tostring(L, $input);%}

%typemap(out) const char*, char*, const char[ANY], char[ANY]
%{  lua_pushstring(L,$1); SWIG_arg++;%}

// char's
// currently treating chars as small strings, not as numbers
// (however signed & unsigned char's are numbers...)
%typemap(in,checkfn="lua_isstring") char
%{$1 = ((char*)lua_tostring(L, $input))[0];%}

%typemap(out) char
%{  lua_pushfstring(L,"%c",$1); SWIG_arg++;%}

// by const ref
%typemap(in,checkfn="lua_isstring") const char& (char temp)
%{temp = ((char*)lua_tostring(L, $input))[0]; $1=&temp;%}

%typemap(out) const char&
%{  lua_pushfstring(L,"%c",*$1); SWIG_arg++;%}

// pointers and references
%typemap(in,checkfn="lua_isuserdata") SWIGTYPE*,SWIGTYPE&,SWIGTYPE[]
%{$1=($1_ltype)SWIG_MustGetPtr(L,$input,$descriptor,0,$argnum,"$symname");%}

%typemap(out) SWIGTYPE*,SWIGTYPE&
%{SWIG_NewPointerObj(L,$1,$descriptor,$owner); SWIG_arg++; %}

// passing objects by value (yuk: do you really have to do this?)
// what we do is get it as a pointer (the $&ltype argp)
// then do an assignment
%typemap(in,checkfn="lua_isuserdata") SWIGTYPE
{
   $&ltype argp;
   if(SWIG_ConvertPtr(L,$input,(void**)(&argp),$&descriptor,0)) SWIG_fail;
   $1 = *argp;
}

// Primitive types--return by value
// must make a new object, copy the data & return the new object
#ifdef __cplusplus
%typemap(out) SWIGTYPE
{
  $&1_ltype resultptr;
  resultptr = new $1_ltype(($1_ltype &) $1);
  SWIG_NewPointerObj(L,(void *) resultptr,$&1_descriptor,1); SWIG_arg++;
}
#else
%typemap(out) SWIGTYPE
{
  $&1_ltype resultptr;
  resultptr = ($&1_ltype) malloc(sizeof($1_type));
  memmove(resultptr, &$1, sizeof($1_type));
  SWIG_NewPointerObj(L,(void *) resultptr,$&1_descriptor,1); SWIG_arg++;
}
#endif

// void (must be empty without the SWIG_arg++)
%typemap(out) void "";

/* void* is a special case
A function void fn(void*) should take any kind of pointer as a parameter (just like C/C++ does)
but if its an output, then it should be wrappered like any other SWIG object (using default typemap)
*/
%typemap(in,checkfn="lua_isuserdata") void*
%{$1=((swig_lua_userdata*)(lua_touserdata(L,$input)))->ptr;%}


/* -----------------------------------------------------------------------------
 *                          constants typemaps
 * ----------------------------------------------------------------------------- */
// this basically adds to a table of constants
%typemap(consttab) int, unsigned int, short, unsigned short, long, unsigned long, unsigned char, signed char, bool, enum SWIGTYPE
       { SWIG_LUA_INT,     (char *)"$symname", (long) $value, 0, 0, 0}

%typemap(consttab) float, double
       { SWIG_LUA_FLOAT,   (char *)"$symname", 0, (double) $value, 0, 0}

%typemap(consttab) char, char *
       { SWIG_LUA_STRING,  (char *)"$symname", 0, 0, (void *)"$value", 0}

%typemap(consttab) long long, unsigned long long
       { SWIG_LUA_STRING, (char *) "$symname", 0, 0, (void *)"$value", 0}

%typemap(consttab) SWIGTYPE *, SWIGTYPE &, SWIGTYPE []
       { SWIG_LUA_POINTER, (char *)"$symname", 0, 0, (void *)$value, &$1_descriptor}

// TODO: not complete
//%typemap(consttab) SWIGTYPE (CLASS::*)
//       { SWIG_LUA_BINARY,  (char *)"$symname", sizeof($type), 0, (void *)&$value, &$1_descriptor}


/* -----------------------------------------------------------------------------
 *                          typecheck rules
 * ----------------------------------------------------------------------------- */
/* These are needed for the overloaded functions
These define the detection routines which will spot what
parmeters match which function
*/

// unfortunately lua only considers one type of number
// so all numbers (int,float,double) match
// you could add an advanced fn to get type & check if its integral
%typecheck(SWIG_TYPECHECK_INTEGER)
	 int, short, long,
 	 unsigned int, unsigned short, unsigned long,
	 signed char, unsigned char,
	 long long, unsigned long long,
	 const int &, const short &, const long &,
 	 const unsigned int &, const unsigned short &, const unsigned long &,
	 const long long &, const unsigned long long &,
	 enum SWIGTYPE,	float, double,
	 const float &, const double &
{
  $1 = lua_isnumber(L,$input);
}

%typecheck(SWIG_TYPECHECK_BOOL)
    bool, const bool &
{
  $1 = lua_isboolean(L,$input);
}

// special check for a char (string of length 1)
%typecheck(SWIG_TYPECHECK_CHAR) char {
  $1 = lua_isstring(L,$input) && (lua_strlen(L,$input)==1);
}

%typecheck(SWIG_TYPECHECK_STRING) char * {
  $1 = lua_isstring(L,$input);
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] {
  void *ptr;
  if (lua_isuserdata(L,$input)==0 || SWIG_ConvertPtr(L,$input, (void **) &ptr, $1_descriptor, 0)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_VOIDPTR) void * {
  void *ptr;
  if (lua_isuserdata(L,$input)==0 || SWIG_ConvertPtr(L,$input, (void **) &ptr, 0, 0)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

/* -----------------------------------------------------------------------------
 *                          Const reference issues
 * ----------------------------------------------------------------------------- */
// additional typemaps for privitives by const reference:
// given a function:
//	int intbyref(const int& i);
// SWIG assumes that this code will need a pointer to int to be passed in
// (this might be ok for passing objects by const ref, but not a primitive)
// therefore we add a set of blanket typemaps to fix this
// also a set for fns which return const X&

// %typemap(in,checkfn="lua_isnumber") const int &(int temp)
// %{ temp = (int)lua_tonumber(L,$input); $1=&temp;%}
// %typemap(out) const int&
// %{  lua_pushnumber(L, (double) $*1); SWIG_arg++;%}
// %typecheck(in,checkfn="lua_isnumber") const int &

// now the code
%define SWIG_NUMBER_BY_CONST_REF(TYPE)
%typemap(in,checkfn="lua_isnumber") const TYPE &($basetype temp)
%{ temp=($basetype)lua_tonumber(L,$input); $1=&temp;%}
%typemap(out) const TYPE&
%{  lua_pushnumber(L, (lua_Number) *$1); SWIG_arg++;%}
%enddef

SWIG_NUMBER_BY_CONST_REF(int);
SWIG_NUMBER_BY_CONST_REF(unsigned int);
SWIG_NUMBER_BY_CONST_REF(signed int);
SWIG_NUMBER_BY_CONST_REF(short);
SWIG_NUMBER_BY_CONST_REF(unsigned short);
SWIG_NUMBER_BY_CONST_REF(signed short);
SWIG_NUMBER_BY_CONST_REF(long);
SWIG_NUMBER_BY_CONST_REF(unsigned long);
SWIG_NUMBER_BY_CONST_REF(signed long);
//SWIG_NUMBER_BY_CONST_REF(char);	// char's are now small strings
SWIG_NUMBER_BY_CONST_REF(unsigned char);
SWIG_NUMBER_BY_CONST_REF(signed char);
SWIG_NUMBER_BY_CONST_REF(float);
SWIG_NUMBER_BY_CONST_REF(double);
SWIG_NUMBER_BY_CONST_REF(enum SWIGTYPE);


// Also needed for object ptrs by const ref
// eg const A* ref_pointer(A* const& a);
// found in mixed_types.i

%typemap(in,checkfn="lua_isuserdata") SWIGTYPE* const &($*ltype temp)
%{temp=($*ltype)SWIG_MustGetPtr(L,$input,$*descriptor,0,$argnum,"$symname");
$1=&temp;%}
// and the typecheck code
%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE* const &
%{
  void *ptr;
  if (lua_isuserdata(L,$input)==0 || SWIG_ConvertPtr(L,$input, (void **) &ptr, $*descriptor, 0)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
%}


/* -----------------------------------------------------------------------------
 *                          Overloaded operator support
 * ----------------------------------------------------------------------------- */
// lua likes to call the + operator '__add'
// python likes to call it '__add__'
// Assuming most SWIGers will probably use the __add__ if they extend their classes
// we have two sets of renames
// one to rename the operator+() to __add()
//	(this lets SWIG rename the operator overloads)
// another is to rename __add__() to __add()
//	(this means that people who wrote SWIG code to do that add will also work)

#ifdef __cplusplus
// this is extra renaming for lua
// not all operators are supported, so only those that are, are listed


/* Ignored operators */
%ignorewarn("362:operator= ignored") operator=;
%ignorewarn("362:operator% ignored") operator%;
%ignorewarn("383:operator++ ignored") operator++;
%ignorewarn("384:operator-- ignored") operator--;
%ignorewarn("361:operator! ignored") operator!;
%ignorewarn("381:operator&& ignored") operator&&;
%ignorewarn("382:operator|| ignored") operator||;
%ignorewarn("386:operator->* ignored") operator->*;
%ignorewarn("362:operator+= ignored") operator+=;
%ignorewarn("362:operator-= ignored") operator-=;
%ignorewarn("362:operator*= ignored") operator*=;
%ignorewarn("362:operator/= ignored") operator/=;
%ignorewarn("362:operator%= ignored") operator%=;
%ignorewarn("389:operator[] ignored (consider using %extend)") operator[];

// renaming the main C++ operators
%rename(__add)			*::operator+;
%rename(__sub)			*::operator-;
%rename(__mul)			*::operator*;
%rename(__div)			*::operator/;
%rename(__unm)      *::operator-();
%rename(__unm)      *::operator-() const;

%rename(__eq)			*::operator==;	// note: Lua does not have a not equal
						// it just uses 'not (a==b)'
%ignore *::operator!=;
%rename(__lt)			*::operator<;	// ditto less than vs greater than
%ignore *::operator>;
%rename(__le)			*::operator<=;	// ditto less than vs greater than
%ignore *::operator>=;

%rename(__call)			*::operator();	// the fn call operator



// renaming the python operators to be compatible with lua
// this means that if a developer has written a fn __add__()
// it will be used for the lua +
%rename(__add)			*::__add__;
%rename(__sub)			*::__sub__;
%rename(__mul)			*::__mul__;
%rename(__div)			*::__div__;
%rename(__unm)			*::__neg__;		// lua calls unary minus,'unm' not 'neg'
%rename(__tostring)		*::__str__;		// both map to __tostring
%rename(__tostring)		*::__repr__;	// both map to __tostring


%rename(__pow)			*::__pow__;		// lua power '^' operator
%rename(__concat)		*::__concat__;  // lua concat '..' operator
%rename(__eq)			*::__eq__;
%rename(__lt)			*::__lt__;
%rename(__le)			*::__le__;
%rename(__call)			*::__call__;	// the fn call operator()

// the [] operator has two parts, the get & the set
%rename(__getitem)			*::__getitem__;	// the v=X[i] (get operator)
%rename(__setitem)			*::__setitem__;	// the X[i]=v (set operator)


#endif


/* ------------------------------------------------------------
 *                              Exceptions
 * ------------------------------------------------------------ */
/* Confession: I dont really like C++ exceptions
The python ones are great, but C++ ones I dont like
(mainly because I cannot get the stack trace out of it)
Therefore I have not bothered to try doing much in this

On top of this I an not clear on how best to do this is Lua

Therefore currently its just enough to get a few test cases running ok

note: if you wish to throw anything related to std::exception
use %include <std_except.i> instead
*/
%typemap(throws) int,unsigned int,signed int,
				long,unsigned long,signed long,
				short,unsigned short,signed short,
				bool,float,double,
				long long,unsigned long long,
				char, unsigned char, signed char,
				enum SWIGTYPE
%{lua_pushfstring(L,"exception thrown of value %f",(double)$1);
SWIG_fail; %}

// strings are just sent as errors
%typemap(throws) char*, const char*
%{lua_pushstring(L,$1);SWIG_fail;%}

// anything else is sent as an object
#ifdef __cplusplus
	%typemap(throws) SWIGTYPE
	{
	  $&1_ltype resultptr;
	  resultptr = new $1_ltype(($1_ltype &) $1);
	  SWIG_NewPointerObj(L,(void *) resultptr,$&1_descriptor,1);
	  SWIG_fail;
	}
#else
	%typemap(throws) SWIGTYPE
	{
	  $&1_ltype resultptr;
	  resultptr = ($&1_ltype) malloc(sizeof($1_type));
	  memmove(resultptr, &$1, sizeof($1_type));
	  SWIG_NewPointerObj(L,(void *) resultptr,$&1_descriptor,1);
	  SWIG_fail;
	}
#endif


/* ------------------------------------------------------------
 *                              SWIG_init
 * ------------------------------------------------------------ */
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


/*************************** end lua.swg ******************************/
