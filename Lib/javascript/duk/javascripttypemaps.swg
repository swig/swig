/* -----------------------------------------------------------------------------
 * javascripttypemaps.swg
 *
 * basic typemaps for Duktape.
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 *                          standard typemaps
 * ----------------------------------------------------------------------------- */
/* NEW LANGUAGE NOTE:
   the 'checkfn' param is something that I added for typemap(in)
   it is an optional fn call to check the type of the lua object
   the fn call must be of the form
     int checkfn(lua_State *ctx, int index);
   and return 1/0 depending upon if this is the correct type
   For the typemap(out), an additional SWIG_arg parameter must be incremented
   to reflect the number of values returned (normally SWIG_arg++; will do)
//FIXME FIXME FIXME
*/
// numbers
%typemap(in,checkfn="duk_is_number") int, short, long,
             signed char, float, double
%{$1 = ($type)duk_to_number(ctx, $input);%}
 
// additional check for unsigned numbers, to not permit negative input
%typemap(in,checkfn="duk_is_number") unsigned int,
             unsigned short, unsigned long, unsigned char
%{SWIG_contract_assert((duk_to_number(ctx, $input)>=0),"number must not be negative")
$1 = ($type)duk_to_number(ctx, $input);%}

%typemap(out) int,short,long,
             unsigned int,unsigned short,unsigned long,
             signed char,unsigned char,
             float,double
%{ duk_push_number(ctx, (duk_double_t) $1); %}

// we must also provide typemaps for primitives by const reference:
// given a function:
//	int intbyref(const int& i);
// SWIG assumes that this code will need a pointer to int to be passed in
// (this might be ok for objects by const ref, but not for numeric primitives)
// therefore we add a set of typemaps to fix this (for both in & out)
%typemap(in,checkfn="duk_is_number") const int&($basetype temp)
%{ temp=($basetype)duk_to_number(ctx, $input); $1=&temp;%}

%typemap(in,checkfn="duk_is_number") const unsigned int&($basetype temp)
%{SWIG_contract_assert((duk_to_number(ctx,$input)>=0),"number must not be negative")
temp=($basetype)duk_to_number(ctx,$input); $1=&temp;%}

%typemap(out) const int&, const unsigned int&
%{duk_push_number(ctx, (duk_double_t) *$1); %}

// for the other numbers we can just use an apply statement to cover them
%apply const int & {const short&,const long&,const signed char&,
             const float&,const double&};

%apply const unsigned int & {const unsigned short&,const unsigned long&,
             const unsigned char&};

/* enums have to be handled slightly differently
	VC++ .net will not allow a cast from lua_Number(double) to enum directly.
*/
%typemap(in,checkfn="duk_is_number") enum SWIGTYPE
%{$1 = ($type)(int)duk_to_number(ctx, $input);%}

%typemap(out) enum SWIGTYPE
%{duk_push_number(ctx, (duk_double_t)($1)); %}

// and const refs
%typemap(in,checkfn="duk_is_number") const enum SWIGTYPE &($basetype temp)
%{ temp=($basetype)(int)duk_to_number(ctx, $input); $1=&temp;%}
%typemap(in,checkfn="duk_is_number") const enum SWIGTYPE &&($basetype temp)
%{ temp=($basetype)(int)duk_to_number(ctx,$input); $1=&temp;%}
%typemap(out) const enum SWIGTYPE &
%{  duk_push_number(ctx, (duk_double_t) *$1); %}
%typemap(out) const enum SWIGTYPE &&
%{  duk_push_number(ctx, (duk_double_t) *$1); %}


// boolean
%typemap(in,checkfn="duk_is_boolean") bool
%{$1 = (duk_to_boolean(ctx, $input)!=0);%}

%typemap(out) bool
%{  duk_push_boolean(ctx,(int)($1!=0)); %}

