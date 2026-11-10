li_std_complex

c = createComplex(6, 8);
if (getReal(c) != 6)
   error("getReal failed");
endif
if (getImaginary(c) != 8)
   error("getImaginary failed");
endif
if (getMagnitude(c) != 10)
   error("getMagnitude failed");
endif
if (c != complex(6, 8))
   error("compare to native complex failed");
endif

f = createComplexFlt(6, 8);
if (getRealFlt(f) != 6)
   error("getReal failed");
endif
if (getImaginaryFlt(f) != 8)
   error("getImaginary failed");
endif
if (getMagnitudeFlt(f) != 10)
   error("getMagnitude failed");
endif
if (f != complex(6, 8))
   error("compare float to native complex failed");
endif
