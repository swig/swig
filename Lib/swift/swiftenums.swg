/* -----------------------------------------------------------------------------
 * swiftenums.swg
 *
 * Typemaps for C/C++ enums wrapped as Swift enums.
 * ----------------------------------------------------------------------------- */

/* Enum values are passed as their raw int representation across the C boundary */
%typemap(ctype)  enum SWIGTYPE  "int"
%typemap(imtype) enum SWIGTYPE  "Int32"
%typemap(swifttype) enum SWIGTYPE  "$swiftclassname"
%typemap(in)  enum SWIGTYPE %{$1 = ($1_ltype)$input;%}
%typemap(out) enum SWIGTYPE %{$result = (int)$1;%}
%typemap(swiftin)    enum SWIGTYPE  "$swiftinput.rawValue"
%typemap(swiftout)   enum SWIGTYPE  %{
    let jresult = $imcall
    try swigCheckException()
    return $swiftclassname(rawValue: jresult)!
%}

/* const enum reference */
%typemap(ctype)  const enum SWIGTYPE &  "int"
%typemap(imtype) const enum SWIGTYPE &  "Int32"
%typemap(swifttype) const enum SWIGTYPE &  "$swiftclassname"
%typemap(in)  const enum SWIGTYPE & (int val) %{
    val = (int)$input;
    $1 = ($1_ltype)&val;
%}
%typemap(out) const enum SWIGTYPE & %{$result = (int)*$1;%}
%typemap(swiftin)    const enum SWIGTYPE &  "$swiftinput.rawValue"
%typemap(swiftout)   const enum SWIGTYPE &  %{
    let jresult = $imcall
    try swigCheckException()
    return $swiftclassname(rawValue: jresult)!
%}

/* Class modifiers for generated Swift enums */
%typemap(swiftclassmodifiers) enum SWIGTYPE ""