// for const bool&, SWIG treats this as a const bool* so we must dereference it
%typemap(in,checkfn="duk_is_boolean") const bool& (bool temp)
%{temp=(duk_to_boolean(ctx, $input)!=0);
  $1=&temp;%}

%typemap(out) const bool&
%{duk_push_boolean(ctx,(int)((*$1)!=0)); %}

// strings (char * and char[])
%fragment("SWIG_duk_isnilstring", "header") {
SWIGINTERN int SWIG_duk_isnilstring(duk_context *ctx, duk_idx_t idx) {
  int ret = duk_is_string(ctx, idx);
  if (!ret)
   ret = duk_is_null_or_undefined(ctx, idx);
  return ret;
}
}

%typemap(in,checkfn="SWIG_duk_isnilstring",fragment="SWIG_duk_isnilstring") const char *, char *
%{$1 = ($ltype)duk_to_string(ctx, $input);%}

%typemap(in,checkfn="SWIG_duk_isnilstring",fragment="SWIG_duk_isnilstring") const char[ANY], char[ANY]
%{$1 = ($ltype)duk_to_string(ctx, $input);%}

%typemap(out) const char *, char *
%{duk_push_string(ctx,(const char *)$1); %}

%typemap(out) const char[ANY], char[ANY]
%{duk_push_string(ctx,(const char *)$1); %}

// char's
// currently treating chars as small strings, not as numbers
// (however signed & unsigned char's are numbers...)
%typemap(in,checkfn="SWIG_duk_isnilstring",fragment="SWIG_duk_isnilstring") char
%{$1 = (duk_to_string(ctx, $input))[0];%}

%typemap(out) char
%{
  const char *str = "$1";
  int len = strlen(str)-2;
  char tmp[len];
  int j = 0;
  for(int i = 1; i < len+1;i++) {
    tmp[j] = str[i];
    j++;
  }
  tmp[j] = '\0';
  str = (const char *)tmp;
  duk_push_string(ctx, str);
%}

// by const ref
%typemap(in,checkfn="SWIG_duk_isnilstring",fragment="SWIG_duk_isnilstring") const char& (char temp)
%{temp = (duk_to_string(ctx, $input))[0]; $1=&temp;%}

%typemap(out) const char&
%{duk_push_lstring(ctx, $1, 1); %}

// pointers and references
// under SWIG rules, it is ok, to have a pass in a JS Undefined.
// it should be converted to a SWIG NULL.
// This will only be allowed for pointers & arrays, not refs or by value
// the checkfn duk_is_heapptr will only work for userdata
// the checkfn SWIG_isptrtype will work for both userdata and nil
%typemap(in,checkfn="SWIG_isptrtype") SWIGTYPE*,SWIGTYPE[]
%{
  /* LINE 153 */
  if (!SWIG_IsOK(SWIG_ConvertPtr(ctx,$argnum,(void**)&$1,$descriptor,$disown))){
    SWIG_fail_ptr("$symname",$argnum,$descriptor);
  }
%}

// out is simple
%typemap(out) SWIGTYPE*,SWIGTYPE&
%{SWIG_NewPointerObj(ctx,$1,$descriptor,$owner);  %}
%typemap(out) SWIGTYPE*,SWIGTYPE&&
%{SWIG_NewPointerObj(ctx,$1,$descriptor,$owner);  %}

// passing objects by value
// SWIG_ConvertPtr wants an object pointer (the $&ltype argp)
// then dereferences it to get the object
%typemap(in,checkfn="duk_is_heapptr") SWIGTYPE ($&ltype argp)
%{
  /* LINE 170 */
#ifdef SWIGRUNTIME_DEBUG
  printf("magic $input 002\n");
#endif
  void *thisVal$argnum = duk_get_heapptr(ctx, $input);
  if (!SWIG_IsOK(SWIG_ConvertPtr(ctx,thisVal$argnum,(void**)&argp,$&descriptor,0))){
    SWIG_fail_ptr("$symname",$argnum,$&descriptor);
  }
  $1 = *argp;
%}

