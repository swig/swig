%{
#include <complex>
%}

namespace std {

// An extremely simplified subset of std::complex<> which contains just the
// methods we need.
template<typename T>
class complex
{
public:
    complex(T re, T im);

    T real() const;
    T imag() const;
};

} // namespace std

%define swig_complex_typemaps(T)
%typemap(cstype) std::complex<T>, std::complex<T>*, const std::complex<T>& "System.Numerics.Complex"

// The casts in "pre" are needed in order to allow creating std::complex<float>
// from System.Numerics.Complex, which always uses doubles. It relies on the
// fact that the name of the C++ and C# float/double types are the same.
%typemap(csin,
         pre="    var cpp$csinput = new Complex_" #T "((" #T ")$csinput.Real, (" #T ")$csinput.Imaginary);"
        ) std::complex<T>, std::complex<T>*, const std::complex<T>& "Complex_" #T ".getCPtr(cpp$csinput)"

%typemap(csout, excode=SWIGEXCODE) std::complex<T>, const std::complex<T>& {
    Complex_##T cppret = new Complex_##T($imcall, $owner);$excode
    return new System.Numerics.Complex(cppret.real(), cppret.imag());
  }

%typemap(csvarin, excode=SWIGEXCODE2) std::complex<T>*, const std::complex<T>& %{
    set {
      var cppvalue = new Complex_##T((T)value.Real, (T)value.Imaginary);
      $imcall;$excode
    }
  %}

%typemap(csvarout, excode=SWIGEXCODE2) std::complex<T>*, const std::complex<T>& %{
    get {
      var cppret = new Complex_##T($imcall, $owner);$excode
      return new System.Numerics.Complex(cppret.real(), cppret.imag());
    }
  %}

%template(Complex_##T) std::complex<T>;
%enddef

swig_complex_typemaps(double)
swig_complex_typemaps(float)
