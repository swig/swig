/* -----------------------------------------------------------------------------
 * swig.swg
 *
 * $Header$
 *
 * Common macro definitions for various SWIG directives.  This file is always 
 * included at the top of each input file.
 * ----------------------------------------------------------------------------- */

/* Deprecated SWIG directives */

#define %disabledoc     %warn "104:%disabledoc is deprecated"
#define %enabledoc      %warn "105:%enabledoc is deprecated"
#define %doconly        %warn "106:%doconly is deprecated"
#define %style          %warn "107:%style is deprecated" /##/
#define %localstyle     %warn "108:%localstyle is deprecated" /##/
#define %title          %warn "109:%title is deprecated" /##/
#define %section        %warn "110:%section is deprecated" /##/
#define %subsection     %warn "111:%subsection is deprecated" /##/
#define %subsubsection  %warn "112:%subsubsection is deprecated" /##/
#define %new            %warn "117:%new is deprecated. Use %newobject"
#define %text           %insert("null")

/* Code insertion directives such as %wrapper %{ ... %} */

#define %init        %insert("init")
#define %wrapper     %insert("wrapper")
#define %header      %insert("header")
#define %runtime     %insert("runtime")

/* Class extension */

#define %addmethods  %warn "113:%addmethods is now %extend" %extend

/* %ignore directive */

#define %ignore         %rename($ignore)
#define %ignorewarn(x)  %rename("$ignore:" x)

/* Access control directives */

#define %readonly    %warn "114:%readonly is deprecated. Use %immutable; " %feature("immutable");
#define %readwrite   %warn "115:%readwrite is deprecated. Use %mutable; " %feature("immutable","");

#define %immutable       %feature("immutable")
#define %noimmutable     %feature("immutable","0")
#define %clearimmutable  %feature("immutable","")
#define %mutable         %clearimmutable

/* Generation of default constructors/destructors */

#define %nodefault       %feature("nodefault","1")
#define %default         %feature("nodefault","0")
#define %clearnodefault  %feature("nodefault","")
#define %makedefault     %cleardefault

/* the %exception directive */

#ifdef SWIGCSHARP
#define %exception      %feature("except", canthrow=1)
#else
#define %exception      %feature("except")
#endif
#define %noexception    %feature("except","0")
#define %clearexception %feature("except","")

/* the %exceptionclass directive */

#define %exceptionclass      %feature("exceptionclass")
#define %noexceptionclass    %feature("exceptionclass","0")
#define %clearexceptionclass %feature("exceptionclass","")

/* the %newobject directive */

#define %newobject        %feature("new")
#define %nonewobject      %feature("new","0")
#define %clearnewobject   %feature("new","")

/* the %refobject/%unrefobject directives */

#define %refobject         %feature("ref")
#define %norefobject       %feature("ref","0")
#define %clearrefobject    %feature("ref","")

#define %unrefobject       %feature("unref")
#define %nounrefobject     %feature("unref","0")
#define %clearunrefobject  %feature("unref","")

/* Directives for callback functions (experimental) */

#define %callback(x)    %feature("callback",`x`)
#define %nocallback     %feature("callback","0")
#define %clearcallback  %feature("callback","")


/* Common features */

/* Warnings */
#define %warnfilter(...) %feature("warnfilter",`__VA_ARGS__`)

/* Warnings used in typemaps. Macro names are the same as those in swigwarn.h but prefixed by SWIG_. */
%define SWIG_WARN_TYPEMAP_THREAD_UNSAFE "470:Thread/reentrant unsafe wrapping, consider returning by value instead." %enddef

/* Contract support - Experimental and undocumented */

#define %contract    %feature("contract")

/* Default handling of certain overloaded operators */

#ifdef __cplusplus
%ignorewarn("350:operator new ignored")     operator new;
%ignorewarn("351:operator delete ignored")  operator delete;
%ignorewarn("394:operator new[] ignored")   operator new[];
%ignorewarn("395:operator delete[] ignored") operator delete[];

/* Smart pointer handling */

%rename(__deref__) *::operator->;
%rename(__ref__) *::operator*();
%rename(__ref__) *::operator*() const;

/* Define std namespace */
namespace std {
}
#endif

/* Set up the typemap for handling new return strings */

#ifdef __cplusplus
%typemap(newfree) char * "delete [] $1;";
#else
%typemap(newfree) char * "free($1);";
#endif

/* Default typemap for handling char * members */

