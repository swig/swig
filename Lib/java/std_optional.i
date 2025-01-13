// This implementation adds support for std::optional for:
// - Custom types
// - Primitive types:
//  |- bool
//  |- int 
//  |- flaot 
//  |- long
//  |- double
// - Types from std library:
//  |- std::string
// - Enum types

#if !defined(JAVA_NULLABLE_ANNOTATION)
// By default it's empty if you like to use @Nullable anntotation define it. (ex. "@javax.annotation.Nullable")
#define JAVA_NULLABLE_ANNOTATION " " 
#endif

// Main user macro for defining optional typemaps for both const and non-const pointer types
%define %optional(TYPE...)
SWIG_STD_OPTIONAL_TYPEMAPS(, TYPE)
SWIG_STD_OPTIONAL_TYPEMAPS(const, TYPE)
%enddef

#ifndef SWIG_STD_OPTIONAL_TYPEMAPS
#define SWIG_STD_OPTIONAL_TYPEMAPS(CONST, TYPE...) SWIG_STD_OPTIONAL_TYPEMAPS_IMPLEMENTATION(protected, protected, CONST, TYPE)
#endif

// Language specific macro implementing specific customisations for handling the std optional
%define SWIG_STD_OPTIONAL_TYPEMAPS_IMPLEMENTATION(PTRCTOR_VISIBILITY, CPTR_VISIBILITY, CONST, TYPE...)

// 1) Implementation for custom types

// %naturalvar is as documented for member variables
%naturalvar TYPE;
%naturalvar std::optional< CONST TYPE >;

// plain value
%typemap(in) CONST TYPE ($&1_type argp = 0) %{
  // %typemap(in) plain value
  argp = (*(std::optional< CONST TYPE > **)&$input)->has_value() ? new CONST TYPE((*(std::optional< CONST TYPE > **)&$input)->value()) : 0;
  if (!argp) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "Attempt to dereference null $1_type");
    return $null;
  }
  $1 = *argp; 
  // %typemap(in) plain value
%}
%typemap(out) CONST TYPE
%{
  // %typemap(out) plain value
  *(std::optional< CONST TYPE > **)&$result = new std::optional< CONST TYPE >($1); 
  // %typemap(out) plain value
%}

// plain reference
%typemap(in) CONST TYPE & %{
  // %typemap(in) plain referance
  $1 = ($1_ltype)((*(std::optional< CONST TYPE > **)&$input)->has_value() ? new CONST TYPE((*(std::optional< CONST TYPE > **)&$input)->value()) : 0);
  if (!$1) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "$1_type reference is null");
    return $null;
  }
  // %typemap(in) plain referance 
%}
%typemap(out, fragment="SWIG_null_deleter") CONST TYPE &
%{
  // %typemap(out) plain referance 
  *(std::optional< CONST TYPE > **)&$result = new std::optional< CONST TYPE >(*$1);
  // %typemap(out) plain referance
%}

// plain pointer
%typemap(in) CONST TYPE * (std::optional< CONST TYPE > *optionalarg = 0) %{
  // %typemap(in) plain pointer
  optionalarg = *(std::optional< CONST TYPE > **)&$input;
  $1 = (TYPE *)(optionalarg->has_value() ? optionalarg->operator->() : 0);
  // %typemap(in) plain pointer
  %}
%typemap(out, fragment="SWIG_null_deleter") CONST TYPE * %{
  // %typemap(out) plain pointer
  *(std::optional< CONST TYPE > **)&$result = $1 ? new std::optional< CONST TYPE >(*($1)) : 0;
  // %typemap(out) plain pointer
%}

// std::optional by value
%typemap(in) std::optional< CONST TYPE > ($&1_type argp) %{
// %typemap(in) std::optional by value
  argp = *($&1_ltype*)&$input;
  $1 = (argp) ? (*argp) : std::nullopt;
// %typemap(in) std::optional by value
%}
%typemap(out) std::optional< CONST TYPE > %{
// %typemap(out) std::optional by value
*($&1_ltype*)&$result = $1.has_value() ? new $1_ltype($1.value()) : NULL;
// %typemap(out) std::optional by value
%}

// std::optional by reference
%typemap(in) std::optional< CONST TYPE > & ($*1_ltype tempnull)
%{
  // %typemap(in) std::optional by reference
  $1 = $input ? *($&1_ltype)&$input : &tempnull;
  // %typemap(in) std::optional by reference
%}
%typemap(out) std::optional< CONST TYPE > &
%{
  // %typemap(out) std::optional by reference
  *($&1_ltype)&$result = (*$1).has_value() ? $1 : NULL; 
  // %typemap(out) std::optional by reference
%}

// std::optional by pointer
%typemap(in) std::optional< CONST TYPE > * ($*1_ltype tempnull)
%{
  // typemap(in) - std::optional by pointer
  $1 = $input ? *($&1_ltype)&$input : &tempnull;
  // typemap(in) - std::optional by pointer
%}
%typemap(out) std::optional< CONST TYPE > *
%{ 
  // typemap(out) - std::optional by pointer
  *($&1_ltype)&$result = ($1 && (*$1).has_value()) ? new $*1_ltype((*$1).value()) : 0;
   // typemap(out) - std::optional by pointer
%}

