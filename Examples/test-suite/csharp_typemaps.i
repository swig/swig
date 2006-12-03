%module csharp_typemaps

// Test the C# types customisation by modifying the default char * typemaps to return a single char

%typemap(imtype, out="char /*imtype out override*/") char * "string"
%typemap(cstype, out="char /*cstype out override*/") char * "string"
%typemap(ctype, out="char /*ctype out override*/") char * "char *"

%typemap(out) char * %{
  // return the 0th element rather than the whole string
  $result = SWIG_csharp_string_callback($1)[0];
%}

%typemap(csout, excode=SWIGEXCODE) char * {
    char ret = $imcall;$excode
    return ret;
  }

%typemap(csvarout, excode=SWIGEXCODE2) char *, char[ANY], char[] %{
    get {
      string ret = new string($imcall, 3);$excode
      return ret;
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

// Number and Obj are for the eager garbage collector runtime test
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

