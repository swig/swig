%module csharp_typemaps

// Test the C# types customisation by modifying the default char * typemaps to return a single char

%typemap(ctype, out="char /*ctype out override*/") char * "char *"
%typemap(imtype, out="char /*imtype out override*/") char * "string"
%typemap(cstype, out="char /*cstype out override*/") char * "string"

%typemap(out) char * %{
  // return the 0th element rather than the whole string
  $result = SWIG_csharp_string_callback($1)[0];
%}

%typemap(csout, excode=SWIGEXCODE) char * {
    char ret = $imcall;$excode
    return ret;
  }

%typemap(csvarout, excode=SWIGEXCODE2) char * %{
    get {
      char ret = $imcall;$excode
      return ret;
    } %}

// test valueparm attribute
%typemap(csvarin, excode=SWIGEXCODE2, valueparm="tempValue") char * %{
    set {
      string tempValue = new string(value, 3);
      $imcall;$excode
    } %}


%inline %{
namespace Space {
    class Things {
    public:
        char* start(char *val) { return val; }
        static char* stop(char *val) { return val; }
    };
    char* partyon(char *val) { return val; }
    #define STRINGCONSTANT "xyz string"
    char *go = "zap";
}
%}


// Test variables when ref is used in the cstype typemap - the variable name should come from the out attribute if specified
%typemap(cstype) MKVector, const MKVector& "MKVector"
%typemap(cstype, out="MKVector") MKVector &, MKVector * "ref MKVector"

%inline %{
struct MKVector {
};
struct MKRenderGameVector {
  MKVector memberValue;
  static MKVector staticValue;
};
MKVector MKRenderGameVector::staticValue;
MKVector globalValue;
%}


// Number and Obj are for the eager garbage collector runtime test
%inline %{
struct Number {
  Number(double value) : Value(value) {}
  double Value;
};

class Obj {
public:
  Number triple(Number n) {
    n.Value *= 3;
    return n;
  }
  Number times6(const Number& num) {
    Number n(num);
    n.Value *= 6;
    return n;
  }
  Number times9(const Number* num) {
    Number n(*num);
    n.Value *= 9;
    return n;
  }
};
Number quadruple(Number n) {
    n.Value *= 4;
    return n;
};
Number times8(const Number& num) {
    Number n(num);
    n.Value *= 8;
    return n;
};
Number times12(const Number* num) {
    Number n(*num);
    n.Value *= 12;
    return n;
};
%}

