%module complextest

%include <complex.i>

#ifdef __cplusplus

%inline 
{
  std::complex<double> Conj(const std::complex<double>&  a) 
  {
    return std::conj(a);
  }  

  std::complex<float> Conjf(const std::complex<float>&  a) 
  {
    return std::conj(a);
  }  
}

#else

%inline 
{
  complex Conj(complex a)
  {
    return conj(a);
  }
}


#endif
