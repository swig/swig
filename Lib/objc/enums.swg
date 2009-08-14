/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * enums.swg
 *
 * Include this file in order for C/C++ enums to be wrapped by proper Objective-C enums.
 * Note that the Objective-C++ layer handles the enum as an int.
* ----------------------------------------------------------------------------- */

// const enum SWIGTYPE & typemaps
%typemap(ocpptype) const enum SWIGTYPE & "int"
%typemap(objctype) const enum SWIGTYPE & "$*objcclassname"

%typemap(in) const enum SWIGTYPE & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input; 
   $1 = &temp; %}
%typemap(out) const enum SWIGTYPE &  %{ $result = (int)*$1; %}

%typemap(objcin) const enum SWIGTYPE & "$objcinput"
%typemap(objcout) const enum SWIGTYPE & {
    return $imcall;
  }

// enum SWIGTYPE typemaps
%typemap(ocpptype) enum SWIGTYPE "int"
%typemap(objctype) enum SWIGTYPE "$objcclassname"

%typemap(in) enum SWIGTYPE  %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum SWIGTYPE  %{ $result = (int)$1; %}

%typemap(objcin) enum SWIGTYPE "$objcinput"
%typemap(objcout) enum SWIGTYPE {
    return $imcall;
  }

%typemap(objcclassmodifiers) enum SWIGTYPE ""
%typemap(objcbase)           enum SWIGTYPE ""
%typemap(objccode)           enum SWIGTYPE ""
%typemap(objcimports)        enum SWIGTYPE ""
%typemap(objcinterfaces)     enum SWIGTYPE ""
%typemap(objcbody)           enum SWIGTYPE ""

%objcenum(proper);

