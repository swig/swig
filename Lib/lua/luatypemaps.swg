/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * luatypemaps.swg
 *
 * basic typemaps for Lua.
 * ----------------------------------------------------------------------------- */

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

// size_t (which is just a unsigned long
%apply unsigned long { size_t };

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
%typemap(in,checkfn="lua_isstring") const char*, char*
%{$1 = ($ltype)lua_tostring(L, $input);%}

%typemap(in,checkfn="lua_isstring") const char[ANY], char[ANY]
%{$1 = ($ltype)lua_tostring(L, $input);%}

%typemap(out) const char*, char*
%{  lua_pushstring(L,(const char*)$1); SWIG_arg++;%}

%typemap(out) const char[ANY], char[ANY]
%{  lua_pushstring(L,(const char*)$1); SWIG_arg++;%}

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
// under SWIG rules, it is ok, to have a pass in a lua nil,
// it should be converted to a SWIG NULL.
// This will only be allowed for pointers & arrays, not refs or by value
// the checkfn lua_isuserdata will only work for userdata
// the checkfn SWIG_isptrtype will work for both userdata and nil's
%typemap(in,checkfn="SWIG_isptrtype") SWIGTYPE*,SWIGTYPE[]
%{
  if (!SWIG_IsOK(SWIG_ConvertPtr(L,$input,(void**)&$1,$descriptor,0))){
    SWIG_fail_ptr("$symname",$argnum,$descriptor);
  }
%}

%typemap(in,checkfn="lua_isuserdata") SWIGTYPE&
%{
  if (!SWIG_IsOK(SWIG_ConvertPtr(L,$input,(void**)&$1,$descriptor,0))){
    SWIG_fail_ptr("$symname",$argnum,$descriptor);
  }
%}

// out is simple
%typemap(out) SWIGTYPE*,SWIGTYPE&
%{SWIG_NewPointerObj(L,$1,$descriptor,$owner); SWIG_arg++; %}

// dynamic casts
// this uses the SWIG_TypeDynamicCast() which relies on RTTI to find out what the pointer really is
// the we return it as the correct type
%typemap(out) SWIGTYPE *DYNAMIC,
              SWIGTYPE &DYNAMIC
{
  swig_type_info *ty = SWIG_TypeDynamicCast($1_descriptor, (void **) &$1);
  SWIG_NewPointerObj(L,(void*)$1,ty,$owner); SWIG_arg++; 
}


// passing objects by value
// SWIG_ConvertPtr wants an object pointer (the $&ltype argp)
// then dereferences it to get the object
%typemap(in,checkfn="lua_isuserdata") SWIGTYPE ($&ltype argp)
%{
   if (!SWIG_IsOK(SWIG_ConvertPtr(L,$input,(void**)&argp,$&descriptor,0))){
     SWIG_fail_ptr("$symname",$argnum,$&descriptor);
   }
   $1 = *argp;
%}

