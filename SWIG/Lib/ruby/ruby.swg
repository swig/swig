/* ------------------------------------------------------------
 * ruby.swg
 *
 * Ruby configuration module.
 * ------------------------------------------------------------ */

/* ------------------------------------------------------------
 * The Ruby global rename rules 
 * ------------------------------------------------------------ */
/* Class names are CamelCase */
%rename("%(camelcase)s", %isclass) ""; 

/* Constants are UPPER_CASE */
%rename("%(uppercase)s",%isvariable,%isimmutable) ""; 
%rename("%(uppercase)s", %isconstant) "";

/* Method names should be changed so that they are 
   lower_case_with_underscores */
%rename("%(undercase)s", %isfunction, %ismember) ""; 

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



