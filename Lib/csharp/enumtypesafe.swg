/* -----------------------------------------------------------------------------
 * Include this file in order for C/C++ enums to be wrapped by the so called
 * typesafe enum pattern. Each enum has an equivalent C# class named after the
 * enum and each enum item is a static instance of this class.
 * ----------------------------------------------------------------------------- */

%typemap(ctype) enum SWIGTYPE "int"
%typemap(imtype) enum SWIGTYPE "int"
%typemap(cstype) enum SWIGTYPE "$csclassname"

%typemap(in) enum SWIGTYPE %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum SWIGTYPE %{ $result = $1; %}

%typecheck(SWIG_TYPECHECK_INT32) enum SWIGTYPE ""

%typemap(throws) enum SWIGTYPE %{
  (void)$1;
  SWIG_CSharpThrowException(SWIG_CSharpException, "C++ $1_type exception thrown");
%}

%typemap(csin) enum SWIGTYPE "$csinput.swigValue"
%typemap(csout) enum SWIGTYPE {
    return $csclassname.swigToEnum($imcall);
  }

%typemap(csvarout) enum SWIGTYPE %{
    get {
      return $csclassname.swigToEnum($imcall);
    } %}

%typemap(csclassmodifiers) enum SWIGTYPE "public sealed class"

/*
 * The swigToEnum method is used to find the C# enum from a C++ enum integer value. The default one here takes 
 * advantage of the fact that most enums do not have initial values specified, so the lookup is fast. If initial
 * values are specified then a lengthy linear search through all possible enums might occur. Specific typemaps could be
 * written to possibly optimise this lookup by taking advantage of characteristics peculiar to the targeted enum.
 * The special variable, $enumvalues, is replaced with a comma separated list of all the enum values.
 */
%typemap(csbody) enum SWIGTYPE %{
  public readonly int swigValue;

  public static $csclassname swigToEnum(int swigValue) {
    if (swigValue < swigValues.Length && swigValues[swigValue].swigValue == swigValue)
      return swigValues[swigValue];
    for (int i = 0; i < swigValues.Length; i++)
      if (swigValues[i].swigValue == swigValue)
        return swigValues[i];
    throw new System.ArgumentOutOfRangeException("No enum $csclassname with value " + swigValue);
  }

  public override string ToString() {
    return swigName;
  }

  private $csclassname(string swigName) {
    this.swigName = swigName;
    this.swigValue = swigNext++;
  }

  private $csclassname(string swigName, int swigValue) {
    this.swigName = swigName;
    this.swigValue = swigValue;
    swigNext = swigValue+1;
  }

  private static $csclassname[] swigValues = { $enumvalues };
  private static int swigNext = 0;
  private readonly string swigName;
%}

%csenum(typesafe);

