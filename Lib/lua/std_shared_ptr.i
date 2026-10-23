/* -----------------------------------------------------------------------------
 * std_shared_ptr.i
 *
 * SWIG library file for handling std::shared_ptr.
 * Memory ownership is properly tracked by shared_ptr instances.
 * ----------------------------------------------------------------------------- */

// Define std namespace before including shared_ptr.i which provides defaults
#ifndef SWIG_SHARED_PTR_NAMESPACE
#define SWIG_SHARED_PTR_NAMESPACE std
#endif

%include <shared_ptr.i>

// Set SHARED_PTR_DISOWN to $disown if required, for example
// #define SHARED_PTR_DISOWN $disown
#if !defined(SHARED_PTR_DISOWN)
#define SHARED_PTR_DISOWN 0
#endif

// Language specific macro implementing all the customisations for handling the smart pointer
%define SWIG_SHARED_PTR_TYPEMAPS(CONST, TYPE...)

// %naturalvar is as documented for member variables
%naturalvar TYPE;
%naturalvar SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;

// destructor wrapper customisation
// In Lua, the destructor receives the shared_ptr* as 'obj' parameter (not the raw pointer)
// We need to cast it back to the correct type and delete it
%feature("unref") TYPE
  %{(void)arg1;
    delete reinterpret_cast< SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > * >(obj);%}

// Typemap customisations...

// plain value
%typemap(in, checkfn="SWIG_isptrtype", noblock=1) CONST TYPE (void *argp = 0, int res = 0, int newmem = 0, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempshared, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) {
  res = SWIG_ConvertPtrAndOwn(L, $input, &argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SHARED_PTR_DISOWN, &newmem);
  if (!SWIG_IsOK(res)) {
    SWIG_fail_ptr("$symname", $argnum, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *));
  }
  if (!argp) {
    SWIG_Lua_pusherrstring(L, "Attempt to dereference null $1_type");
    SWIG_fail;
  }
  smartarg = reinterpret_cast< SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * >(argp);
  tempshared = *smartarg;
  $1 = *(tempshared.get());
  if (newmem & SWIG_CAST_NEW_MEMORY) delete smartarg;
}
%typemap(out) CONST TYPE {
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(new $1_ltype($1));
  SWIG_NewPointerObj(L, (void *)smartresult, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN); SWIG_arg++;
}

%typemap(directorin, noblock=1) CONST TYPE (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) {
  smartarg = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(new $1_ltype(SWIG_STD_MOVE($1)));
  SWIG_NewPointerObj(L, (void *)smartarg, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN);
}
%typemap(directorout, noblock=1) CONST TYPE (void *swig_argp, int swig_res = 0, int newmem = 0) {
  swig_res = SWIG_ConvertPtrAndOwn(L, $input, &swig_argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), 0, &newmem);
  if (!SWIG_IsOK(swig_res)) {
    Swig::DirectorTypeMismatchException::raise(L, "in output value of type '$type'");
  }
  if (!swig_argp) {
    Swig::DirectorTypeMismatchException::raise(L, "Attempt to dereference null $1_type");
  }
  $result = *(reinterpret_cast< SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * >(swig_argp)->get());
  if (newmem & SWIG_CAST_NEW_MEMORY) delete reinterpret_cast< SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * >(swig_argp);
}

// plain pointer
// Note: $disown not implemented by default as it will lead to a memory leak of the shared_ptr instance
%typemap(in, checkfn="SWIG_isptrtype", noblock=1) CONST TYPE * (void *argp = 0, int res = 0, int newmem = 0, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempshared, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) {
  res = SWIG_ConvertPtrAndOwn(L, $input, &argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SHARED_PTR_DISOWN, &newmem);
  if (!SWIG_IsOK(res)) {
    SWIG_fail_ptr("$symname", $argnum, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *));
  }
  if (newmem & SWIG_CAST_NEW_MEMORY) {
    tempshared = *reinterpret_cast< SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * >(argp);
    delete reinterpret_cast< SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * >(argp);
    $1 = const_cast< $1_ltype >(tempshared.get());
  } else {
    smartarg = reinterpret_cast< SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * >(argp);
    $1 = const_cast< $1_ltype >((smartarg ? smartarg->get() : 0));
  }
}
%typemap(out, fragment="SWIG_null_deleter") CONST TYPE * {
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = $1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_$owner) : 0;
  SWIG_NewPointerObj(L, (void *)smartresult, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN); SWIG_arg++;
}

%typemap(directorin, noblock=1, fragment="SWIG_null_deleter") CONST TYPE * (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) {
  smartarg = $1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_0) : 0;
  SWIG_NewPointerObj(L, (void *)smartarg, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN);
}
%typemap(directorout, noblock=1) CONST TYPE * (void *swig_argp, int swig_res = 0, int newmem = 0) {
  swig_res = SWIG_ConvertPtrAndOwn(L, $input, &swig_argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), 0, &newmem);
  if (!SWIG_IsOK(swig_res)) {
    Swig::DirectorTypeMismatchException::raise(L, "in output value of type '$type'");
  }
  if (swig_argp) {
    $result = reinterpret_cast< SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * >(swig_argp)->get();
  } else {
    $result = 0;
  }
}

