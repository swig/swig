// Users can provide their own SWIG_SHARED_PTR_TYPEMAPS macro before including this file to change the
// visibility of the constructor and getCPtr method if desired to public if using multiple modules.
#ifndef SWIG_SHARED_PTR_TYPEMAPS
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
#define SWIG_SHARED_PTR_TYPEMAPS(CONST, TYPE...) SWIG_SHARED_PTR_TYPEMAPS_IMPLEMENTATION(protected, protected, CONST, TYPE)
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
#define SWIG_SHARED_PTR_TYPEMAPS(CONST, TYPE...) SWIG_SHARED_PTR_TYPEMAPS_IMPLEMENTATION(internal, internal, CONST, TYPE)
#endif
#endif

%include <shared_ptr.i>

// Language specific macro implementing all the customisations for handling the smart pointer
%define SWIG_SHARED_PTR_TYPEMAPS_IMPLEMENTATION(PTRCTOR_VISIBILITY, CPTR_VISIBILITY, CONST, TYPE...)

// %naturalvar is as documented for member variables
%naturalvar TYPE;
%naturalvar SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;

// destructor wrapper customisation
%feature("unref") TYPE
//"if (debug_shared) { cout << \"deleting use_count: \" << (*smartarg1).use_count() << \" [\" << (boost::get_deleter<SWIG_null_deleter>(*smartarg1) ? std::string(\"CANNOT BE DETERMINED SAFELY\") : ( (*smartarg1).get() ? (*smartarg1)->getValue() : std::string(\"NULL PTR\") )) << \"]\" << endl << flush; }\n"
                               "(void)arg1; delete smartarg1;"

// Typemap customisations...

// plain value
%typemap(in) CONST TYPE ($&1_type argp = 0) %{
  argp = (*(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input) ? (*(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input)->get() : 0;
  if (!argp) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "Attempt to dereference null $1_type");
    return $null;
  }
  $1 = *argp; %}
