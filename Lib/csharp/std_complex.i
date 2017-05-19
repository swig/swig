%{
#include <complex>
%}

namespace std {

%naturalvar complex;

// An extremely simplified subset of std::complex<> which contains just the
// methods we need.
template<typename T>
class complex
{
public:
    complex(T re = T(), T im = T());

    T real() const;
    T imag() const;
};

} // namespace std

%define swig_complex_typemaps(T)
%typemap(cstype) std::complex<T>, const std::complex<T>& "System.Numerics.Complex"

// The casts in "pre" are needed in order to allow creating std::complex<float>
// from System.Numerics.Complex, which always uses doubles. It relies on the
// fact that the name of the C++ and C# float/double types are the same.
%typemap(csin,
         pre="    var cpp$csinput = new Complex_" #T "((" #T ")$csinput.Real, (" #T ")$csinput.Imaginary);"
        ) std::complex<T>, const std::complex<T>& "Complex_" #T ".getCPtr(cpp$csinput)"

%typemap(csout, excode=SWIGEXCODE) std::complex<T>, const std::complex<T>& {
    Complex_##T cppret = new Complex_##T($imcall, $owner);$excode
    return new System.Numerics.Complex(cppret.real(), cppret.imag());
  }

%typemap(csvarin, excode=SWIGEXCODE2) const std::complex<T>& %{
    set {
      var cppvalue = new Complex_##T((T)value.Real, (T)value.Imaginary);
      $imcall;$excode
    }
  %}

%typemap(csvarout, excode=SWIGEXCODE2) const std::complex<T>& %{
    get {
      var cppret = new Complex_##T($imcall, $owner);$excode
      return new System.Numerics.Complex(cppret.real(), cppret.imag());
    }
  %}

%template(Complex_##T) std::complex<T>;
%enddef

// By default, typemaps for both std::complex<double> and std::complex<float>
// are defined, but one of them can be disabled by predefining the
// corresponding symbol before including this file.
#ifndef SWIG_NO_STD_COMPLEX_DOUBLE
swig_complex_typemaps(double)
#endif

#ifndef SWIG_NO_STD_COMPLEX_FLOAT
swig_complex_typemaps(float)
#endif