#ifdef __cplusplus
%typemap(memberin) char * {
  if ($1) delete [] $1;
  if ($input) {
     $1 = ($1_type) (new char[strlen($input)+1]);
     strcpy((char *) $1,$input);
  } else {
     $1 = 0;
  }
}
%typemap(memberin,warning="451:Setting const char * member may leak memory.") const char * {
  if ($input) {
     $1 = ($1_type) (new char[strlen($input)+1]);
     strcpy((char *) $1,$input);
  } else {
     $1 = 0;
  }
}
%typemap(globalin) char * {
  if ($1) delete [] $1;
  if ($input) {
     $1 = ($1_type) (new char[strlen($input)+1]);
     strcpy((char *) $1,$input);
  } else {
     $1 = 0;
  }
}
%typemap(globalin,warning="451:Setting const char * variable may leak memory.") const char * {
  if ($input) {
     $1 = ($1_type) (new char[strlen($input)+1]);
     strcpy((char *) $1,$input);
  } else {
     $1 = 0;
  }
}
#else
%typemap(memberin) char * {
  if ($1) free((char*)$1);
  if ($input) {
     $1 = ($1_type) malloc(strlen($input)+1);
     strcpy((char*)$1,$input);
  } else {
     $1 = 0;
  }
}
%typemap(memberin,warning="451:Setting const char * member may leak memory.") const char * {
  if ($input) {
     $1 = ($1_type) malloc(strlen($input)+1);
     strcpy((char*)$1,$input);
  } else {
     $1 = 0;
  }
}
%typemap(globalin) char * {
  if ($1) free((char*)$1);
  if ($input) {
     $1 = ($1_type) malloc(strlen($input)+1);
     strcpy((char*)$1,$input);
  } else {
     $1 = 0;
  }
}
%typemap(globalin,warning="451:Setting const char * variable may leak memory.") const char * {
  if ($input) {
     $1 = ($1_type) malloc(strlen($input)+1);
     strcpy((char*)$1,$input);
  } else {
     $1 = 0;
  }
}

#endif

/* Character array handling */

%typemap(memberin) char [ANY] {
  if ($input) strncpy($1,$input,$1_dim0);
  else $1[0] = 0;
}

%typemap(globalin) char [ANY] {
  if ($input) strncpy($1,$input,$1_dim0);
  else $1[0] = 0;
}

%typemap(memberin) char [] {
  if ($input) strcpy($1,$input);
  else $1[0] = 0;
}

%typemap(globalin) char [] {
  if ($input) strcpy($1,$input);
  else $1[0] = 0;
}

/* memberin/globalin typemap for arrays. */

%typemap(memberin) SWIGTYPE [ANY] {
  size_t ii;
  $1_basetype *b = ($1_basetype *) $1;
  for (ii = 0; ii < (size_t)$1_size; ii++) b[ii] = *(($1_basetype *) $input + ii);
}

%typemap(globalin) SWIGTYPE [ANY] {
  size_t ii;
  $1_basetype *b = ($1_basetype *) $1;
  for (ii = 0; ii < (size_t)$1_size; ii++) b[ii] = *(($1_basetype *) $input + ii);
}

/* memberin/globalin typemap for double arrays. */

%typemap(memberin) SWIGTYPE [ANY][ANY] {
  $basetype (*inp)[$dim1] = ($basetype (*)[$dim1])($input);
  $basetype (*dest)[$dim1] = ($basetype (*)[$dim1])($1);
  size_t ii = 0;
  for (; ii < $dim0; ++ii) {
    $basetype *ip = inp[ii];
    $basetype *dp = dest[ii];
    size_t jj = 0;
    for (; jj < $dim1; ++jj) dp[jj] = ip[jj];
  }
}

%typemap(globalin) SWIGTYPE [ANY][ANY] {
  $basetype (*inp)[$dim1] = ($basetype (*)[$dim1])($input);
  $basetype (*dest)[$dim1] = ($basetype (*)[$dim1])($1);
  size_t ii = 0;
  for (; ii < $dim0; ++ii) {
    $basetype *ip = inp[ii];
    $basetype *dp = dest[ii];
    size_t jj = 0;
    for (; jj < $dim1; ++jj) dp[jj] = ip[jj];
  }
}

/* Typemap for variable length arguments sentinel value.  Used
   by the %varargs directive. */

%typemap(in,numinputs=0) SWIGTYPE *VARARGS_SENTINEL, SWIGTYPE VARARGS_SENTINEL "";