// various missing typemaps - If ever used (unlikely) ensure compilation error rather than runtime bug
%typemap(in) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}
%typemap(out) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}

%typemap (jni)    std::optional< CONST TYPE >,
                  std::optional< CONST TYPE > &,
                  std::optional< CONST TYPE > *,
                  std::optional< CONST TYPE > *& "jlong"
%typemap (jtype)  std::optional< CONST TYPE >,
                  std::optional< CONST TYPE > &,
                  std::optional< CONST TYPE > *,
                  std::optional< CONST TYPE > *& "long"
%typemap (jstype) std::optional< CONST TYPE >,
                  std::optional< CONST TYPE > &,
                  std::optional< CONST TYPE > *,
                  std::optional< CONST TYPE > *& JAVA_NULLABLE_ANNOTATION "$typemap(jstype, TYPE)"

%typemap(javain) std::optional< CONST TYPE >,
                 std::optional< CONST TYPE > &,
                 std::optional< CONST TYPE > *,
                 std::optional< CONST TYPE > *& "$typemap(jstype, TYPE).getCPtr($javainput)"

%typemap(javaout) std::optional< CONST TYPE > {
    long cPtr = $jnicall;
    return (cPtr == 0) ? null : new $typemap(jstype, TYPE)(cPtr, true);
  }
%typemap(javaout) std::optional< CONST TYPE > & {
    long cPtr = $jnicall;
    return (cPtr == 0) ? null : new $typemap(jstype, TYPE)(cPtr, true);
  }
%typemap(javaout) std::optional< CONST TYPE > * {
    long cPtr = $jnicall;
    return (cPtr == 0) ? null : new $typemap(jstype, TYPE)(cPtr, true);
  }
%typemap(javaout) std::optional< CONST TYPE > *& {
    long cPtr = $jnicall;
    return (cPtr == 0) ? null : new $typemap(jstype, TYPE)(cPtr, true);
  }


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
  
// Base proxy classes
%typemap(javabody) TYPE %{
  private transient long swigCPtr;
  protected transient boolean swigCMemOwn;

  PTRCTOR_VISIBILITY $javaclassname(long cPtr, boolean cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = cPtr;
  }

  CPTR_VISIBILITY static long getCPtr($javaclassname obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }

  CPTR_VISIBILITY static long swigRelease($javaclassname obj) {
    long ptr = 0;
    if (obj != null) {
      if (!obj.swigCMemOwn)
        throw new RuntimeException("Cannot release ownership as memory is not owned");
      ptr = obj.swigCPtr;
      obj.swigCMemOwn = false;
      obj.delete();
    }
    return ptr;
  }
%}

// Derived proxy classes
%typemap(javabody_derived) TYPE %{
  private transient long swigCPtr;

  PTRCTOR_VISIBILITY $javaclassname(long cPtr, boolean cMemoryOwn) {
    super($imclassname.$javaclazznameSWIGUpcast(cPtr), cMemoryOwn);
    swigCPtr = cPtr;
  }

  CPTR_VISIBILITY static long getCPtr($javaclassname obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }

  CPTR_VISIBILITY static long swigRelease($javaclassname obj) {
    long ptr = 0;
    if (obj != null) {
      if (!obj.swigCMemOwn)
        throw new RuntimeException("Cannot release ownership as memory is not owned");
      ptr = obj.swigCPtr;
      obj.swigCMemOwn = false;
      obj.delete();
    }
    return ptr;
  }
%}

%enddef

// 2) Implementation for primitive types

%{
#include <optional>
%}

namespace std {
  template<typename T> class optional {};
}

%define %AddOptionalTypeForPrimitive(type, java_type, j_type, signature, calling_method, value)

%typemap(jni)    std::optional<type>,
                 std::optional<type> * "jobject"
%typemap(jtype)  std::optional<type>,
                 std::optional<type> * "java_type"
%typemap(jstype) std::optional<type>,
                 std::optional<type> * JAVA_NULLABLE_ANNOTATION "java_type"

%typemap(in) std::optional<type> {
  if ($input) {
    jclass sbufClass = JCALL1(GetObjectClass, jenv, $input);
    jmethodID mid = JCALL3(GetMethodID, jenv, sbufClass, "value", "()signature");
    j_type val = (j_type)JCALL2(calling_method, jenv, $input, mid);
    if (JCALL0(ExceptionCheck, jenv)) return $null;
    $1 = (type)val;
  }
}
%typemap(out) std::optional<type> {
  jclass clazz = JCALL1(FindClass, jenv, "java/lang/java_type");
  jmethodID mid = JCALL3(GetMethodID, jenv, clazz, "<init>", "(signature)V");
  jobject obj = $1.has_value() ? JCALL3(NewObject, jenv, clazz, mid, *$1) : 0;
  $result = obj;
}

