/* -----------------------------------------------------------------------------
 * python.swg
 *
 * Python configuration module.
 * ----------------------------------------------------------------------------- */

/*
  bool type in python is too much generic, we invert order for proper
  resolution.
*/

#undef SWIG_TYPECHECK_BOOL
%define SWIG_TYPECHECK_BOOL         10000 %enddef


/* -----------------------------------------------------------------------------
 *  The runtime part
 * ----------------------------------------------------------------------------- */
%include <pyruntime.swg>

/* -----------------------------------------------------------------------------
 *  Special user directives
 * ----------------------------------------------------------------------------- */
%include <pyuserdir.swg>

/* -----------------------------------------------------------------------------
 *  Inner macros (ugly ones)
 * ----------------------------------------------------------------------------- */
%include <pymacros.swg>

/* -----------------------------------------------------------------------------
 *  Look for user fragments file. If not found, include empty system one.
 * ----------------------------------------------------------------------------- */
%include "pyfragments.swg"

/* -----------------------------------------------------------------------------
 *  Typemap specializations
 * ----------------------------------------------------------------------------- */
%include <pyswigtype.swg>
%include <pyinout.swg>
%include <pyvoid.swg>
%include <pyobject.swg>
%include <pystrbase.swg>
%include <pystrings.swg>
%include <pyvaltypes.swg>
%include <pyptrtypes.swg>
%include <pyprimtypes.swg>
%include <pymisctypes.swg>
%include <pyenum.swg>

/* ------------------------------------------------------------
 *  Overloaded operator support
 * ------------------------------------------------------------ */
%include <pyopers.swg>

/* ------------------------------------------------------------
 * Warnings for Python keywords 
 * ------------------------------------------------------------ */
%include <pythonkw.swg>

/* ------------------------------------------------------------
 * The Python autodoc support
 * ------------------------------------------------------------ */

%include <pydocs.swg>

/* ------------------------------------------------------------
 * The Python initialization function 
 * ------------------------------------------------------------ */
%include <pyinit.swg>