%typemap(out) CONST TYPE
%{ *(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(new $1_ltype($1)); %}

%typemap(directorin,descriptor="L$packagepath/$&javaclassname;") CONST TYPE
%{ $input = 0;
  *((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input) = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > (new $1_ltype(SWIG_STD_MOVE($1))); %}

%typemap(directorout) CONST TYPE
%{ if (!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "Attempt to dereference null $1_type");
    return $null;
  }
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = *(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input;
  $result = *smartarg->get();
  %}

// plain pointer
%typemap(in) CONST TYPE * (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) %{
  smartarg = *(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input;
  $1 = (TYPE *)(smartarg ? smartarg->get() : 0); %}
%typemap(out, fragment="SWIG_null_deleter") CONST TYPE * %{
  *(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = $1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_$owner) : 0;
%}

%typemap(directorin,descriptor="L$packagepath/$javaclassname;") CONST TYPE *
%{ $input = 0;
  if ($1) {
    *((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input) = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > ($1 SWIG_NO_NULL_DELETER_0);
  } %}

%typemap(directorout) CONST TYPE * %{
#error "typemaps for $1_type not available"
%}

// plain reference
%typemap(in) CONST TYPE & %{
  $1 = ($1_ltype)((*(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input) ? (*(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input)->get() : 0);
  if (!$1) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "$1_type reference is null");
    return $null;
  } %}
%typemap(out, fragment="SWIG_null_deleter") CONST TYPE &
%{ *(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_$owner); %}

%typemap(directorin,descriptor="L$packagepath/$javaclassname;") CONST TYPE &
%{ $input = 0;
  *((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input) = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > (&$1 SWIG_NO_NULL_DELETER_0); %}

%typemap(directorout) CONST TYPE & %{
#error "typemaps for $1_type not available"
%}

// plain pointer by reference
%typemap(in) TYPE *CONST& ($*1_ltype temp = 0)
%{ temp = (TYPE *)((*(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input) ? (*(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input)->get() : 0);
   $1 = &temp; %}
%typemap(out, fragment="SWIG_null_deleter") TYPE *CONST&
%{ *(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1 SWIG_NO_NULL_DELETER_$owner); %}

%typemap(directorin,descriptor="L$packagepath/$*javaclassname;") TYPE *CONST&
%{ $input = 0;
  if ($1) {
    *((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input) = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > ($1 SWIG_NO_NULL_DELETER_0);
 } %}

%typemap(directorout) TYPE *CONST& %{
#error "typemaps for $1_type not available"
%}

// shared_ptr by value
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > ($&1_type argp)
%{ argp = *($&1_ltype*)&$input;
   if (argp) $1 = *argp; %}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
%{ *($&1_ltype*)&$result = $1 ? new $1_ltype($1) : 0; %}

%typemap(directorin,descriptor="L$packagepath/$typemap(jstype, TYPE);") SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
%{ $input = 0;
  if ($1) {
    *((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input) = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1);
  } %}

%typemap(directorout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
%{ if ($input) {
    $&1_type smartarg = *(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input;
    $result = *smartarg;
  } %}

// shared_ptr by reference
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & ($*1_ltype tempnull)
%{ $1 = $input ? *($&1_ltype)&$input : &tempnull; %}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &
%{ *($&1_ltype)&$result = *$1 ? new $*1_ltype(*$1) : 0; %}

%typemap(directorin,descriptor="L$packagepath/$typemap(jstype, TYPE);") SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &
%{ $input = 0;
  if ($1) {
    *((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input) = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1);
  } %}

%typemap(directorout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & %{
#error "typemaps for $1_type not available"
%}

// shared_ptr by pointer
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * ($*1_ltype tempnull)
%{ $1 = $input ? *($&1_ltype)&$input : &tempnull; %}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *
%{ *($&1_ltype)&$result = ($1 && *$1) ? new $*1_ltype(*$1) : 0;
   if ($owner) delete $1; %}

%typemap(directorin,descriptor="L$packagepath/$typemap(jstype, TYPE);") SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *
%{ $input = 0;
  if ($1 && *$1) {
    *((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input) = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1);
  } %}

%typemap(directorout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * %{
#error "typemaps for $1_type not available"
%}

// shared_ptr by pointer reference
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempnull, $*1_ltype temp = 0)
%{ temp = $input ? *($1_ltype)&$input : &tempnull;
   $1 = &temp; %}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&
%{ *($1_ltype)&$result = (*$1 && **$1) ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(**$1) : 0; %}

%typemap(directorin,descriptor="L$packagepath/$typemap(jstype, TYPE);") SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&
%{ $input = 0;
  if ($1 && *$1) {
    *((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input) = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1);
  } %}

%typemap(directorout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& %{
#error "typemaps for $1_type not available"
%}

// various missing typemaps - If ever used (unlikely) ensure compilation error rather than runtime bug
%typemap(in) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}
%typemap(out) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}


%typemap (jni)    SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "jlong"
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap (jtype)  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "long"
%typemap (jstype) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "$typemap(jstype, TYPE)"
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap (jtype)  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "Long"
%typemap (jstype) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "$typemap(jstype, TYPE)?"
#endif /* SWIGJAVA_TARGET */

%typemap(javain) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                 SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                 SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                 SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "$typemap(jstype, TYPE).getCPtr($javainput)"

#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javaout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > {
    long cPtr = $jnicall;
    return (cPtr == 0) ? null : new $typemap(jstype, TYPE)(cPtr, true);
  }
%typemap(javaout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & {
    long cPtr = $jnicall;
    return (cPtr == 0) ? null : new $typemap(jstype, TYPE)(cPtr, true);
  }
%typemap(javaout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * {
    long cPtr = $jnicall;
    return (cPtr == 0) ? null : new $typemap(jstype, TYPE)(cPtr, true);
  }
%typemap(javaout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& {
    long cPtr = $jnicall;
    return (cPtr == 0) ? null : new $typemap(jstype, TYPE)(cPtr, true);
  }
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javaout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > {
    val cPtr = $jnicall;
    return if (cPtr == 0L) null else $typemap(jstype, TYPE)(cPtr, true);
  }
%typemap(javaout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & {
    val cPtr = $jnicall;
    return if (cPtr == 0L) null else $typemap(jstype, TYPE)(cPtr, true);
  }
%typemap(javaout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * {
    val cPtr = $jnicall;
    return if (cPtr == 0L) null else $typemap(jstype, TYPE)(cPtr, true);
  }
%typemap(javaout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& {
    val cPtr = $jnicall;
    return if (cPtr == 0L) null else $typemap(jstype, TYPE)(cPtr, true);
  }
#endif /* SWIGJAVA_TARGET */


#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javaout) CONST TYPE {
    return new $typemap(jstype, TYPE)($jnicall, true);
  }
%typemap(javaout) CONST TYPE & {
    return new $typemap(jstype, TYPE)($jnicall, true);
  }
%typemap(javaout) CONST TYPE * {
    long cPtr = $jnicall;
    return (cPtr == 0) ? null : new $typemap(jstype, TYPE)(cPtr, true);
  }
%typemap(javaout) TYPE *CONST& {
    long cPtr = $jnicall;
    return (cPtr == 0) ? null : new $typemap(jstype, TYPE)(cPtr, true);
  }
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javaout) CONST TYPE {
    return $typemap(jstype, TYPE)($jnicall, true)
  }
%typemap(javaout) CONST TYPE & {
    return $typemap(jstype, TYPE)($jnicall, true)
  }
%typemap(javaout) CONST TYPE * {
    val cPtr = $jnicall;
    return if (cPtr == 0L) null else $typemap(jstype, TYPE)(cPtr, true);
  }
%typemap(javaout) TYPE *CONST& {
    val cPtr = $jnicall;
    return if (cPtr == 0L) null else $typemap(jstype, TYPE)(cPtr, true);
  }
#endif /* SWIGJAVA_TARGET */

%typemap(javadirectorout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > "$typemap(jstype, TYPE).getCPtr($javacall)"

#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javadirectorin) CONST TYPE,
                         CONST TYPE *,
                         CONST TYPE &,
                         TYPE *CONST& "($jniinput == 0) ? null : new $typemap(jstype, TYPE)($jniinput, true)"
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javadirectorin) CONST TYPE,
                         CONST TYPE *,
                         CONST TYPE &,
                         TYPE *CONST& "if ($jniinput == 0L) null else $typemap(jstype, TYPE)($jniinput, true)"
#endif /* SWIGJAVA_TARGET */

#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javadirectorin) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                         SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                         SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                         SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "($jniinput == 0) ? null : new $typemap(jstype, TYPE)($jniinput, true)"
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javadirectorin) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                         SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                         SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                         SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "if ($jniinput == 0L) null else $typemap(jstype, TYPE)($jniinput, true)"
#endif /* SWIGJAVA_TARGET */

// Base proxy classes
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javabody) TYPE %{
  private transient long swigCPtr;
  private transient boolean swigCMemOwn;

  PTRCTOR_VISIBILITY $javaclassname(long cPtr, boolean cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = cPtr;
  }

  CPTR_VISIBILITY static long getCPtr($javaclassname obj) {
    return (obj == null) ? 0L : obj.swigCPtr;
  }

  CPTR_VISIBILITY void swigSetCMemOwn(boolean own) {
    swigCMemOwn = own;
  }
%}
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javabody) TYPE %{
  private var swigCPtr: Long
  private var swigCMemOwn: Boolean

  PTRCTOR_VISIBILITY constructor(cPtr: Long, cMemoryOwn: Boolean) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = cPtr;
  }

  CPTR_VISIBILITY open fun swigSetCMemOwn(own: Boolean) {
    swigCMemOwn = own;
  }
%}

%typemap(javacompanion) TYPE %{
    CPTR_VISIBILITY fun getCPtr(obj: $javaclassname?): Long {
      return if (obj == null) 0L else obj.swigCPtr;
    }
%}
#endif /* SWIGJAVA_TARGET */

// Derived proxy classes
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javabody_derived) TYPE %{
  private transient long swigCPtr;
  private transient boolean swigCMemOwnDerived;

  PTRCTOR_VISIBILITY $javaclassname(long cPtr, boolean cMemoryOwn) {
    super($imclassname.$javaclazznameSWIGSmartPtrUpcast(cPtr), true);
    swigCMemOwnDerived = cMemoryOwn;
    swigCPtr = cPtr;
  }

  CPTR_VISIBILITY static long getCPtr($javaclassname obj) {
    return (obj == null) ? 0L : obj.swigCPtr;
  }

  CPTR_VISIBILITY void swigSetCMemOwn(boolean own) {
    swigCMemOwnDerived = own;
    super.swigSetCMemOwn(own);
  }
%}
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javabody_derived) TYPE %{
  private var swigCPtr: Long
  private var swigCMemOwnDerived: Boolean

  PTRCTOR_VISIBILITY constructor(cPtr: Long, cMemoryOwn: Boolean) : super($imclassname.$javaclazznameSWIGSmartPtrUpcast(cPtr), true) {
    swigCMemOwnDerived = cMemoryOwn
    swigCPtr = cPtr
  }

  CPTR_VISIBILITY override fun swigSetCMemOwn(own: Boolean) {
    swigCMemOwnDerived = own
    super.swigSetCMemOwn(own)
  }
%}

%typemap(javacompanion_derived) TYPE %{
    CPTR_VISIBILITY fun getCPtr(obj: $javaclassname?): Long {
      return if (obj == null) 0L else obj.swigCPtr
    }
%}
#endif /* SWIGJAVA_TARGET */

#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javadestruct, methodname="delete", methodmodifiers="public synchronized") TYPE {
    if (swigCPtr != 0L) {
      if (swigCMemOwn) {
        swigCMemOwn = false;
        $jnicall;
      }
      swigCPtr = 0L;
    }
  }
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javadestruct, methodname="delete", methodmodifiers="@Synchronized open") TYPE {
    if (swigCPtr != 0L) {
      if (swigCMemOwn) {
        swigCMemOwn = false;
        $jnicall;
      }
      swigCPtr = 0L;
    }
  }
#endif /* SWIGJAVA_TARGET */

#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javadestruct_derived, methodname="delete", methodmodifiers="public synchronized") TYPE {
    if (swigCPtr != 0L) {
      if (swigCMemOwnDerived) {
        swigCMemOwnDerived = false;
        $jnicall;
      }
      swigCPtr = 0L;
    }
    super.delete();
  }
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javadestruct_derived, methodname="delete", methodmodifiers="@Synchronized override") TYPE {
    if (swigCPtr != 0L) {
      if (swigCMemOwnDerived) {
        swigCMemOwnDerived = false;
        $jnicall;
      }
      swigCPtr = 0L;
    }
    super.delete();
  }
#endif /* SWIGJAVA_TARGET */

#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(directordisconnect, methodname="swigDirectorDisconnect") TYPE %{
  protected void $methodname() {
    swigSetCMemOwn(false);
    $jnicall;
  }
%}
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(directordisconnect, methodname="swigDirectorDisconnect") TYPE %{
  $methodmodifiers fun $methodname() {
    swigSetCMemOwn(false);
    $jnicall;
  }
%}
#endif /* SWIGJAVA_TARGET */

#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(directorowner_release, methodname="swigReleaseOwnership") TYPE %{
  public void $methodname() {
    swigSetCMemOwn(false);
    $jnicall;
  }
%}
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(directorowner_release, methodname="swigReleaseOwnership") TYPE %{
  $methodmodifiers fun $methodname() {
    swigSetCMemOwn(false);
    $jnicall;
  }
%}
#endif /* SWIGJAVA_TARGET */

#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(directorowner_take, methodname="swigTakeOwnership") TYPE %{
  public void $methodname() {
    swigSetCMemOwn(true);
    $jnicall;
  }
%}
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(directorowner_take, methodname="swigTakeOwnership") TYPE %{
  $methodmodifiers fun $methodname() {
    swigSetCMemOwn(true);
    $jnicall;
  }
%}
#endif /* SWIGJAVA_TARGET */

// Typecheck typemaps
%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER, equivalent="TYPE *")
  TYPE CONST,
  TYPE CONST &,
  TYPE CONST *,
  TYPE *CONST&,
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&
  ""

%template() SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;
%enddef

