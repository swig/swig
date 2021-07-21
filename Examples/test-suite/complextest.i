%module complextest

%include <complex.i>

%{
#include <algorithm>
#include <functional>
#include <numeric>
%}
%include <std_vector.i>

%template(VectorStdCplx) std::vector<std::complex<double> >;

%inline
{
  std::complex<double> Conj(std::complex<double> a)
  {
    return std::conj(a);
  }

  std::complex<float> Conjf(std::complex<float>  a)
  {
    return std::conj(a);
  }

  std::vector<std::complex<double> > CopyHalf(std::vector<std::complex<double> >  a)
  {
    std::vector<std::complex<double> > b(a.size()/2);
    std::copy(a.begin(), a.begin()+a.size()/2, b.begin());
    return b;
  }

  using namespace std;

  struct ComplexPair
  {
    std::complex<double> z1;
    complex<double> z2;
  };

  const complex<double>& Conj2(const complex<double>& a)
  {
    static complex<double> ret;
    ret = std::conj(a);
    return ret;
  }

  const complex<float>& Conjf2(const complex<float>& a)
  {
    static complex<float> ret;
    ret = std::conj(a);
    return ret;
  }

  const vector<complex<double> >& CopyHalfRef(const vector<complex<double> >&  a)
  {
    static vector<complex<double> > b;
    b = CopyHalf(a);
    return b;
  }
}

