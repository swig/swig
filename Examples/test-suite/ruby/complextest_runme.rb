#!/usr/bin/env ruby

require 'swig_assert'
require 'complextest'

include Complextest

a = Complex(-1, 2)

swig_assert(Conj(a) == a.conjugate(), "bad complex mapping")

swig_assert(Conjf(a) == a.conjugate(), "bad complex mapping")

swig_assert(Conj2(a) == a.conjugate(), "bad complex mapping")

swig_assert(Conjf2(a) == a.conjugate(), "bad complex mapping")

v = [ Complex(1, 2), Complex(2, 3), Complex(4, 3), 1 ]

swig_assert(CopyHalf(v).length == 2, "CopyHalf failed")

swig_assert(CopyHalfRef(v).length == 2, "CopyHalfRef failed")

p = ComplexPair.new
p.z1 = Complex(0, 1)
p.z2 = Complex(0, -1)
swig_assert(Conj(p.z2) == p.z1, "bad complex mapping")
