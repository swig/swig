#!/usr/bin/env ruby
#
# This test implementation is directly derived from its Java counterpart.
#

require 'swig_assert'
require 'nested_class'

outer = Nested_class::Outer.new
is1 = outer.makeInnerStruct1
ic1 = outer.makeInnerClass1
iu1 = outer.makeInnerUnion1

is2 = outer.makeInnerStruct2
ic2 = outer.makeInnerClass2
iu2 = outer.makeInnerUnion2

ic4 = outer.makeInnerClass4Typedef
is4 = outer.makeInnerStruct4Typedef
iu4 = outer.makeInnerUnion4Typedef

ic5 = outer.makeInnerClass5
is5 = outer.makeInnerStruct5
iu5 = outer.makeInnerUnion5

ic5 = outer.makeInnerClass5Typedef
is5 = outer.makeInnerStruct5Typedef
iu5 = outer.makeInnerUnion5Typedef

im1 = outer.MultipleInstance1
im2 = outer.MultipleInstance2
im3 = outer.MultipleInstance3
im4 = outer.MultipleInstance4

im1 = outer.MultipleDerivedInstance1
im2 = outer.MultipleDerivedInstance2
im3 = outer.MultipleDerivedInstance3
im4 = outer.MultipleDerivedInstance4

im1 = outer.MultipleDerivedInstance1
im2 = outer.MultipleDerivedInstance2
im3 = outer.MultipleDerivedInstance3
im4 = outer.MultipleDerivedInstance4

mat1 = outer.makeInnerMultipleAnonTypedef1
mat2 = outer.makeInnerMultipleAnonTypedef2
mat3 = outer.makeInnerMultipleAnonTypedef3

mnt = outer.makeInnerMultipleNamedTypedef
mnt1 = outer.makeInnerMultipleNamedTypedef1
mnt2 = outer.makeInnerMultipleNamedTypedef2
mnt3 = outer.makeInnerMultipleNamedTypedef3

isn = outer.makeInnerSameName
