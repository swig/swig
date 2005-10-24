/* -----------------------------------------------------------------------------
 *  Typemap specializations
 * ----------------------------------------------------------------------------- */

/* flags for new/convert methods */

#ifndef %convertptr_flags
%ignore %convertptr_flags;
#define %convertptr_flags 0
#endif

#ifndef %newpointer_flags
%ignore %newpointer_flags;
#define %newpointer_flags 0 
#endif

#ifndef %newinstance_flags
%ignore %newinstance_flags;
#define %newinstance_flags 0 
#endif

/* output  and constant manipulation */

#ifndef %set_varoutput
#define %set_varoutput(obj)         $result = obj
#endif

#ifndef %set_output
#define %set_output(obj)            $result = obj
#endif

#ifndef %append_output
#define %append_output(obj)         $result = SWIG_AppendOutput($result,obj) 
#endif

#ifndef %set_constant
#define %set_constant(name,value)   SWIG_SetConstant(name,value)
#endif

/* setting an error and exit */
#define %error_block(Block...)            %block(Block)
#define %argument_fail(code, type, argn)  %error_block(SWIG_Error(code, %argfail_fmt(type, argn)); SWIG_fail)
#define %argument_nullref(type, argn)     %error_block(SWIG_Error(SWIG_ValueError, %argnullref_fmt(type, argn)); SWIG_fail)
#define %variable_fail(code, type, name)  %error_block(SWIG_Error(code, %varfail_fmt(type, name)); SWIG_fail)
#define %variable_nullref(type, name)     %error_block(SWIG_Error(SWIG_ValueError, %varnullref_fmt(type, name)); SWIG_fail)


#ifndef %raise
#define %raise(obj, type, desc)           %error_block(SWIG_Raise(obj, type, desc); SWIG_fail)
#endif

#ifdef SWIG_DIRECTOR_TYPEMAPS
#define %dirout_fail(code, type)          SWIG_DirOutFail(code, %outfail_fmt(type))
#define %dirout_nullref(type)             SWIG_DirOutFail(SWIG_ValueError, %outnullref_fmt(type))
#endif






/* -----------------------------------------------------------------------------
 *  All the typemaps
 * ----------------------------------------------------------------------------- */

%include <typemaps/fragments.swg>
%include <typemaps/exception.swg>
%include <typemaps/swigtype.swg>
%include <typemaps/void.swg>
%include <typemaps/swigobject.swg>
%include <typemaps/valtypes.swg>
%include <typemaps/ptrtypes.swg>
%include <typemaps/inoutlist.swg>
%include <typemaps/primtypes.swg>
%include <typemaps/string.swg>
%include <typemaps/misctypes.swg>
%include <typemaps/enumint.swg>


