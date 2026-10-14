/* -----------------------------------------------------------------------------
 * exception.swg
 *
 * SWIG_exception and the other error handling macros for the target languages that use the unified typemap library.
 * ----------------------------------------------------------------------------- */

%include <typemaps/swigmacros.swg>


/* macros for error manipulation */
#define %nullref_fmt()                     "invalid null reference "		   
#define %varfail_fmt(_type,_name)          "in variable '"`_name`"' of type '"`_type`"'"
#ifndef %argfail_fmt
#define %argfail_fmt(_type,_name,_argn)    "in method '" `_name` "', argument " `_argn`" of type '" `_type`"'"
#endif
#define %outfail_fmt(_type)                "in output value of type '"_type"'"
#ifndef	%argnullref_fmt
#define %argnullref_fmt(_type,_name,_argn) %nullref_fmt() %argfail_fmt(_type, _name, _argn)
#endif  
#define %varnullref_fmt(_type,_name)       %nullref_fmt() %varfail_fmt(_type, _name)  		   
#define %outnullref_fmt(_type)             %nullref_fmt() %outfail_fmt(_type)         
#define %releasenotownedfail_fmt(_type,_name,_argn)    "in method '" `_name` "', cannot release ownership as memory is not owned for argument " `_argn`" of type '" `_type`"'"

/* setting an error */
#define %error(code,msg...)               SWIG_Error(code, msg)
#define %type_error(msg...)               SWIG_Error(SWIG_TypeError,  msg)



%insert("runtime") {

%define_as(SWIG_exception(code, msg), %block(%error(code, msg); SWIG_fail))

%define_as(SWIG_contract_assert(expr, msg), do { if (!(expr)) { %error(SWIG_RuntimeError, msg); SWIG_fail; } } while (0))

}

/* SWIG_exception needs no support code, but this fragment is always brought in, as other target languages need it */
%fragment("SWIG_exception", "header") {}
