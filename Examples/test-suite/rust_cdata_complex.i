%module rust_cdata_complex

%include <std_common.i>
%include <cdata.i>
%include <complex.i>

%cdata(unsigned char, rust_bytes);

%inline %{
#include <complex>
#include <cstring>

int rust_count_bytes(const void *BYTES, size_t LENGTH) {
  const unsigned char *data = (const unsigned char *)BYTES;
  int total = 0;
  size_t i;
  for (i = 0; i < LENGTH; ++i)
    total += data[i];
  return total;
}

std::complex<double> rust_shift_complex(std::complex<double> value) {
  return std::complex<double>(value.real() + 1.5, value.imag() - 2.0);
}

SWIGCDATA rust_make_cdata() {
  static unsigned char rust_cdata_storage[] = { 9, 8, 7, 6 };
  return cdata_rust_bytes(rust_cdata_storage, 4);
}
%}
