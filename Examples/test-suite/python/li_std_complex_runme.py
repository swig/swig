import li_std_complex

c = li_std_complex.createComplex(6, 8);
if li_std_complex.getReal(c) != 6:
  raise RuntimeError
if li_std_complex.getImaginary(c) != 8:
  raise RuntimeError
if li_std_complex.getMagnitude(c) != 10:
  raise RuntimeError

f = li_std_complex.createComplexFlt(6, 8);
if li_std_complex.getRealFlt(f) != 6:
  raise RuntimeError
if li_std_complex.getImaginaryFlt(f) != 8:
  raise RuntimeError
if li_std_complex.getMagnitudeFlt(f) != 10:
  raise RuntimeError
