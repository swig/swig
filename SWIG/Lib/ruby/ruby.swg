/* ----------------------------------------------------------------------
 * ruby.swg
 *
 * Ruby configuation file.
 * ---------------------------------------------------------------------- */

%runtime "rubyhead.swg"
%runtime "swigrun.swg"       // Common C API type-checking code
%runtime "common.swg"
%runtime "rubydef.swg"

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

