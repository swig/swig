%module li_std_complex

%include std_complex.i

%inline %{
std::complex<double> createComplex(double real, double img) { return std::complex<double>(real, img); }
double getReal(const std::complex<double> &val) { return val.real(); }
double getImaginary(const std::complex<double> &val) { return val.imag(); }
double getMagnitude(const std::complex<double> &val) { return std::abs(val); }

std::complex<float> createComplexFlt(float real, float img) { return std::complex<float>(real, img); }
float getRealFlt(const std::complex<float> &val) { return val.real(); }
float getImaginaryFlt(const std::complex<float> &val) { return val.imag(); }
float getMagnitudeFlt(const std::complex<float> &val) { return std::abs(val); }
%}