// Also needed for object ptrs by const ref
// eg A* const& ref_pointer(A* const& a);
// found in mixed_types.i
%typemap(in,checkfn="duk_is_heapptr") SWIGTYPE *const&($*ltype temp)
%{temp=($*ltype)SWIG_MustGetPtr(ctx,$input,$*descriptor,0,$argnum,"$symname");
$1=($1_ltype)&temp;%}

%typemap(out) SWIGTYPE *const&
%{SWIG_NewPointerObj(ctx,*$1,$*descriptor,$owner);  %}


// DISOWN-ing typemaps
// if you have an object pointer which must be disowned, use this typemap
// eg. for void destroy_foo(Foo* toDie);
// use %apply SWIGTYPE* DISOWN {Foo* toDie};
// you could just use %delobject, but this is more flexible
%typemap(in,checkfn="SWIG_isptrtype") SWIGTYPE* DISOWN,SWIGTYPE DISOWN[]
%{
  /* LINE 196 */
#ifdef SWIGRUNTIME_DEBUG
  printf("magic $input 005\n");
#endif
  if (!SWIG_IsOK(SWIG_ConvertPtr(ctx,$input,(void**)&$1,$descriptor,SWIG_POINTER_DISOWN))){
    SWIG_fail_ptr("$symname",$argnum,$descriptor);
  }
%}


// Primitive types--return by value
// must make a new object, copy the data & return the new object
// Note: the brackets are {...} and not %{..%}, because we want them to be included in the wrapper
// this is because typemap(out) does not support local variables, like in typemap(in) does
// and we need the $&1_ltype resultptr; to be declared
#ifdef __cplusplus
%typemap(out) SWIGTYPE
{
  $&1_ltype resultptr = new $1_ltype((const $1_ltype &) $1);
  SWIG_NewPointerObj(ctx,(void *) resultptr,$&1_descriptor,1); 
}
#else
%typemap(out) SWIGTYPE
{
  $&1_ltype resultptr;
  resultptr = ($&1_ltype) malloc(sizeof($1_type));
  memmove(resultptr, &$1, sizeof($1_type));
  SWIG_NewPointerObj(ctx,(void *) resultptr,$&1_descriptor,1); 
}
#endif

// member function pointer
// a member fn ptr is not 4 bytes like a normal pointer, but 8 bytes (at least on mingw)
// so the standard wrapping cannot be done
// nor can you cast a member function pointer to a void* (obviously)
// therefore a special wrapping functions SWIG_ConvertMember() & SWIG_NewMemberObj() were written
#ifdef __cplusplus
%typemap(in,checkfn="duk_is_heapptr") SWIGTYPE (CLASS::*)
%{
#ifdef SWIGRUNTIME_DEBUG
  printf("magic $input 004\n");
#endif
  if (!SWIG_IsOK(SWIG_ConvertMember(ctx,$input,(void*)(&$1),sizeof($type),$descriptor)))
    SWIG_fail_ptr("$symname",$argnum,$descriptor);
%}

%typemap(out) SWIGTYPE (CLASS::*)
%{ 
  SWIG_NewMemberObj(ctx,(void*)(&$1),sizeof($type),$descriptor);  
%}
#endif


// void (must be empty without the SWIG_arg++)
%typemap(out) void "";

/* void* is a special case
A function void fn(void*) should take any kind of pointer as a parameter (just like C/C++ does)
but if its an output, then it should be wrapped like any other SWIG object (using default typemap)
*/
%typemap(in,checkfn="SWIG_isptrtype") void*
%{$1=($1_ltype)SWIG_MustGetPtr(ctx,$input,0,0,$argnum,"$symname");%}

/* long long is another special case:
as Duktape only supports one numeric type (duk_double_t), we will just cast it
*/
%apply long {long long, signed long long, unsigned long long};
%apply const long& {const long long&, const signed long long&, const unsigned long long&};