// plain reference
%typemap(in, checkfn="SWIG_isptrtype", noblock=1) CONST TYPE & (void *argp = 0, int res = 0, int newmem = 0, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempshared, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) {
  res = SWIG_ConvertPtrAndOwn(L, $input, &argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SHARED_PTR_DISOWN, &newmem);
  if (!SWIG_IsOK(res)) {
    SWIG_fail_ptr("$symname", $argnum, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *));
  }
  if (!argp) {
    SWIG_Lua_pusherrstring(L, "$1_type reference is null");
    SWIG_fail;
  }
  if (newmem & SWIG_CAST_NEW_MEMORY) {
    tempshared = *reinterpret_cast< SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * >(argp);
    delete reinterpret_cast< SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * >(argp);
    $1 = const_cast< $1_ltype >(tempshared.get());
  } else {
    smartarg = reinterpret_cast< SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * >(argp);
    tempshared = *smartarg;
    $1 = const_cast< $1_ltype >(tempshared.get());
  }
}
%typemap(out, fragment="SWIG_null_deleter") CONST TYPE & {
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_$owner);
  SWIG_NewPointerObj(L, (void *)smartresult, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN); SWIG_arg++;
}

%typemap(directorin, noblock=1, fragment="SWIG_null_deleter") CONST TYPE & (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) {
  smartarg = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(&$1 SWIG_NO_NULL_DELETER_0);
  SWIG_NewPointerObj(L, (void *)smartarg, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN);
}
%typemap(directorout, noblock=1) CONST TYPE & (void *swig_argp, int swig_res = 0, int newmem = 0, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempshared) {
  swig_res = SWIG_ConvertPtrAndOwn(L, $input, &swig_argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), 0, &newmem);
  if (!SWIG_IsOK(swig_res)) {
    Swig::DirectorTypeMismatchException::raise(L, "in output value of type '$type'");
  }
  if (!swig_argp) {
    Swig::DirectorTypeMismatchException::raise(L, "$1_type reference is null");
  }
  if (newmem & SWIG_CAST_NEW_MEMORY) {
    tempshared = *reinterpret_cast< SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * >(swig_argp);
    delete reinterpret_cast< SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * >(swig_argp);
    $result = const_cast< $1_ltype >(tempshared.get());
  } else {
    $result = reinterpret_cast< SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * >(swig_argp)->get();
  }
}

// plain pointer by reference
%typemap(in, checkfn="SWIG_isptrtype", noblock=1) TYPE *CONST& (void *argp = 0, int res = 0, int newmem = 0, $*1_ltype temp = 0, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempshared, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) {
  res = SWIG_ConvertPtrAndOwn(L, $input, &argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SHARED_PTR_DISOWN, &newmem);
  if (!SWIG_IsOK(res)) {
    SWIG_fail_ptr("$symname", $argnum, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *));
  }
  if (newmem & SWIG_CAST_NEW_MEMORY) {
    tempshared = *reinterpret_cast< SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * >(argp);
    delete reinterpret_cast< SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * >(argp);
    temp = const_cast< $*1_ltype >(tempshared.get());
  } else {
    smartarg = reinterpret_cast< SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * >(argp);
    temp = const_cast< $*1_ltype >((smartarg ? smartarg->get() : 0));
  }
  $1 = &temp;
}
%typemap(out, fragment="SWIG_null_deleter") TYPE *CONST& {
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = *$1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1 SWIG_NO_NULL_DELETER_$owner) : 0;
  SWIG_NewPointerObj(L, (void *)smartresult, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN); SWIG_arg++;
}

%typemap(directorin, noblock=1, fragment="SWIG_null_deleter") TYPE *CONST& (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) {
  smartarg = $1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_0) : 0;
  SWIG_NewPointerObj(L, (void *)smartarg, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN);
}
%typemap(directorout, noblock=1) TYPE *CONST& %{
#error "directorout typemap for plain pointer by reference not implemented"
%}

// shared_ptr by value
// Note: nil is a valid value representing an empty shared_ptr
%typemap(in, noblock=1) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > (void *argp = 0, int res = 0, int newmem = 0) {
  if (lua_isnil(L, $input)) {
    // nil means empty shared_ptr, $1 is default constructed
  } else {
    res = SWIG_ConvertPtrAndOwn(L, $input, &argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), 0, &newmem);
    if (!SWIG_IsOK(res)) {
      SWIG_fail_ptr("$symname", $argnum, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *));
    }
    if (argp) {
      $1 = *(reinterpret_cast< $&1_ltype >(argp));
      if (newmem & SWIG_CAST_NEW_MEMORY) delete reinterpret_cast< $&1_ltype >(argp);
    }
  }
}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > {
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = $1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1) : 0;
  SWIG_NewPointerObj(L, (void *)smartresult, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN); SWIG_arg++;
}

