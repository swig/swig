var v = require('li_std_complex');

function check(a, b) {
  if (a !== b)
    throw new Error(`Not equal: ${a} ${b}`);
}

var c = v.createComplex(6, 8);
check(v.getReal(c), 6);
check(v.getImaginary(c), 8);
check(v.getMagnitude(c), 10);

var f = v.createComplexFlt(6, 8);
check(v.getRealFlt(f), 6);
check(v.getImaginaryFlt(f), 8);
check(v.getMagnitudeFlt(f), 10);
