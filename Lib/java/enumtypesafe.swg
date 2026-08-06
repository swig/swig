/* -----------------------------------------------------------------------------
 * enumtypesafe.swg
 *
 * Include this file in order for C/C++ enums to be wrapped by the so called
 * typesafe enum pattern. Each enum has an equivalent Java class named after the
 * enum and each enum item is a static instance of this class.
 * ----------------------------------------------------------------------------- */

// const enum SWIGTYPE & typemaps
%typemap(jni) const enum SWIGTYPE & "jint"
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(jtype) const enum SWIGTYPE & "int"
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
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
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javadirectorout) const enum SWIGTYPE & "($javacall).swigValue"
#endif

%typecheck(SWIG_TYPECHECK_POINTER) const enum SWIGTYPE & ""

%typemap(throws) const enum SWIGTYPE &
%{ (void)$1;
   SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, "C++ $1_type exception thrown"); %}

#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javain) const enum SWIGTYPE & "$javainput.swigValue()"
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javain) const enum SWIGTYPE & "$javainput.swigValue"
#endif
%typemap(javaout) const enum SWIGTYPE & {
    return $*javaclassname.swigToEnum($jnicall);
  }

// enum SWIGTYPE typemaps
%typemap(jni) enum SWIGTYPE "jint"
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(jtype) enum SWIGTYPE "int"
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
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
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javadirectorout) enum SWIGTYPE "($javacall).swigValue"
#endif

%typecheck(SWIG_TYPECHECK_POINTER) enum SWIGTYPE ""

%typemap(throws) enum SWIGTYPE
%{ (void)$1;
   SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, "C++ $1_type exception thrown"); %}

#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javain) enum SWIGTYPE "$javainput.swigValue()"
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javain) enum SWIGTYPE "$javainput.swigValue"
#endif
%typemap(javaout) enum SWIGTYPE {
    return $javaclassname.swigToEnum($jnicall);
  }

// '$static' will be replaced with either 'static' or nothing depending on whether the enum is an inner Java class or not
%typemap(javabase)           enum SWIGTYPE ""
%typemap(javacode)           enum SWIGTYPE ""
%typemap(javaimports)        enum SWIGTYPE ""
%typemap(javainterfaces)     enum SWIGTYPE ""
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javaclassmodifiers) enum SWIGTYPE "public final $static class"
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javaclassmodifiers) enum SWIGTYPE "class"
%typemap(javacompanion)      enum SWIGTYPE ""
#endif

/*
 * The swigToEnum method is used to find the Java enum from a C++ enum integer value. The default one here takes 
 * advantage of the fact that most enums do not have initial values specified, so the lookup is fast. If initial
 * values are specified then a lengthy linear search through all possible enums might occur. Specific typemaps could be
 * written to possibly optimise this lookup by taking advantage of characteristics peculiar to the targeted enum.
 * The special variable, $enumvalues, is replaced with a comma separated list of all the enum values.
 */
#if SWIGJAVA_TARGET == SWIGJAVA_JAVA
%typemap(javabody) enum SWIGTYPE %{
  public final int swigValue() {
    return swigValue;
  }

  public String toString() {
    return swigName;
  }

  public static $javaclassname swigToEnum(int swigValue) {
    if (swigValue < swigValues.length && swigValue >= 0 && swigValues[swigValue].swigValue == swigValue)
      return swigValues[swigValue];
    for (int i = 0; i < swigValues.length; i++)
      if (swigValues[i].swigValue == swigValue)
        return swigValues[i];
    throw new IllegalArgumentException("No enum " + $javaclassname.class + " with value " + swigValue);
  }

  private $javaclassname(String swigName) {
    this.swigName = swigName;
    this.swigValue = swigNext++;
  }

  private $javaclassname(String swigName, int swigValue) {
    this.swigName = swigName;
    this.swigValue = swigValue;
    swigNext = swigValue+1;
  }

  private $javaclassname(String swigName, $javaclassname swigEnum) {
    this.swigName = swigName;
    this.swigValue = swigEnum.swigValue;
    swigNext = this.swigValue+1;
  }

  private static $javaclassname[] swigValues = { $enumvalues };
  private static int swigNext = 0;
  private final int swigValue;
  private final String swigName;
%}
#elif SWIGJAVA_TARGET == SWIGJAVA_KOTLIN
%typemap(javabody, companion="1") enum SWIGTYPE %{
    private val swigValues = arrayOf<$javaclassname>($enumvalues)

    fun swigToEnum(swigValue: Int): $javaclassname {
      if (swigValue < swigValues.size && swigValue >= 0 && swigValues[swigValue].swigValue == swigValue)
        return swigValues[swigValue]
      for (swigEnum in swigValues)
        if (swigEnum.swigValue == swigValue)
          return swigEnum
      throw IllegalArgumentException("No enum $javaclassname with value " + swigValue)
    }$kcompanionmembers
  }

  val swigValue: Int
  private val swigName: String

  override fun toString(): String {
    return swigName
  }

  private constructor(swigName: String) {
    this.swigName = swigName;
    swigValue = SwigNext.next++
  }

  private constructor(swigName: String, swigValue: Int) {
    this.swigName = swigName;
    this.swigValue = swigValue;
    SwigNext.next = swigValue + 1
  }

  private constructor(swigName: String, swigEnum: $javaclassname) {
    this.swigName = swigName;
    swigValue = swigEnum.swigValue
    SwigNext.next = swigValue + 1
  }

  private object SwigNext {
    var next = 0
  }
%}
#endif /* SWIGJAVA_TARGET */

%javaenum(typesafe);

