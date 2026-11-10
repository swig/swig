#!/usr/bin/env ruby

require 'swig_assert'
require 'li_std_complex'

include Li_std_complex

c = createComplex(6, 8)
swig_assert(getReal(c) == 6, binding, 'getReal')
swig_assert(getImaginary(c) == 8, binding, 'getImaginary')
swig_assert(getMagnitude(c) == 10, binding, 'getMagnitude')

f = createComplexFlt(6, 8)
swig_assert(getRealFlt(f) == 6, binding, 'getReal')
swig_assert(getImaginaryFlt(f) == 8, binding, 'getImaginary')
swig_assert(getMagnitudeFlt(f) == 10, binding, 'getMagnitude')
