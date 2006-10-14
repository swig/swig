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

%include <luatypemaps.swg>          /* The typemaps */
%include <luaruntime.swg>          /* The runtime stuff */

/* -----------------------------------------------------------------------------
 *                          constants typemaps
 * ----------------------------------------------------------------------------- */
// this basically adds to a table of constants
%typemap(consttab) int, unsigned int, short, unsigned short, long, unsigned long, unsigned char, signed char, bool, enum SWIGTYPE
       { SWIG_LUA_INT,     (char *)"$symname", (long) $value, 0, 0, 0}

%typemap(consttab) float, double
       { SWIG_LUA_FLOAT,   (char *)"$symname", 0, (double) $value, 0, 0}

%typemap(consttab) long long, unsigned long long, signed long long
       { SWIG_LUA_FLOAT,   (char *)"$symname", 0, (double) $value, 0, 0}

%typemap(consttab) const long long&, const unsigned long long&, const signed long long&
       { SWIG_LUA_FLOAT,   (char *)"$symname", 0, (double) *$value, 0, 0}

%typemap(consttab) char *, const char *, char [], const char []
       { SWIG_LUA_STRING,  (char *)"$symname", 0, 0, (void *)$value, 0}

// note: char is treated as a seperate special type
// signed char & unsigned char are numbers
%typemap(consttab) char
       { SWIG_LUA_CHAR,  (char *)"$symname", (long)$value, 0, 0, 0}

%typemap(consttab) long long, unsigned long long
       { SWIG_LUA_STRING, (char *) "$symname", 0, 0, (void *)"$value", 0}

%typemap(consttab) SWIGTYPE *, SWIGTYPE &, SWIGTYPE []
       { SWIG_LUA_POINTER, (char *)"$symname", 0, 0, (void *)$value, &$1_descriptor}


// TODO: not complete
//%typemap(consttab) SWIGTYPE (CLASS::*)
//       { SWIG_LUA_BINARY,  (char *)"$symname", sizeof($type), 0, (void *)&$value, &$1_descriptor}


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

On top of this I am not clear on how best to do this is Lua

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
%{lua_pushfstring(L,"numeric exception thrown of value %f",(double)$1);
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
/*	%typemap(throws) SWIGTYPE&
	{
	  SWIG_NewPointerObj(L,(void *) &$1,$&1_descriptor,1);
	  SWIG_fail;
	}*/
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



/* -----------------------------------------------------------------------------
 *                          extras
 * ----------------------------------------------------------------------------- */

/* ------------------------------ end lua.swg  ------------------------------ */
