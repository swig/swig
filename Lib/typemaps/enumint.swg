/* ------------------------------------------------------------
 *  Enums mapped as integer values
 * ------------------------------------------------------------ */

%apply int { enum SWIGTYPE };
%apply const int& { const enum SWIGTYPE& };

%typemap(in,fragment=SWIG_AsVal_frag(int),noblock=1) const enum SWIGTYPE& (int val, int ecode, $basetype temp) {  
  ecode = SWIG_AsVal(int)($input, &val);
  if (ecode != SWIG_OK) {
    %argument_fail(ecode, "$type", $argnum);
  } else {
    temp = %static_cast(val,$basetype);
    $1 = &temp;
  }
}

%typemap(varin,fragment=SWIG_AsVal_frag(int),noblock=1) enum SWIGTYPE {
  if (sizeof(int) != sizeof($1)) {
    %variable_fail(SWIG_AttributeError,"$type", "arch, read-only $name");
  }  else {
    int ecode = SWIG_AsVal(int)($input, %reinterpret_cast(&$1,int*));
    if (ecode != SWIG_OK) {
      %variable_fail(ecode, "$type", "$name");
    }
  }
}

/* 
   typemaps needed due to unnamed enums
*/
%define %enum_out_typemaps(from_meth,frag)
  %typemap(out,noblock=1,fragment=frag) enum SWIGTYPE {
    %set_output(from_meth(($1)));
  }
  %typemap(out,noblock=1,fragment=frag) const enum SWIGTYPE& {
    %set_output(from_meth((*$1)));
  }
  %typemap(varout,noblock=1,fragment=frag) enum SWIGTYPE, const enum SWIGTYPE& {
    %set_varoutput(from_meth($1));
  }
  %typemap(constcode,noblock=1,fragment=frag) enum SWIGTYPE {
    %set_constant("$symname", from_meth($value));
  }
  %typemap(directorin,noblock=1,fragment=frag) enum SWIGTYPE *DIRECTORIN {
    $input = from_meth(*$1_name);
  }
  %typemap(directorin,noblock=1,fragment=frag) enum SWIGTYPE, const enum SWIGTYPE& {
    $input = from_meth($1_name);
  }
  %typemap(throws,noblock=1,fragment=frag) enum SWIGTYPE {
    %raise(from_meth($1),"$type",0);
  }
%enddef

%enum_out_typemaps(SWIG_From(int),SWIG_From_frag(int));

  






