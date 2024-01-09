#ifdef SWIGTYPESCRIPT
/* -----------------------------------------------------------------------------
 * ts_header:  module header
 *   - $jsmodule:         name of the module
 * ----------------------------------------------------------------------------- */
%fragment("ts_header", "templates")
%{
declare const _SWIG_enum_tag: unique symbol;
%}

/* -----------------------------------------------------------------------------
 * ts_footer:  module footer
 *   - $jsmodule:         name of the module
 * ----------------------------------------------------------------------------- */
%fragment("ts_footer", "templates")
%{
%}


/* -----------------------------------------------------------------------------
 * ts_global_function:  template for global function wrappers
 *   - $jsname:           JS name of the function
 *   - $tsargs:           TS arguments
 *   - $tsret:            TS return type
 * ----------------------------------------------------------------------------- */
%fragment("ts_global_function", "templates")
%{
export function $jsname($tsargs): $tsret;
%}

/* -----------------------------------------------------------------------------
 * ts_global_variable:  template for public global variables
 *   - $jsname:           JS name of the variable
 *   - $tstype:           TS type
 * ----------------------------------------------------------------------------- */
%fragment("ts_global_variable", "templates")
%{
export let $jsname: $tstype;
%}

/* -----------------------------------------------------------------------------
 * ts_global_constant:  template for global constants
 *   - $jsname:           JS name of the constant
 *   - $tstype:           TS type
 * ----------------------------------------------------------------------------- */
%fragment("ts_global_constant", "templates")
%{
export const $jsname: $tstype;
%}


/* -----------------------------------------------------------------------------
 * ts_class_header:  template for class header
 *   - $jsname:           JS name of the constant
 *   - $jsparent:         Optional parent JS class, must be prefixed with " extends "
 *   - $tsqualifier:      Optional TS qualifier
 * ----------------------------------------------------------------------------- */
%fragment("ts_class_header", "templates")
%{
export $tsqualifier class $jsname$jsparent {
%}

/* -----------------------------------------------------------------------------
 * ts_class_footer:  template for class footer
 *   - $jsname:           JS name of the constant
 * ----------------------------------------------------------------------------- */
%fragment("ts_class_footer", "templates")
%{
}
%}

/* -----------------------------------------------------------------------------
 * ts_function:  template for member function wrappers
 *   - $jsname:           JS name of the function
 *   - $tsargs:           TS arguments
 *   - $tsret:            TS return type
 *   - $tsqualifier:      Optional TS qualifier
 * ----------------------------------------------------------------------------- */
%fragment("ts_function", "templates")
%{
 $tsqualifier $jsname($tsargs): $tsret;
%}

/* -----------------------------------------------------------------------------
 * ts_variable:  template for public members
 *   - $jsname:           JS name of the variable
 *   - $tstype:           TS type
 *   - $tsqualifier:      Optional TS qualifier
 * ----------------------------------------------------------------------------- */
%fragment("ts_variable", "templates")
%{
 $tsqualifier $jsname: $tstype;
%}

/* -----------------------------------------------------------------------------
 * ts_constant:  template for public member constants
 *   - $jsname:           JS name of the constant
 *   - $tstype:           TS type
 *   - $tsqualifier:      Optional TS qualifier
 * ----------------------------------------------------------------------------- */
%fragment("ts_constant", "templates")
%{
 $tsqualifier readonly $jsname: $tstype;
%}

/* -----------------------------------------------------------------------------
 * ts_ctor:  template for public member constants
 *   - $jsname:           JS name of the constant
 *   - $tsargs:           TS arguments
 * ----------------------------------------------------------------------------- */
%fragment("ts_ctor", "templates")
%{
  constructor($tsargs);
%}

/* -----------------------------------------------------------------------------
 * ts_nspace_header:  template for namespace header
 *   - $jsname:           JS name of the constant
 * ----------------------------------------------------------------------------- */
%fragment("ts_nspace_header", "templates")
%{
export namespace $jsname {
%}

/* -----------------------------------------------------------------------------
 * ts_nspace_footer:  template for namespace footer
 *   - $jsname:           JS name of the constant
 * ----------------------------------------------------------------------------- */
%fragment("ts_nspace_footer", "templates")
%{
}
%}

/* -----------------------------------------------------------------------------
 * ts_enum_declaration:  template for enum declaration
 *   - $jsname:         name of the enum type
 *
 * This uses a TypeScript technique called "type branding"
 * https://spin.atomicobject.com/2018/01/15/typescript-flexible-nominal-typing/
 * ----------------------------------------------------------------------------- */
%fragment("ts_enum_declaration", "templates")
%{
export type $jsname = number & { readonly [_SWIG_enum_tag]: '$jsname'; };
%}
#endif
