/* -----------------------------------------------------------------------------
 * enums.swg
 *
 * Include this file in order for C/C++ enums to be wrapped by proper Java enums.
 * Note that the JNI layer handles the enum as an int. The Java enum has extra
 * code generated to store the C++ int value. This is required for C++ enums that
 * specify a value for the enum item, as native Java enums do not support this.
 * ----------------------------------------------------------------------------- */

// const enum SWIGTYPE & typemaps
%typemap(jni) const enum SWIGTYPE & "jint"
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(jtype) const enum SWIGTYPE & "int"
#else
%typemap(jtype) const enum SWIGTYPE & "Int"
#endif
%typemap(jstype) const enum SWIGTYPE & "$*javaclassname"

%typemap(in) const enum SWIGTYPE & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input; 
   $1 = &temp; %}
%typemap(out) const enum SWIGTYPE &  %{ $result = (jint)*$1; %}

%typemap(directorout,warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const enum SWIGTYPE &
%{ static $*1_ltype temp = ($*1_ltype)$input; 
   $result = &temp; %}
%typemap(directorin, descriptor="L$packagepath/$*javaclassname;") const enum SWIGTYPE & "$input = (jint)$1;"
%typemap(javadirectorin) const enum SWIGTYPE & "$*javaclassname.swigToEnum($jniinput)"
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javadirectorout) const enum SWIGTYPE & "($javacall).swigValue()"
#else
%typemap(javadirectorout) const enum SWIGTYPE & "($javacall).swigValue"
#endif

%typecheck(SWIG_TYPECHECK_POINTER) const enum SWIGTYPE & ""

%typemap(throws) const enum SWIGTYPE &
%{ (void)$1;
   SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, "C++ $1_type exception thrown"); %}

#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javain) const enum SWIGTYPE & "$javainput.swigValue()"
#else
%typemap(javain) const enum SWIGTYPE & "$javainput.swigValue"
#endif
%typemap(javaout) const enum SWIGTYPE & {
    return $*javaclassname.swigToEnum($jnicall);
  }


// enum SWIGTYPE typemaps
%typemap(jni) enum SWIGTYPE "jint"
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(jtype) enum SWIGTYPE "int"
#else
%typemap(jtype) enum SWIGTYPE "Int"
#endif
%typemap(jstype) enum SWIGTYPE "$javaclassname"

%typemap(in) enum SWIGTYPE  %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum SWIGTYPE  %{ $result = (jint)$1; %}

%typemap(directorout) enum SWIGTYPE  %{ $result = ($1_ltype)$input; %}
%typemap(directorin, descriptor="L$packagepath/$javaclassname;") enum SWIGTYPE "$input = (jint) $1;"
%typemap(javadirectorin) enum SWIGTYPE "$javaclassname.swigToEnum($jniinput)"
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javadirectorout) enum SWIGTYPE "($javacall).swigValue()"
#else
%typemap(javadirectorout) enum SWIGTYPE "($javacall).swigValue"
#endif

%typecheck(SWIG_TYPECHECK_POINTER) enum SWIGTYPE ""

%typemap(throws) enum SWIGTYPE
%{ (void)$1;
   SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, "C++ $1_type exception thrown"); %}

#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javain) enum SWIGTYPE "$javainput.swigValue()"
#else
%typemap(javain) enum SWIGTYPE "$javainput.swigValue"
#endif
%typemap(javaout) enum SWIGTYPE {
    return $javaclassname.swigToEnum($jnicall);
  }

%typemap(javabase)           enum SWIGTYPE ""
%typemap(javacode)           enum SWIGTYPE ""
%typemap(javaimports)        enum SWIGTYPE ""
%typemap(javainterfaces)     enum SWIGTYPE ""
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javaclassmodifiers) enum SWIGTYPE "public enum"
#else
%typemap(javaclassmodifiers) enum SWIGTYPE "enum class"
%typemap(javacompanion)      enum SWIGTYPE ""
#endif

/*
 * SwigNext static inner class used instead of a static int as static fields cannot be accessed from enum initialisers.
 * The swigToEnum method is used to find the Java enum from a C++ enum integer value. The default one here takes 
 * advantage of the fact that most enums do not have initial values specified, so the lookup is fast. If initial
 * values are specified then a lengthy linear search through all possible enums might occur. Specific typemaps could be
 * written to possibly optimise this lookup by taking advantage of characteristics peculiar to the targeted enum.
 */
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javabody) enum SWIGTYPE %{
  public final int swigValue() {
    return swigValue;
  }

  public static $javaclassname swigToEnum(int swigValue) {
    $javaclassname[] swigValues = $javaclassname.class.getEnumConstants();
    if (swigValue < swigValues.length && swigValue >= 0 && swigValues[swigValue].swigValue == swigValue)
      return swigValues[swigValue];
    for ($javaclassname swigEnum : swigValues)
      if (swigEnum.swigValue == swigValue)
        return swigEnum;
    throw new IllegalArgumentException("No enum " + $javaclassname.class + " with value " + swigValue);
  }

  @SuppressWarnings("unused")
  private $javaclassname() {
    this.swigValue = SwigNext.next++;
  }

  @SuppressWarnings("unused")
  private $javaclassname(int swigValue) {
    this.swigValue = swigValue;
    SwigNext.next = swigValue+1;
  }

  @SuppressWarnings("unused")
  private $javaclassname($javaclassname swigEnum) {
    this.swigValue = swigEnum.swigValue;
    SwigNext.next = this.swigValue+1;
  }

  private final int swigValue;

  private static class SwigNext {
    private static int next = 0;
  }
%}
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javabody) enum SWIGTYPE %{
  val swigValue: Int

  @Suppress("unused")
  constructor() {
    swigValue = SwigNext.next++
  }

  @Suppress("unused")
  constructor(swigValue: Int) {
    this.swigValue = swigValue
    SwigNext.next = swigValue + 1
  }

  @Suppress("unused")
  constructor(swigEnum: $javaclassname) {
    swigValue = swigEnum.swigValue
    SwigNext.next = swigValue + 1
  }

  private object SwigNext {
    var next = 0
  }

  companion object {
    fun swigToEnum(swigValue: Int): $javaclassname {
      val swigValues = values()
      if (swigValue < swigValues.size && swigValue >= 0 && swigValues[swigValue].swigValue == swigValue)
        return swigValues[swigValue]
      for (swigEnum in swigValues)
        if (swigEnum.swigValue == swigValue)
          return swigEnum
      throw IllegalArgumentException("No enum $javaclassname with value " + swigValue)
    }$kcompanionmembers
  }
%}
#endif /* SWIGJAVA_TARGET */

%javaenum(proper);

