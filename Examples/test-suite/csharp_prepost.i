%module csharp_prepost

// Test the pre, post and cshin attributes for csin typemaps

%include "std_vector.i"

%define VECTOR_DOUBLE_CSIN_POST
"      int count$csinput = d$csinput.Count;
      $csinput = new double[count$csinput];
      for (int i=0; i<count$csinput; ++i) {
        $csinput[i] = d$csinput[i];
      }"
%enddef

// pre and post in csin typemaps
%typemap(cstype) std::vector<double> &v "out double[]"
%typemap(csin, pre="    DoubleVector d$csinput = new DoubleVector();", post=VECTOR_DOUBLE_CSIN_POST, cshin="out $csinput") std::vector<double> &v
  "$csclassname.getCPtr(d$csinput)"

%apply std::vector<double> & v { std::vector<double> & v2 }

// pre only in csin typemap
%typemap(cstype) std::vector<double> &vpre "ref double[]"
%typemap(csin, pre="    DoubleVector d$csinput = new DoubleVector();\n    foreach (double d in $csinput) {\n      d$csinput.Add(d);\n    }", cshin="ref $csinput") std::vector<double> &vpre
  "$csclassname.getCPtr(d$csinput)"

// post only in csin typemap
%typemap(csin, post="      int size = $csinput.Count;\n      for (int i=0; i<size; ++i) {\n        $csinput[i] /= 100;\n      }") std::vector<double> &vpost
  "$csclassname.getCPtr($csinput)"

%inline %{
bool globalfunction(std::vector<double> & v) {
  v.push_back(0.0);
  v.push_back(1.1);
  v.push_back(2.2);
  return true;
}
struct PrePostTest {
  PrePostTest() {
  }
  PrePostTest(std::vector<double> & v) {
    v.push_back(3.3);
    v.push_back(4.4);
  }
  bool method(std::vector<double> & v) {
    v.push_back(5.5);
    v.push_back(6.6);
    return true;
  }
  static bool staticmethod(std::vector<double> & v) {
    v.push_back(7.7);
    v.push_back(8.8);
    return true;
  }
};

// Check pre and post only typemaps and that they coexist okay and that the generated code line spacing looks okay
bool globalfunction2(std::vector<double> & v, std::vector<double> &v2, std::vector<double> & vpre, std::vector<double> & vpost) {
  return true;
}
struct PrePost2 {
  PrePost2() {
  }
  PrePost2(std::vector<double> & v, std::vector<double> &v2, std::vector<double> & vpre, std::vector<double> & vpost) {
  }
  bool method(std::vector<double> & v, std::vector<double> &v2, std::vector<double> & vpre, std::vector<double> & vpost) {
    return true;
  }
  static bool staticmethod(std::vector<double> & v, std::vector<double> &v2, std::vector<double> & vpre, std::vector<double> & vpost) {
    return true;
  }
};
%}

%template(DoubleVector) std::vector<double>;

// Check attributes in the typemaps
%typemap(cstype, inattributes="[CustomInt]") int val "int"
%typemap(csin, pre="    int tmp_$csinput = $csinput * 100;") int "tmp_$csinput"
%typemap(imtype, out="IntPtr/*overridden*/", outattributes="[CustomIntPtr]") CsinAttributes * "HandleRef/*overridden*/"

%inline %{
class CsinAttributes {
  int m_val;
public:
  CsinAttributes(int val) : m_val(val) {}
  int getVal() { return m_val; }
};
%}

