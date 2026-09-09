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

/* Director typemaps: C++ enum <-> int (callback ABI), Int32 <-> Swift enum. */
%typemap(directorin)  enum SWIGTYPE  "(int)$input"
%typemap(directorout) enum SWIGTYPE  "($1_ltype)$result"
%typemap(swiftdirectorin)  enum SWIGTYPE  "$swiftclassname(rawValue: $input)!"
%typemap(swiftdirectorout) enum SWIGTYPE  "$input.rawValue"

/* enum / const enum reference director typemaps.  The callback ABI is int; a
 * reference return needs stable storage, so stash the value in a thread-local
 * and return a reference to it. */
%typemap(directorin)  enum SWIGTYPE &        "(int)$input"
%typemap(directorin)  const enum SWIGTYPE &  "(int)$input"
%typemap(directorout) enum SWIGTYPE & \
  "[&]() -> $1_basetype& { static thread_local $1_basetype _swig_e; _swig_e = ($1_basetype)$result; return _swig_e; }()"
%typemap(directorout) const enum SWIGTYPE & \
  "[&]() -> const $1_basetype& { static thread_local $1_basetype _swig_e; _swig_e = ($1_basetype)$result; return _swig_e; }()"
%typemap(swiftdirectorin)  enum SWIGTYPE &        "$swiftclassname(rawValue: $input)!"
%typemap(swiftdirectorin)  const enum SWIGTYPE &  "$swiftclassname(rawValue: $input)!"
%typemap(swiftdirectorout) enum SWIGTYPE &        "$input.rawValue"
%typemap(swiftdirectorout) const enum SWIGTYPE &  "$input.rawValue"

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

/* Non-const enum reference and enum pointer.  Marshalled by value through the
 * enumerator's int; a reference/pointer parameter is backed by a local of the
 * enum type whose address is passed to the C++ call (in/out is not preserved,
 * but the generated Swift and wrapper compile, which the pointer-group class
 * marshalling could not do for a bare enum). */
%typemap(ctype)   enum SWIGTYPE &  "int"
%typemap(imtype)  enum SWIGTYPE &  "Int32"
%typemap(swifttype) enum SWIGTYPE &  "$swiftclassname"
%typemap(in)  enum SWIGTYPE & ($*1_ltype tmp) %{
    tmp = ($*1_ltype)$input;
    $1 = ($1_ltype)&tmp;
%}
%typemap(out) enum SWIGTYPE & %{$result = (int)*$1;%}
%typemap(swiftin)    enum SWIGTYPE &  "$swiftinput.rawValue"
%typemap(swiftout)   enum SWIGTYPE &  %{
    let jresult = $imcall
    try swigCheckException()
    return $swiftclassname(rawValue: jresult)!
%}

%typemap(ctype)   enum SWIGTYPE *  "int"
%typemap(imtype)  enum SWIGTYPE *  "Int32"
%typemap(swifttype) enum SWIGTYPE *  "$swiftclassname"
%typemap(in)  enum SWIGTYPE * ($*1_ltype tmp) %{
    tmp = ($*1_ltype)$input;
    $1 = ($1_ltype)&tmp;
%}
%typemap(out) enum SWIGTYPE * %{$result = (int)*$1;%}
%typemap(swiftin)    enum SWIGTYPE *  "$swiftinput.rawValue"
%typemap(swiftout)   enum SWIGTYPE *  %{
    let jresult = $imcall
    try swigCheckException()
    return $swiftclassname(rawValue: jresult)!
%}

/* Class modifiers for generated Swift enums */
%typemap(swiftclassmodifiers) enum SWIGTYPE ""
