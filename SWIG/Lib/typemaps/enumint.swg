/* ------------------------------------------------------------
 *  Enums mapped as integer values
 * ------------------------------------------------------------ */

%apply int { enum SWIGTYPE };
%apply const int& { const enum SWIGTYPE& };

%typemap(in,fragment=SWIG_AsVal_frag(int),noblock=1) const enum SWIGTYPE& (int val, int ecode, $basetype temp) {  
  ecode = SWIG_AsVal(int)($input, &val);
  if (ecode != SWIG_OK) {
    SWIG_arg_fail(ecode, "$basetype", $argnum);
  } else {
    temp = SWIG_static_cast(val,$basetype);
    $1 = &temp;
  }
}

%typemap(varin,fragment=SWIG_AsVal_frag(int),noblock=1) enum SWIGTYPE {
  if (sizeof(int) != sizeof($1)) {
    SWIG_var_fail(SWIG_AttributeError,"$type", "$name");
  }  else {
    int ecode = SWIG_AsVal(int)($input, SWIG_reinterpret_cast(&$1,int*));
    if (ecode != SWIG_OK) {
      SWIG_var_fail(ecode, "$type", "$name");
    }
  }
}

/* 
   typemaps needed due to unnamed enums
*/
%define SWIG_ENUM_OUT_TYPEMAPS(from_meth,frag)
  %typemap(out,noblock=1,fragment=frag) enum SWIGTYPE {
    $result = from_meth(($1));
  }
  %typemap(out,noblock=1,fragment=frag) const enum SWIGTYPE& {
    $result = from_meth((*$1));
  }
  %typemap(varout,noblock=1,fragment=frag) enum SWIGTYPE, const enum SWIGTYPE& {
    $result = from_meth($1);
  }
  %typemap(constcode,noblock=1,fragment=frag) enum SWIGTYPE {
    SWIG_set_constant("$symname", from_meth($value));
  }
  %typemap(directorin,noblock=1,fragment=frag) enum SWIGTYPE *DIRECTORIN {
    $input = from_meth(*$1_name);
  }
  %typemap(directorin,noblock=1,fragment=frag) enum SWIGTYPE, const enum SWIGTYPE& {
    $input = from_meth($1_name);
  }
  %typemap(throws,noblock=1,fragment=frag) enum SWIGTYPE {
    SWIG_raise(from_meth($1),"$type",0);
  }
%enddef

SWIG_ENUM_OUT_TYPEMAPS(SWIG_From(int),SWIG_From_frag(int));

  