%typemap(in) std::optional<type> * {

  $*1_ltype optVal = std::nullopt;
  if ($input) {
    jclass sbufClass = JCALL1(GetObjectClass, jenv, $input);
    jmethodID mid = JCALL3(GetMethodID, jenv, sbufClass, "value", "()signature");
    j_type val = (j_type)JCALL2(calling_method, jenv, $input, mid);
    if (JCALL0(ExceptionCheck, jenv)) return $null;
    optVal = (type)val;
  }
  $1 = &optVal;
}
%typemap(out) std::optional<type> * {
  jclass clazz = JCALL1(FindClass, jenv, "java/lang/java_type");
  jmethodID mid = JCALL3(GetMethodID, jenv, clazz, "<init>", "(signature)V");
  jobject obj = $1->has_value() ? JCALL3(NewObject, jenv, clazz, mid, **$1) : 0;
  $result = obj;
}

%typemap(javain) std::optional<type>,
                 std::optional<type> * "$javainput"
%typemap(javaout) std::optional<type> {
    return $jnicall;
}
%typemap(javaout) std::optional<type> * {
    return $jnicall;
}

%template() std::optional<type>;

%enddef

%AddOptionalTypeForPrimitive(bool, Boolean, jboolean, Z, CallBooleanMethod, booleanValue)
%AddOptionalTypeForPrimitive(int, Integer, jint, I, CallIntMethod, intValue)
%AddOptionalTypeForPrimitive(float, Float, jfloat, F, CallFloatMethod, floatValue)
%AddOptionalTypeForPrimitive(long, Long, jlong, J, CallLongMethod, longValue)
%AddOptionalTypeForPrimitive(long long, Long, jlong, J, CallLongMethod, longValue)
%AddOptionalTypeForPrimitive(double, Double, jdouble, D, CallDoubleMethod, doubleValue)

// 3) Implementation for std library types

%include <std_string.i>

%typemap(jni)    std::optional<std::string>,
                 std::optional<std::string> * "jstring"
%typemap(jtype)  std::optional<std::string>, 
                 std::optional<std::string> * "String"
%typemap(jstype) std::optional<std::string>,
                 std::optional<std::string> * JAVA_NULLABLE_ANNOTATION "String"

%typemap(in) std::optional<std::string> %{
  if ($input) {
    const char *pstr = (const char *)jenv->GetStringUTFChars($input, 0); 
    if (!pstr) return $null;
    $1 = std::string(pstr);
    jenv->ReleaseStringUTFChars($input, pstr);
  }
%}
%typemap(out) std::optional<std::string> %{ 
    $result = $1.has_value() ? jenv->NewStringUTF($1->c_str()) : 0; 
%}

%typemap(in) std::optional<std::string> * %{
  $*1_ltype optVal = std::nullopt;
  if ($input) {
    const char *pstr = (const char *)jenv->GetStringUTFChars($input, 0); 
    if (!pstr) return $null;
    optVal = std::string(pstr);
    jenv->ReleaseStringUTFChars($input, pstr);
  }
  $1 = &optVal;
%}
%typemap(out) std::optional<std::string> * %{ 
    $result = $1->has_value() ? jenv->NewStringUTF((*$1)->c_str()) : 0;
%}

%typemap(javain)  std::optional<std::string>,
                  std::optional<std::string> * "$javainput"
%typemap(javaout) std::optional<std::string> {
    return $jnicall;
}
%typemap(javaout) std::optional<std::string> * {
    return $jnicall;
}

%template() std::optional<std::string>;

// 4) Implementation for enum types

%define %optional_enum(TYPE)

%typemap(jni)    std::optional< TYPE >,
                 std::optional< TYPE > * "jint"
%typemap(jtype)  std::optional< TYPE >,
                 std::optional< TYPE > *  "int"
%typemap(jstype) std::optional< TYPE >,
                 std::optional< TYPE > *  JAVA_NULLABLE_ANNOTATION "$typemap(jstype, TYPE)"

%typemap(in) std::optional< TYPE > %{
    if ($input != -1) {
        $1 = (TYPE)$input;
    } else {
        $1 = std::nullopt;
    }
%}
%typemap(out) std::optional< TYPE > %{ 
    $result = (&$1)->has_value() ? (jint)((&$1))->value() : -1;
%}

%typemap(in) std::optional< TYPE > * %{
    $*1_ltype optVal = std::nullopt;
    if ($input != -1) {
        optVal = (TYPE)$input;
    }
    $1 = &optVal;
%}
%typemap(out) std::optional< TYPE > * %{ 
    $result = $1->has_value() ? (jint)($1)->value() : -1;
%}

%typemap(javain)  std::optional< TYPE >,
                  std::optional< TYPE > * "($javainput == null) ? -1 : $javainput.swigValue()"

%typemap(javaout) std::optional< TYPE > {
    int swigVal = $jnicall;
    return (swigVal == -1) ? null : $typemap(jstype, TYPE).swigToEnum(swigVal);
}
%typemap(javaout) std::optional< TYPE > * {
    int swigVal = $jnicall; 
    return (swigVal == -1) ? null : $typemap(jstype, TYPE).swigToEnum(swigVal);
}

%enddef
