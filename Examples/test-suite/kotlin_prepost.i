%module kotlin_prepost

// Test the pre, post attributes for kin typemaps

%include "std_vector.i"

// Kotlin function parameters are immutable (val), so unlike the Java post typemap which
// reallocates the array parameter, the post code copies the populated DoubleVector contents
// back into the existing array in place.
%define VECTOR_DOUBLE_KIN_POST
"      val count$kotlininput = minOf(d$kotlininput.size, $kotlininput.size)
      for (i in 0 until count$kotlininput) {
        $kotlininput[i] = d$kotlininput[i]
      }"
%enddef

// pre and post in kin typemaps
%typemap(kstype) std::vector<double> &v "DoubleArray"
%typemap(kin, pre="    val d$kotlininput = DoubleVector()", post=VECTOR_DOUBLE_KIN_POST, pgcppname="d$kotlininput") std::vector<double> &v
  "$kotlinclassname.getCPtr(d$kotlininput)"

%apply std::vector<double> & v { std::vector<double> & v2 }

// pre only in kin typemap
%typemap(kstype) std::vector<double> &vpre "DoubleArray"
%typemap(kin, pre="    val d$kotlininput = DoubleVector()\n    for (i in 0 until $kotlininput.size) {\n      val d = $kotlininput[i]\n      d$kotlininput.add(d)\n    }", pgcppname="d$kotlininput") std::vector<double> &vpre
  "$kotlinclassname.getCPtr(d$kotlininput)"

// post only in kin typemap
%typemap(kin, post="      val size = $kotlininput.size\n      for (i in 0 until size) {\n        $kotlininput[i] = $kotlininput[i]/100\n      }") std::vector<double> &vpost
  "$kotlinclassname.getCPtr($kotlininput)"

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


// Check pre post constructor helper. Unlike Java, Kotlin has no checked exceptions, so the
// "throws" attribute (collected but not rendered into the generated code) is a no-op here;
// the pre code simply throws a RuntimeException at runtime when null is passed.
%typemap(kin, pre="    if ($kotlininput == null)\n      throw RuntimeException(\"empty value!!\")", throws="InstantiationException") PrePostTest *
  "$kotlinclassname.getCPtr($kotlininput)"

%inline %{
struct PrePostThrows {
  PrePostThrows(PrePostTest *ppt, bool) {
  }
};
%}
