/* ----------------------------------------------------------------------
 * ruby.swg
 *
 * Ruby configuation file.
 * ---------------------------------------------------------------------- */

%runtime "rubyhead.swg"
%runtime "precommon.swg"
%insert(runtime) %{

#ifndef SWIG_ALLOW_RUNTIME
/* -----------------------------------------------------------------------------
 * Disable runtime library use, everything is used as static
 * ----------------------------------------------------------------------------- */
#ifndef SWIG_DISABLE_RUNTIME
#define SWIG_DISABLE_RUNTIME
#endif
#ifdef SWIG_GLOBAL
#undef SWIG_GLOBAL
#endif
#ifdef SWIG_NOINCLUDE
#undef SWIG_NOINCLUDE
#endif
#endif /* SWIG_ALLOW_RUNTIME */

%}
%runtime "common.swg"

%insert(runtime) %{
#ifdef SWIG_NOINCLUDE
%}
%runtime "rubydec.swg"
%insert(runtime) %{
#else
%}
%runtime "rubydef.swg"
%insert(runtime) %{
#endif
%}

#define %alias %feature("alias")
#define %freefunc %feature("freefunc")
#define %markfunc %feature("markfunc")
#define %mixin %feature("mixin")
#define %predicate %feature("predicate", "1")

/* -----------------------------------------------------------------------------
 *  SWIGTYPE typemaps
 * ----------------------------------------------------------------------------- */

%include "rubyswigtype.swg"

/* -----------------------------------------------------------------------------
 *  Typemap specializations
 * ----------------------------------------------------------------------------- */

%include "rubyvoid.swg"
%include "rubyobject.swg"
%include "rubystrings.swg"
%include "rubyprimtypes.swg"
%include "rubymisctypes.swg"
%include "rubyenum.swg"

/* ------------------------------------------------------------
 *  Overloaded operator support
 * ------------------------------------------------------------ */
%include "rubyopers.swg"

/* ------------------------------------------------------------
 * Warnings for Ruby keywords 
 * ------------------------------------------------------------ */
%include "rubykw.swg"

