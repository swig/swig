// Users can provide their own SWIG_SHARED_PTR_TYPEMAPS macro before including this file.
#ifndef SWIG_SHARED_PTR_TYPEMAPS
#define SWIG_SHARED_PTR_TYPEMAPS(CONST, TYPE...) SWIG_SHARED_PTR_TYPEMAPS_IMPLEMENTATION(CONST, TYPE)
#endif

%include <shared_ptr.i>

%define SWIG_SHARED_PTR_TYPEMAPS_IMPLEMENTATION(CONST, TYPE...)

%naturalvar TYPE;
%naturalvar SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;

%feature("unref") TYPE "(void)arg1; delete smartarg1;"

%typemap(in) CONST TYPE ($&1_type argp = 0) {
  argp = ((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input) ? ((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input)->get() : 0;
  if (!argp) {
    SWIG_ObjcThrowException(SWIG_ObjcNullPointerException, "Attempt to dereference null $1_type");
    return $null;
  }
  $1 = *argp;
}
%typemap(out) CONST TYPE {
  $result = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(new $1_ltype($1));
}

%typemap(in) CONST TYPE * (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) {
  smartarg = (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input;
  $1 = (TYPE *)(smartarg ? smartarg->get() : 0);
}
%typemap(out, fragment="SWIG_null_deleter") CONST TYPE * {
  $result = $1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_0) : 0;
}

%typemap(in) CONST TYPE & {
  $1 = ($1_ltype)(((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input) ? ((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input)->get() : 0);
  if (!$1) {
    SWIG_ObjcThrowException(SWIG_ObjcNullPointerException, "$1_type reference is null");
    return $null;
  }
}
%typemap(out, fragment="SWIG_null_deleter") CONST TYPE & {
  $result = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_0);
}

%typemap(in) TYPE *CONST& ($*1_ltype temp = 0) {
  temp = (TYPE *)(((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input) ? ((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input)->get() : 0);
  $1 = &temp;
}
%typemap(out, fragment="SWIG_null_deleter") TYPE *CONST& {
  $result = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1 SWIG_NO_NULL_DELETER_0);
}

%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > {
  if ($input)
    $1 = *(($&1_ltype)$input);
}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > {
  $result = $1 ? new $1_ltype($1) : 0;
}

%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & ($*1_ltype tempnull) {
  $1 = $input ? ($1_ltype)$input : &tempnull;
}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & {
  $result = *$1 ? new $*1_ltype(*$1) : 0;
}

%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * ($*1_ltype tempnull) {
  $1 = $input ? ($1_ltype)&$input : &tempnull;
}
%typemap(out, fragment="SWIG_null_deleter") SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * {
  $result = ($1 && *$1) ? new $*1_ltype(*$1) : 0;
}

%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempnull, $*1_ltype temp = 0) {
  temp = $input ? ($*1_ltype)$input : &tempnull;
  $1 = &temp;
}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& {
  $result = (*$1 && **$1) ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(**$1) : 0;
}

%typemap(imtype) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                 SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                 SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                 SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "void *"
%typemap(objctype) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                   SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                   SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                   SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "$typemap(objctype, TYPE)"
%typemap(objcin) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                 SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                 SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                 SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "[$objcinput getCptr]"

%typemap(objcout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& {
  void *cptr = $imcall;
  $objcclassname *ret = [[$objcclassname alloc] initWithCptr:cptr swigOwnCObject:YES];
  return ret;
}

%template() SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;

%enddef
