/* -----------------------------------------------------------------------------
 * objcenums.swg
 *
 * Include this file in order for C/C++ enums to be wrapped by proper Objective-C enums.
 * Note that the intermediate (Objective-C++) layer will handle enums as integers.
* ----------------------------------------------------------------------------- */

/* Intermediate and Proxy Typemaps */
%typemap(imtype)    const enum SWIGTYPE &           "int"
%typemap(imtype)    enum SWIGTYPE                   "int"

%typemap(objctype)  const enum SWIGTYPE &           "$*objcclassname"
%typemap(objctype)  enum SWIGTYPE                   "$objcclassname"

/* IN and OUT Typemaps */
%typemap(in) const enum SWIGTYPE & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input; 
   $1 = &temp; %}
   
%typemap(directorout,warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const enum SWIGTYPE &
%{ static $*1_ltype temp = ($*1_ltype)$input; 
   $result = &temp; %}

%typemap(in) enum SWIGTYPE
%{ $1 = ($1_ltype)$input; %}

%typemap(directorout) enum SWIGTYPE
%{ $result = ($1_ltype)$input; %}

%typemap(objcdirectorout) enum SWIGTYPE "$objccall"

%typemap(out)   const enum SWIGTYPE &  
%{ $result = (int)*$1; %}

%typemap(directorin) const enum SWIGTYPE &
  "$input = (int)$1;"

%typemap(objcdirectorin) const enum SWIGTYPE & "($objctype)($iminput)"

%typemap(out)   enum SWIGTYPE  
%{ $result = (int)$1; %}

%typemap(directorin) enum SWIGTYPE
  "$input = (int)$1;"

%typemap(objcdirectorin) enum SWIGTYPE "($objctype)($iminput)"

/* OBJCIN and OBJCOUT Typemaps */
%typemap(objcin) const enum SWIGTYPE &              "(int)$objcinput"
%typemap(objcin) enum SWIGTYPE                      "(int)$objcinput"

%typemap(objcout) const enum SWIGTYPE & 
%{ return ($*objcclassname)$imcall; %}

%typemap(objcout) enum SWIGTYPE 
%{ return ($objcclassname)$imcall; %}