/*
 * Function/method overloading support.   This is done through typemaps,
 * but also involve a precedence level. 
 */

/* Macro for overload resolution */

%define %typecheck(_x, _opt...) 
#if #_opt != ""
%typemap(typecheck, precedence=_x, _opt)
#else
%typemap(typecheck, precedence=_x)
#endif
%enddef

/* Macros for precedence levels */

%define SWIG_TYPECHECK_POINTER       0     %enddef
%define SWIG_TYPECHECK_VOIDPTR       10    %enddef
%define SWIG_TYPECHECK_BOOL          15    %enddef
%define SWIG_TYPECHECK_UINT8         20    %enddef
%define SWIG_TYPECHECK_INT8          25    %enddef
%define SWIG_TYPECHECK_UINT16        30    %enddef
%define SWIG_TYPECHECK_INT16         35    %enddef
%define SWIG_TYPECHECK_UINT32        40    %enddef
%define SWIG_TYPECHECK_INT32         45    %enddef
%define SWIG_TYPECHECK_UINT64        50    %enddef
%define SWIG_TYPECHECK_INT64         55    %enddef
%define SWIG_TYPECHECK_UINT128       60    %enddef
%define SWIG_TYPECHECK_INT128        65    %enddef
%define SWIG_TYPECHECK_INTEGER       70    %enddef
%define SWIG_TYPECHECK_FLOAT         80    %enddef
%define SWIG_TYPECHECK_DOUBLE        90    %enddef
%define SWIG_TYPECHECK_CPLXFLT       95    %enddef
%define SWIG_TYPECHECK_CPLXDBL      100    %enddef
%define SWIG_TYPECHECK_COMPLEX      105    %enddef
%define SWIG_TYPECHECK_UNICHAR      110    %enddef
%define SWIG_TYPECHECK_UNISTRING    120    %enddef
%define SWIG_TYPECHECK_CHAR         130    %enddef
%define SWIG_TYPECHECK_STRING       140    %enddef
%define SWIG_TYPECHECK_PAIR         150    %enddef
%define SWIG_TYPECHECK_VECTOR       160    %enddef
%define SWIG_TYPECHECK_DEQUE        170    %enddef
%define SWIG_TYPECHECK_LIST         180    %enddef
%define SWIG_TYPECHECK_SET          190    %enddef
%define SWIG_TYPECHECK_MULTISET     200    %enddef
%define SWIG_TYPECHECK_MAP          210    %enddef
%define SWIG_TYPECHECK_MULTIMAP     220    %enddef

%define SWIG_TYPECHECK_BOOL_ARRAY        1015    %enddef
%define SWIG_TYPECHECK_INT8_ARRAY        1025    %enddef
%define SWIG_TYPECHECK_INT16_ARRAY       1035    %enddef
%define SWIG_TYPECHECK_INT32_ARRAY       1045    %enddef
%define SWIG_TYPECHECK_INT64_ARRAY       1055    %enddef
%define SWIG_TYPECHECK_INT128_ARRAY      1065    %enddef
%define SWIG_TYPECHECK_FLOAT_ARRAY       1080    %enddef
%define SWIG_TYPECHECK_DOUBLE_ARRAY      1090    %enddef
%define SWIG_TYPECHECK_CHAR_ARRAY        1130    %enddef
%define SWIG_TYPECHECK_STRING_ARRAY      1140    %enddef
%define SWIG_TYPECHECK_OBJECT_ARRAY      1150    %enddef

%define SWIG_TYPECHECK_BOOL_PTR          2015    %enddef
%define SWIG_TYPECHECK_UINT8_PTR         2020    %enddef
%define SWIG_TYPECHECK_INT8_PTR          2025    %enddef
%define SWIG_TYPECHECK_UINT16_PTR        2030    %enddef
%define SWIG_TYPECHECK_INT16_PTR         2035    %enddef
%define SWIG_TYPECHECK_UINT32_PTR        2040    %enddef
%define SWIG_TYPECHECK_INT32_PTR         2045    %enddef
%define SWIG_TYPECHECK_UINT64_PTR        2050    %enddef
%define SWIG_TYPECHECK_INT64_PTR         2055    %enddef
%define SWIG_TYPECHECK_FLOAT_PTR         2080    %enddef
%define SWIG_TYPECHECK_DOUBLE_PTR        2090    %enddef
%define SWIG_TYPECHECK_CHAR_PTR          2130    %enddef

