/* -----------------------------------------------------------------------------
 * Include this file in order for C/C++ enums to be wrapped by the so called
 * typesafe enum pattern. Each enum has an equivalent Java class named after the
 * enum and each enum item is a static instance of this class.
 * ----------------------------------------------------------------------------- */

%typemap(jni) enum SWIGTYPE "jint"
%typemap(jtype) enum SWIGTYPE "int"
%typemap(jstype) enum SWIGTYPE "$javaclassname"

%typemap(in) enum SWIGTYPE  %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum SWIGTYPE  %{ $result = (jint)$1; %}

%typemap(directorin, descriptor="I") enum SWIGTYPE    "$input = (jint) $1;"
%typemap(javadirectorin) enum SWIGTYPE "$jniinput"
%typemap(javadirectorout) enum SWIGTYPE "$javacall"

%typecheck(SWIG_TYPECHECK_INT32) enum SWIGTYPE ""

%typemap(throws) enum SWIGTYPE %{
  SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, "C++ $1_type exception thrown");
%}

%typemap(javain) enum SWIGTYPE "$javainput.swigValue()"
%typemap(javaout) enum SWIGTYPE {
    return $javaclassname.swigToEnum($jnicall);
  }

// '$static' will be replaced with either 'static' or nothing depending on whether the enum is an inner Java class or not
%typemap(javaclassmodifiers) enum SWIGTYPE "public final $static class"

/*
 * The swigToEnum method is used to find the Java enum from a C++ enum integer value. The default one here takes 
 * advantage of the fact that most enums do not have initial values specified, so the lookup is fast. If initial
 * values are specified then a lengthy linear search through all possible enums might occur. Specific typemaps could be
 * written to possibly optimise this lookup by taking advantage of characteristics peculiar to the targeted enum.
 * The special variable, $enumvalues, is replaced with a comma separated list of all the enum values.
 */
%typemap(javagetcptr) enum SWIGTYPE %{
  public final int swigValue() {
    return swigValue;
  }

  public String toString() {
    return swigName;
  }

  public static $javaclassname swigToEnum(int swigValue) {
    if (swigValue < swigValues.length && swigValues[swigValue].swigValue == swigValue)
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

  private static $javaclassname[] swigValues = { $enumvalues };
  private static int swigNext = 0;
  private final int swigValue;
  private final String swigName;
%}

%javaenum(typesafe);

