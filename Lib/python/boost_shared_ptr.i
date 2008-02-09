%include <shared_ptr.i>

%define SWIG_SHARED_PTR_TYPEMAPS(PROXYCLASS, CONST, TYPE...)

%naturalvar TYPE;
%naturalvar SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;

// destructor mods
%feature("unref") TYPE 
//"if (debug_shared) { cout << \"deleting use_count: \" << (*smartarg1).use_count() << \" [\" << (boost::get_deleter<SWIG_null_deleter>(*smartarg1) ? std::string(\"CANNOT BE DETERMINED SAFELY\") : ( (*smartarg1).get() ? (*smartarg1)->getValue() : std::string(\"NULL PTR\") )) << \"]\" << endl << flush; }\n"
                               "(void)arg1; delete smartarg1;"

%feature("smartptr", noblock=1) TYPE { SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > }

// TODO:
// freearg typemaps
// move %newpointer_flags to SWIG_NO_NULL_DELETER
// position of %newpointer_flags at the moment
// check error messages
// no tests for out typemap for shared_ptr *&

// plain value
%typemap(in) CONST TYPE (void *argp, int res = 0) {
  int newmem = 0;
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum); 
  }
  if (!argp) {
    %argument_nullref("$type", $symname, $argnum);
  } else {
    $1 = *(%reinterpret_cast(argp, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)->get());
    if (newmem & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
  }
}
%typemap(out) CONST TYPE {
  %set_output(SWIG_NewPointerObj(new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(new $1_ltype(($1_ltype &)$1)), $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN | %newpointer_flags));
}

// plain pointer
%typemap(in) CONST TYPE * (void  *argp = 0, int res = 0, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempshared, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) {
  int newmem = 0;
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), $disown | %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum); 
  }
  if (newmem & SWIG_CAST_NEW_MEMORY) {
    tempshared = *%reinterpret_cast(argp, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
    delete %reinterpret_cast(argp, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
    $1 = %const_cast(tempshared.get(), $1_ltype);
  } else {
    smartarg = %reinterpret_cast(argp, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
    $1 = %const_cast((smartarg ? smartarg->get() : 0), $1_ltype); // TODO: replace 0 with $ owner ($owner)
  }
}

%typemap(out, fragment="SWIG_null_deleter") CONST TYPE * {
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >* smartresult = $1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_$owner /* TODO: | %newpointer_flags*/) : 0;
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN));
}

// plain reference
%typemap(in) CONST TYPE & (void  *argp = 0, int res = 0, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempshared) {
  int newmem = 0;
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum); 
  }
  if (!argp) { %argument_nullref("$type", $symname, $argnum); }
  if (newmem & SWIG_CAST_NEW_MEMORY) {
    tempshared = *%reinterpret_cast(argp, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
    delete %reinterpret_cast(argp, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *);
    $1 = %const_cast(tempshared.get(), $1_ltype);
  } else {
    $1 = %const_cast(%reinterpret_cast(argp, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)->get(), $1_ltype);
  }
}
%typemap(out, fragment="SWIG_null_deleter") CONST TYPE & {
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >* smartresult = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_$owner /* TODO: | %newpointer_flags*/);
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN));
}

// plain pointer by reference
%typemap(in) CONST TYPE *& (void  *argp = 0, int res = 0, $*1_ltype temp = 0) {
  res = SWIG_ConvertPtr($input, &argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum); 
  }
  if (argp) temp = %const_cast(%reinterpret_cast(argp, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)->get(), $*1_ltype);
  $1 = &temp;
}

%typemap(out, fragment="SWIG_null_deleter") CONST TYPE *& {
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >* smartresult = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1 SWIG_NO_NULL_DELETER_$owner /* TODO: | %newpointer_flags*/);
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN));
}

// shared_ptr by value
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > (void *argp, int res = 0) {
  int newmem = 0;
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum); 
  }
  if (argp) $1 = *(%reinterpret_cast(argp, $&ltype));
  if (newmem & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, $&ltype);
}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > {
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >* smartresult = $1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1) : 0;
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN | %newpointer_flags));
}

// shared_ptr by reference
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & (void *argp, int res = 0, $*1_ltype tempshared) {
  int newmem = 0;
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum); 
  }
  if (argp) tempshared = *%reinterpret_cast(argp, $ltype);
  if (newmem & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, $ltype);
  $1 = &tempshared;
}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & {
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >* smartresult = *$1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1) : 0;
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN | %newpointer_flags));
}

// shared_ptr by pointer
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * (void *argp, int res = 0, $*1_ltype tempshared) {
  int newmem = 0;
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum); 
  }
  if (argp) tempshared = *%reinterpret_cast(argp, $ltype);
  if (newmem & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, $ltype);
  $1 = &tempshared;
}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * {
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >* smartresult = $1 && *$1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1) : 0;
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN | %newpointer_flags));
  if ($owner | %newpointer_flags) delete $1;
}

// shared_ptr by pointer reference
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& (void *argp, int res = 0, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempshared, $*1_ltype temp = 0) {
  int newmem = 0;
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum); 
  }
  if (argp) tempshared = *%reinterpret_cast(argp, $*ltype);
  if (newmem & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, $*ltype);
  temp = &tempshared;
  $1 = &temp;
}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& {
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >* smartresult = *$1 && **$1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(* /*TODO: extr cast like java?? also shared_ptr<>* typemaps */ *$1) : 0;
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN | %newpointer_flags));
}

// various missing typemaps - If ever used (unlikely) ensure compilation error rather than runtime bug
%typemap(in) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}
%typemap(out) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}


%template() SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;
%enddef

