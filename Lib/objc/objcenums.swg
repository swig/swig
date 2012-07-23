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
   
%typemap(in) enum SWIGTYPE
%{ $1 = ($1_ltype)$input; %}

%typemap(out)   const enum SWIGTYPE &  
%{ $result = (int)*$1; %}

%typemap(out)   enum SWIGTYPE  
%{ $result = (int)$1; %}

/* OBJCIN and OBJCOUT Typemaps */
%typemap(objcin) const enum SWIGTYPE &              "$objcinput"
%typemap(objcin) enum SWIGTYPE                      "$objcinput"

%typemap(objcout) const enum SWIGTYPE & 
%{ return $imcall; %}

%typemap(objcout) enum SWIGTYPE 
%{ return $imcall; %}
