/*
  Include the internal swig macro codes. These macros correspond to
  the one found in Source/Include/swigwarn.h plus the 'SWIG'prefix.
  
  For example, in the include file 'swigwarn.h' you will find

    #define WARN_TYPEMAP_CHARLEAK ...

  and in the 'swigwarn.swg' interface, you will see

    %define SWIGWARN_TYPEMAP_CHARLEAK ...

  This code can be used in warning filters as follows:

    %warnfilter(SWIGWARN_TYPEMAP_CHARLEAK);

  Warnings messages used in typemaps. Message names will be the same
  as those in Lib/swigwarn.swg but with the suffix _MSG.
   
  For example, for the code SWIGWARN_TYPEMAP_CHARLEAK, once you use

    %typemapmsg(CHARLEAK,<msg>);

  you use the message in your typemap as

    %typemap(varin,warning=SWIGWARN_TYPEMAP_CHARLEAK_MSG) char * 

  while you suppress the warning using

    %warnfilter(SWIGWARN_TYPEMAP_CHARLEAK);

  as described above.
*/

/* -----------------------------------------------------------------------------
 * SWIG warning codes
 * ----------------------------------------------------------------------------- */

%include <swigwarn.swg>

/* -----------------------------------------------------------------------------
 * Auxiliar macros
 * ----------------------------------------------------------------------------- */

/* Macro to define warning messages */
#define %_warningmsg(Val, Msg...) `Val`":"Msg 
#define %warningmsg(Val, Msg...) %_warningmsg(Val, Msg)

/* Macro to define warning macros */
%define %_warningmacro(Def, Val, Msg) %define Def %warningmsg(Val, Msg) %enddef %enddef
#define %warningmacro(x,msg) %_warningmacro(x##_MSG, x, msg)

/* -----------------------------------------------------------------------------
 *  Define typemap macro messages
 * ----------------------------------------------------------------------------- */

#define %typemapmsg(TMap, msg) %warningmacro(SWIGWARN_TYPEMAP_##TMap,msg)

%typemapmsg(CHARLEAK,        "Setting a const char * variable may leak memory.")
%typemapmsg(SWIGTYPELEAK,    "Setting a pointer/reference variable may leak memory.");
%typemapmsg(THREAD_UNSAFE,   "Thread/reentrant unsafe wrapping, consider returning by value instead.");
%typemapmsg(DIRECTOROUT_PTR, "Returning a pointer or reference in a director method is not recommended.");

/* Old warning messages names, for compatibility */
%define SWIG_WARN_TYPEMAP_CHARLEAK        SWIGWARN_TYPEMAP_CHARLEAK_MSG        %enddef
%define SWIG_WARN_TYPEMAP_SWIGTYPELEAK    SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG    %enddef
%define SWIG_WARN_TYPEMAP_THREAD_UNSAFE   SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG   %enddef
%define SWIG_WARN_TYPEMAP_DIRECTOROUT_PTR SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG %enddef

/* -----------------------------------------------------------------------------
 *  Define operator warning macro messages 
 * ----------------------------------------------------------------------------- */

#define %ignoreopermsg(Oper, msg) %warningmacro(SWIGWARN_IGNORE_OPERATOR_##Oper,msg) 

%ignoreopermsg(NEW,       "operator new ignored");
%ignoreopermsg(DELETE,    "operator delete ignored");
%ignoreopermsg(NEWARR,    "operator new[] ignored");
%ignoreopermsg(DELARR,    "operator delete[] ignored");
%ignoreopermsg(PLUS,      "operator+ ignored");
%ignoreopermsg(MINUS,     "operator- ignored");
%ignoreopermsg(MUL,       "operator* ignored");
%ignoreopermsg(DIV,       "operator/ ignored");
%ignoreopermsg(MOD,       "operator% ignored");
%ignoreopermsg(XOR,       "operator^ ignored");
%ignoreopermsg(AND,       "operator& ignored");
%ignoreopermsg(OR,        "operator| ignored");
%ignoreopermsg(NOT,       "operator~ ignored");
%ignoreopermsg(LNOT,      "operator! ignored");
%ignoreopermsg(LAND,      "operator&& ignored");
%ignoreopermsg(LOR,       "operator|| ignored");
%ignoreopermsg(EQ,        "operator= ignored");
%ignoreopermsg(PLUSPLUS,  "operator++ ignored");
%ignoreopermsg(MINUSMINUS,"operator-- ignored");
%ignoreopermsg(ARROWSTAR, "operator->* ignored");
%ignoreopermsg(INDEX,     "operator[] ignored (consider using %%extend)");
%ignoreopermsg(NOTEQUAL,  "operator!= ignored");
%ignoreopermsg(PLUSEQ,    "operator+= ignored");
%ignoreopermsg(MINUSEQ,   "operator-= ignored");
%ignoreopermsg(MULEQ,     "operator*= ignored");
%ignoreopermsg(DIVEQ,     "operator/= ignored");
%ignoreopermsg(MODEQ,     "operator%= ignored");
%ignoreopermsg(LSHIFTEQ,  "operator<<= ignored");
%ignoreopermsg(RSHIFTEQ,  "operator>>= ignored");
%ignoreopermsg(ANDEQ,     "operator&= ignored");
%ignoreopermsg(OREQ,      "operator|= ignored");
%ignoreopermsg(XOREQ,     "operator^= ignored");

#define %ignoreoperator(Oper) %ignorewarn(SWIGWARN_IGNORE_OPERATOR_##Oper##_MSG)

/* -----------------------------------------------------------------------------
 * Macros for keyword and built-in names 
 * ----------------------------------------------------------------------------- */

#define %keywordwarn(msg...) %namewarn(%warningmsg(SWIGWARN_PARSE_KEYWORD, msg)) 
#define %builtinwarn(msg...) %namewarn(%warningmsg(SWIGWARN_PARSE_BUILTIN_NAME, msg))


/* -----------------------------------------------------------------------------
 * Warning filter feature
 * ----------------------------------------------------------------------------- */

#define %_warnfilter(filter...) %feature("warnfilter",`filter`)
#define %warnfilter(filter...) %_warnfilter(filter)