%typemap(directorin, noblock=1) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) {
  smartarg = $1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1) : 0;
  SWIG_NewPointerObj(L, (void *)smartarg, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN);
}
%typemap(directorout, noblock=1) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > (void *swig_argp, int swig_res = 0, int newmem = 0) {
  swig_res = SWIG_ConvertPtrAndOwn(L, $input, &swig_argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), 0, &newmem);
  if (!SWIG_IsOK(swig_res)) {
    Swig::DirectorTypeMismatchException::raise(L, "in output value of type '$type'");
  }
  if (swig_argp) {
    $result = *(reinterpret_cast< $&ltype >(swig_argp));
    if (newmem & SWIG_CAST_NEW_MEMORY) delete reinterpret_cast< $&ltype >(swig_argp);
  }
}

// shared_ptr by reference
%typemap(in, checkfn="SWIG_isptrtype", noblock=1) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & (void *argp = 0, int res = 0, int newmem = 0, $*1_ltype tempshared) {
  res = SWIG_ConvertPtrAndOwn(L, $input, &argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), 0, &newmem);
  if (!SWIG_IsOK(res)) {
    SWIG_fail_ptr("$symname", $argnum, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *));
  }
  if (newmem & SWIG_CAST_NEW_MEMORY) {
    if (argp) tempshared = *reinterpret_cast< $ltype >(argp);
    delete reinterpret_cast< $ltype >(argp);
    $1 = &tempshared;
  } else {
    $1 = (argp) ? reinterpret_cast< $ltype >(argp) : &tempshared;
  }
}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & {
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = *$1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1) : 0;
  SWIG_NewPointerObj(L, (void *)smartresult, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN); SWIG_arg++;
}

%typemap(directorin, noblock=1) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) {
  smartarg = $1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1) : 0;
  SWIG_NewPointerObj(L, (void *)smartarg, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN);
}
%typemap(directorout, noblock=1) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & %{
#error "directorout typemap for shared_ptr ref not implemented"
%}

// shared_ptr by pointer
%typemap(in, checkfn="SWIG_isptrtype", noblock=1) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * (void *argp = 0, int res = 0, int newmem = 0, $*1_ltype tempshared) {
  res = SWIG_ConvertPtrAndOwn(L, $input, &argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), 0, &newmem);
  if (!SWIG_IsOK(res)) {
    SWIG_fail_ptr("$symname", $argnum, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *));
  }
  if (newmem & SWIG_CAST_NEW_MEMORY) {
    if (argp) tempshared = *reinterpret_cast< $ltype >(argp);
    delete reinterpret_cast< $ltype >(argp);
    $1 = &tempshared;
  } else {
    $1 = (argp) ? reinterpret_cast< $ltype >(argp) : &tempshared;
  }
}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * {
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = ($1 && *$1) ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1) : 0;
  SWIG_NewPointerObj(L, (void *)smartresult, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN); SWIG_arg++;
  if ($owner) delete $1;
}

%typemap(directorin, noblock=1) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) {
  smartarg = ($1 && *$1) ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1) : 0;
  SWIG_NewPointerObj(L, (void *)smartarg, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN);
}
%typemap(directorout, noblock=1) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * %{
#error "directorout typemap for pointer to shared_ptr not implemented"
%}

// shared_ptr by pointer reference
%typemap(in, checkfn="SWIG_isptrtype", noblock=1) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& (void *argp = 0, int res = 0, int newmem = 0, SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempshared, $*1_ltype temp = 0) {
  res = SWIG_ConvertPtrAndOwn(L, $input, &argp, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), 0, &newmem);
  if (!SWIG_IsOK(res)) {
    SWIG_fail_ptr("$symname", $argnum, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *));
  }
  if (argp) {
    tempshared = *(reinterpret_cast< $*ltype >(argp));
    if (newmem & SWIG_CAST_NEW_MEMORY) delete reinterpret_cast< $*ltype >(argp);
  }
  temp = &tempshared;
  $1 = &temp;
}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& {
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartresult = (*$1 && **$1) ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(**$1) : 0;
  SWIG_NewPointerObj(L, (void *)smartresult, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN); SWIG_arg++;
}

%typemap(directorin, noblock=1) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) {
  smartarg = ($1 && *$1) ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1) : 0;
  SWIG_NewPointerObj(L, (void *)smartarg, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), SWIG_POINTER_OWN);
}
%typemap(directorout, noblock=1) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& %{
#error "directorout typemap for pointer ref to shared_ptr not implemented"
%}

// Typecheck typemaps
// Note: SWIG_ConvertPtr with void ** parameter set to 0 instead of using SWIG_ConvertPtrAndOwn, so that the casting
// function is not called thereby avoiding a possible smart pointer copy constructor call when casting up the inheritance chain.
%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER, equivalent="TYPE *", noblock=1)
                      TYPE CONST,
                      TYPE CONST &,
                      TYPE CONST *,
                      TYPE *CONST&,
                      SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                      SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                      SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                      SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& {
  int res = SWIG_ConvertPtr(L, $input, 0, $descriptor(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > *), 0);
  $1 = SWIG_CheckState(res);
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
