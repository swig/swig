/* ------------------------------------------------------------
 * ruby.swg
 *
 * Ruby configuration module.
 * ------------------------------------------------------------ */

/* ------------------------------------------------------------
 * The Ruby auto rename rules 
 * ------------------------------------------------------------ */
#if defined(SWIG_RUBY_AUTORENAME)
/* Class names are CamelCase */
%rename("%(camelcase)s", %isclass) ""; 

/* Constants are UPPER_CASE */
%rename("%(uppercase)s", %isconstant) "";
%rename("%(undercase)s", %isvariable,%ismember) ""; 
%rename("%(uppercase)s", %isvariable,%isimmutable) ""; 
%rename("%(uppercase)s", %isvariable,%isstatic,%hasvalue,%hasconsttype) ""; 

/* Method names should be changed so that they are 
   lower_case_with_underscores */
%rename("%(undercase)s", %isfunction, %ismember, %isnotmemberget, %isnotmemberset) "";
#endif

/* ------------------------------------------------------------
 *  Inner macros 
 * ------------------------------------------------------------ */
%include <rubymacros.swg>

/* ------------------------------------------------------------
 *  Error manipulation
 * ------------------------------------------------------------ */
%include <rubyerrors.swg>

/* ------------------------------------------------------------
 *  The runtime part
 * ------------------------------------------------------------ */
%include <rubyruntime.swg>

/* ------------------------------------------------------------
 *  Special user directives
 * ------------------------------------------------------------ */
%include <rubyuserdir.swg>

/* ------------------------------------------------------------
 *  Typemap specializations
 * ------------------------------------------------------------ */
%include <rubytypemaps.swg>

/* ------------------------------------------------------------
 *  Overloaded operator support
 * ------------------------------------------------------------ */
%include <rubyopers.swg>

/* ------------------------------------------------------------
 * Warnings for Ruby keywords 
 * ------------------------------------------------------------ */
%include <rubykw.swg>

/* ------------------------------------------------------------
 * The Ruby initialization function 
 * ------------------------------------------------------------ */
%include <rubyinit.swg>