/*  
 * This template wrapper is used to handle C++ objects that are passed or 
 * returned by value.   This is necessary to handle objects that define
 * no default-constructor (making it difficult for SWIG to properly declare
 * local variables).
 *
 * The wrapper is used as follows.  First consider a function like this:
 *
 *      Vector cross_product(Vector a, Vector b)
 *
 * Now, if Vector is defined as a C++ class with no default constructor, 
 * code is generated as follows:
 *
 *     Vector *wrap_cross_product(Vector *inarg1, Vector *inarg2) {
 *          SwigValueWrapper<Vector>  arg1;
 *          SwigValueWrapper<Vector>  arg2;
 *          SwigValueWrapper<Vector> result;
 *
 *          arg1 = *inarg1;
 *          arg2 = *inarg2;
 *          ...            
 *          result = cross_product(arg1,arg2);
 *          ...
 *          return new Vector(result);
 *    }
 *         
 * In the wrappers, the template SwigValueWrapper simply provides a thin
 * layer around a Vector *.  However, it does this in a way that allows
 * the object to be bound after the variable declaration (which is not possible
 * with the bare object when it lacks a default constructor).  
 *
 * An observant reader will notice that the code after the variable declarations
 * is *identical* to the code used for classes that do define default constructors.
 * Thus, this neat trick allows us to fix this special case without having to
 * make massive changes to typemaps and other parts of the SWIG code generator.
 *
 * Note: this code is not included when SWIG runs in C-mode, when classes
 * define default constructors, or when pointers and references are used.
 * SWIG tries to avoid doing this except in very special circumstances.
 *
 * Note: This solution suffers from making a large number of copies
 * of the underlying object.  However, this is needed in the interest of
 * safety and in order to cover all of the possible ways in which a value
 * might be assigned.  For example:
 *
 *       arg1 = *inarg1;       // Assignment from a pointer
 *       arg1 = Vector(1,2,3); // Assignment from a value  
 *
 * This wrapping technique was suggested by William Fulton and is henceforth
 * known as the "Fulton Transform" :-).
 */

#ifdef __cplusplus
%insert("runtime") %{
#ifdef __cplusplus
template<class T> class SwigValueWrapper {
    T *tt;
public:
    SwigValueWrapper() : tt(0) { }
    SwigValueWrapper(const SwigValueWrapper<T>& rhs) : tt(new T(*rhs.tt)) { }
    SwigValueWrapper(const T& t) : tt(new T(t)) { }
    ~SwigValueWrapper() { delete tt; } 
    SwigValueWrapper& operator=(const T& t) { delete tt; tt = new T(t); return *this; }
    operator T&() const { return *tt; }
    T *operator&() { return tt; }
private:
    SwigValueWrapper& operator=(const SwigValueWrapper<T>& rhs);
};
#endif
%}
#endif

/* Macro for setting a dynamic cast function */
%define DYNAMIC_CAST(mangle,func)
%init %{
   mangle->dcast = (swig_dycast_func) func;
%}
%enddef

/*

   This macro performs constant aggregation.  Basically the idea of
   constant aggregation is that you can group a collection of constants 
   together.  For example, suppose you have some code like this:

       #define UP  1
       #define DOWN 2
       #define LEFT 3
       #define RIGHT 4

   Now, suppose you had a function like this:

       int move(int direction)

   In this case, you might want to restrict the direction argument to one of the supplied
   constant names. To do this, you could write some typemap code by hand.  Alternatively,
   you can use the %aggregate_check macro defined here to create a simple check function
   for you.  Here is an example:

      %aggregate_check(int, check_direction, UP, DOWN, LEFT, RIGHT);

   Now, using a typemap

       %typemap(check) int direction {
            if (!check_direction($1)) SWIG_exception(SWIG_ValueError,"Bad direction.");
       }

   or a contract (better)

       %contract move(int x) {
       require:
           check_direction(x);
       }
*/
   
%define %aggregate_check(TYPE, NAME, FIRST, ...)
%wrapper %{
static int NAME(TYPE x) {
    static  TYPE values[] = { FIRST, ##__VA_ARGS__ };
    static  int size = sizeof(values);
    int     i,j;
    for (i = 0, j = 0; i < size; i+=sizeof(TYPE),j++) {
        if (x == values[j]) return 1; 
    }
    return 0;
}
%}
%enddef

%insert("runtime") "swiglabels.swg"