/* It is possible to also pass a duk_context* into a function, so
void fn(int a, float b, duk_context* s) is wrappable as
> fn(1,4.3) -- note: the state is implicitly passed in
*/
%typemap(in, numinputs=0) duk_context* 
%{$1 = ctx;%}



/* -----------------------------------------------------------------------------
 *                          typecheck rules
 * ----------------------------------------------------------------------------- */
/* These are needed for the overloaded functions
These define the detection routines which will spot what
parameters match which function
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
	const signed char&, const unsigned char&,
	const long long &, const unsigned long long &,
	enum SWIGTYPE, const enum SWIGTYPE&, const enum SWIGTYPE &&,
	float, double, const float &, const double&
{
  $1 = duk_is_number(ctx,$input);
}

%typecheck(SWIG_TYPECHECK_BOOL)
    bool, const bool &
{
  $1 = duk_is_boolean(ctx,$input);
}

// special check for a char (string of length 1)
%typecheck(SWIG_TYPECHECK_CHAR,fragment="SWIG_duk_isnilstring") char, const char& {
  $1 = SWIG_duk_isnilstring(ctx,$input) && (lua_rawlen(ctx,$input)==1);
}

%typecheck(SWIG_TYPECHECK_STRING,fragment="SWIG_duk_isnilstring") char *, char[] {
  $1 = SWIG_duk_isnilstring(ctx,$input);
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE *, SWIGTYPE [] {
  void *ptr;
  if (SWIG_isptrtype(ctx,$input)==0 || SWIG_ConvertPtr(ctx,$input, (void **) &ptr, $1_descriptor, 0)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE & {
  void *ptr;
  if (duk_is_heapptr(ctx,$input)==0 || SWIG_ConvertPtr(ctx,$input, (void **) &ptr, $1_descriptor, 0)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE && {
  void *ptr;
  if (duk_is_heapptr(ctx,$input)==0 || SWIG_ConvertPtr(ctx,$input, (void **) &ptr, $1_descriptor, 0)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE {
  void *ptr;
  if (duk_is_heapptr(ctx,$input)==0 || SWIG_ConvertPtr(ctx,$input, (void **) &ptr, $&1_descriptor, 0)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_VOIDPTR) void * {
  void *ptr;
  if (SWIG_isptrtype(ctx,$input)==0 || SWIG_ConvertPtr(ctx,$input, (void **) &ptr, 0, 0)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

// Also needed for object pointers by const ref
// eg const A* ref_pointer(A* const& a);
// found in mixed_types.i
%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE *const&
{
  void *ptr;
  if (duk_is_heapptr(ctx,$input)==0 || SWIG_ConvertPtr(ctx,$input, (void **) &ptr, $*descriptor, 0)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

/* -----------------------------------------------------------------------------
 *                          Others
 * ----------------------------------------------------------------------------- */

// Array reference typemaps
%apply SWIGTYPE & { SWIGTYPE ((&)[ANY]) }
%apply SWIGTYPE && { SWIGTYPE ((&&)[ANY]) }

/* const pointers */
%apply SWIGTYPE * { SWIGTYPE *const }

// size_t (which is just a unsigned long)
%apply unsigned long { size_t };
%apply const unsigned long & { const size_t & };


/* -----------------------------------------------------------------------------
 *                          Specials
 * ----------------------------------------------------------------------------- */
// swig::LANGUAGE_OBJ was added to allow containers of native objects
// however its rather difficult to do this in Duktape, as you cant
// pin native objects (they are held in the interpreter)
// therefore for now: just ignoring this feature. However, Duktape 2.x might
// make it much more tenable.
#ifdef __cplusplus
%ignore swig::LANGUAGE_OBJ;

//%inline %{
%{
namespace swig {
typedef struct{} LANGUAGE_OBJ;
}
%}

#endif // __cplusplus