// Primitive types--return by value
// must make a new object, copy the data & return the new object
// Note: the brackets are {...} and not %{..%}, because we want them to be included in the wrapper
// this is because typemap(out) does not support local variables, like in typemap(in) does
// and we need the $&1_ltype resultptr; to be declared
#ifdef __cplusplus
%typemap(out) SWIGTYPE
{
  $&1_ltype resultptr = new $1_ltype(($1_ltype &) $1);
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

// member function pointer
// a member fn ptr is not 4 bytes like a normal pointer, but 8 bytes 
// so the standard wrappering cannot be done
// nor can you cast a member function pointer to a void* (obviously)
#ifdef __cplusplus
%typemap(in,checkfn="lua_isuserdata") SWIGTYPE (CLASS::*)
%{
  if (!SWIG_IsOK(SWIG_ConvertMember(L,$input,(void*)(&$1),sizeof($type),$descriptor)))
    SWIG_fail_ptr("$symname",$argnum,$descriptor);
%}

%typemap(out) SWIGTYPE (CLASS::*)
%{ 
  SWIG_NewMemberObj(L,(void*)(&$1),sizeof($type),$descriptor); SWIG_arg++; 
%}
#endif


// void (must be empty without the SWIG_arg++)
%typemap(out) void "";

/* void* is a special case
A function void fn(void*) should take any kind of pointer as a parameter (just like C/C++ does)
but if its an output, then it should be wrappered like any other SWIG object (using default typemap)
*/
%typemap(in,checkfn="SWIG_isptrtype") void*
%{$1=($1_ltype)SWIG_MustGetPtr(L,$input,0,0,$argnum,"$symname");%}

/* long long is another special case:
as lua only supports one numeric type (lua_Number), we will just
cast it to that & accept the loss of precision.
An alternative solution would be a long long struct or class
with the relevant operators.
*/
%typemap(in,checkfn="lua_isnumber") long long, unsigned long long, signed long long
%{$1 = ($type)lua_tonumber(L, $input);%}

%typemap(out) long long, unsigned long long, signed long long
%{  lua_pushnumber(L, (lua_Number) $1); SWIG_arg++;%}

/* It is possible to also pass a lua_State* into a function, so
void fn(int a, float b, lua_State* s) is wrappable as
> fn(1,4.3) -- note: the state is implicitly passed in
*/
%typemap(in, numinputs=0) lua_State* 
%{$1 = L;%}

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
	 long long, unsigned long long, signed long long,
	 const int &, const short &, const long &,
 	 const unsigned int &, const unsigned short &, const unsigned long &,
	 const long long &, const unsigned long long &,
	 enum SWIGTYPE,	float, double,
	 const float &, const double&,
	 size_t,const size_t&
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

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE *, SWIGTYPE [] {
  void *ptr;
  if (SWIG_isptrtype(L,$input)==0 || SWIG_ConvertPtr(L,$input, (void **) &ptr, $1_descriptor, 0)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE & {
  void *ptr;
  if (lua_isuserdata(L,$input)==0 || SWIG_ConvertPtr(L,$input, (void **) &ptr, $1_descriptor, 0)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE {
  void *ptr;
  if (lua_isuserdata(L,$input)==0 || SWIG_ConvertPtr(L,$input, (void **) &ptr, $&1_descriptor, 0)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_VOIDPTR) void * {
  void *ptr;
  if (SWIG_isptrtype(L,$input)==0 || SWIG_ConvertPtr(L,$input, (void **) &ptr, 0, 0)) {
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
// %{  lua_pushnumber(L, (lua_Number) *$1); SWIG_arg++;%}
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
//SWIG_NUMBER_BY_CONST_REF(char);	// char's are small strings not numbers
SWIG_NUMBER_BY_CONST_REF(unsigned char);
SWIG_NUMBER_BY_CONST_REF(signed char);
SWIG_NUMBER_BY_CONST_REF(float);
SWIG_NUMBER_BY_CONST_REF(double);
SWIG_NUMBER_BY_CONST_REF(enum SWIGTYPE);
SWIG_NUMBER_BY_CONST_REF(long long);
SWIG_NUMBER_BY_CONST_REF(signed long long);
SWIG_NUMBER_BY_CONST_REF(unsigned long long);

%apply const unsigned long & { const size_t & };	// size_t is the same as unsigned long


// Also needed for object ptrs by const ref
// eg const A* ref_pointer(A* const& a);
// found in mixed_types.i

%typemap(in,checkfn="lua_isuserdata") SWIGTYPE* const &($*ltype temp)
%{temp=($*ltype)SWIG_MustGetPtr(L,$input,$*descriptor,0,$argnum,"$symname");
$1=&temp;%}
// and the typecheck code
%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE* const &
{
  void *ptr;
  if (lua_isuserdata(L,$input)==0 || SWIG_ConvertPtr(L,$input, (void **) &ptr, $*descriptor, 0)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}


/* -----------------------------------------------------------------------------
 *                          Specials
 * ----------------------------------------------------------------------------- */
// swig::LANGUAGE_OBJ was added to allow containers of native objects
// however its rather difficult to do this in lua, as you cannot hold pointers
// to native objects (they are held in the interpreter)
// therefore for now: just ignoring this feature
#ifdef __cplusplus
%ignore swig::LANGUAGE_OBJ;

%inline %{
namespace swig {
typedef struct{} LANGUAGE_OBJ;
//typedef void* LANGUAGE_OBJ;
}
%}

#endif // __cplusplus