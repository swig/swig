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
%typemap(ktype) const enum SWIGTYPE & "Int"
%typemap(kstype) const enum SWIGTYPE & "$*kotlinclassname"

%typemap(in) const enum SWIGTYPE & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input; 
   $1 = &temp; %}
%typemap(out) const enum SWIGTYPE &  %{ $result = (jint)*$1; %}

%typemap(directorout,warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const enum SWIGTYPE &
%{ static $*1_ltype temp = ($*1_ltype)$input; 
   $result = &temp; %}
%typemap(directorin, descriptor="L$packagepath/$*kotlinclassname;") const enum SWIGTYPE & "$input = (jint)$1;"
%typemap(kdirectorin) const enum SWIGTYPE & "$*kotlinclassname.swigToEnum($jniinput)"
%typemap(kdirectorout) const enum SWIGTYPE & "($kotlincall).swigValue"

%typecheck(SWIG_TYPECHECK_POINTER) const enum SWIGTYPE & ""

%typemap(throws) const enum SWIGTYPE &
%{ (void)$1;
   SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, "C++ $1_type exception thrown"); %}

%typemap(kin) const enum SWIGTYPE & "$kotlininput.swigValue"
%typemap(kout) const enum SWIGTYPE & {
    return $*kotlinclassname.swigToEnum($jnicall)
  }


// enum SWIGTYPE typemaps
%typemap(jni) enum SWIGTYPE "jint"
%typemap(ktype) enum SWIGTYPE "Int"
%typemap(kstype) enum SWIGTYPE "$kotlinclassname"

%typemap(in) enum SWIGTYPE  %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum SWIGTYPE  %{ $result = (jint)$1; %}

%typemap(directorout) enum SWIGTYPE  %{ $result = ($1_ltype)$input; %}
%typemap(directorin, descriptor="L$packagepath/$kotlinclassname;") enum SWIGTYPE "$input = (jint) $1;"
%typemap(kdirectorin) enum SWIGTYPE "$kotlinclassname.swigToEnum($jniinput)"
%typemap(kdirectorout) enum SWIGTYPE "($kotlincall).swigValue"

%typecheck(SWIG_TYPECHECK_POINTER) enum SWIGTYPE ""

%typemap(throws) enum SWIGTYPE
%{ (void)$1;
   SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, "C++ $1_type exception thrown"); %}

%typemap(kin) enum SWIGTYPE "$kotlininput.swigValue"
%typemap(kout) enum SWIGTYPE {
    return $kotlinclassname.swigToEnum($jnicall)
  }

%typemap(kclassmodifiers) enum SWIGTYPE "enum class"
%typemap(kbase)           enum SWIGTYPE ""
%typemap(kcode)           enum SWIGTYPE ""
%typemap(kimports)        enum SWIGTYPE ""
%typemap(kinterfaces)     enum SWIGTYPE ""

/*
 * The SwigNext nested object is used instead of a companion object property as the companion
 * object cannot be accessed from the enum entry initialisers - it is initialised after them.
 * The swigToEnum method is used to find the Kotlin enum from a C++ enum integer value. The default one here takes
 * advantage of the fact that most enums do not have initial values specified, so the lookup is fast. If initial
 * values are specified then a lengthy linear search through all possible enums might occur. Specific typemaps could be
 * written to possibly optimise this lookup by taking advantage of characteristics peculiar to the targeted enum.
 */
%typemap(kbody) enum SWIGTYPE %{
  val swigValue: Int

  @Suppress("unused")
  private constructor() {
    swigValue = SwigNext.next++
  }

  @Suppress("unused")
  private constructor(swigValue: Int) {
    this.swigValue = swigValue
    SwigNext.next = swigValue + 1
  }

  @Suppress("unused")
  private constructor(swigEnum: $kotlinclassname) {
    swigValue = swigEnum.swigValue
    SwigNext.next = swigValue + 1
  }

  private object SwigNext {
    var next = 0
  }

  companion object {
    fun swigToEnum(swigValue: Int): $kotlinclassname {
      val swigValues = values()
      if (swigValue < swigValues.size && swigValue >= 0 && swigValues[swigValue].swigValue == swigValue)
        return swigValues[swigValue]
      for (swigEnum in swigValues)
        if (swigEnum.swigValue == swigValue)
          return swigEnum
      throw IllegalArgumentException("No enum $kotlinclassname with value " + swigValue)
    }
  }
%}

%kotlinenum(proper);

