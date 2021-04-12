#!/usr/bin/env ruby
#
# This test implementation is directly derived from its Java counterpart.
#

require 'swig_assert'
require 'multiple_inheritance_nspace'

# Test base class as a parameter in Ruby

def jcbase1b(cb1)
  cb1.cbase1y
end

def jabase1(ab1)
  ab1.abase1
end

def jcbase2(cb2)
  cb2.cbase2
end

# test Derived1
d1 = Multiple_inheritance_nspace::Derived1.new
swig_assert_equal('d1.cbase1y', '3', binding, 'Derived1::cbase1y() failed')
swig_assert_equal('d1.cbase2', '4', binding, 'Derived1::cbase2() failed')

# test Derived2
d2 = Multiple_inheritance_nspace::Derived2.new
swig_assert_equal('d2.cbase1y', '6', binding, 'Derived2::cbase1y() failed')
swig_assert_equal('d2.abase1', '5', binding, 'Derived2::cbase1y() failed')

# test Derived3
d3 = Multiple_inheritance_nspace::Derived3.new
swig_assert_equal('d3.cbase1y', '7', binding, 'Derived3::cbase1y() failed')
swig_assert_equal('d3.cbase2', '8', binding, 'Derived3::cbase2() failed')
swig_assert_equal('d3.abase1', '9', binding, 'Derived3::abase1() failed')

# test Bottom1
b1 = Multiple_inheritance_nspace::Bottom1.new
swig_assert_equal('b1.cbase1y', '103', binding, 'Bottom1::cbase1y() failed')
swig_assert_equal('b1.cbase2', '104', binding, 'Bottom1::cbase2() failed')

# test Bottom2
b2 = Multiple_inheritance_nspace::Bottom2.new
swig_assert_equal('b2.cbase1y', '206', binding, 'Bottom2::cbase1y() failed')
swig_assert_equal('b2.abase1', '205', binding, 'Bottom2::abase1() failed')

# test Bottom3
b3 = Multiple_inheritance_nspace::Bottom3.new
swig_assert_equal('b3.cbase1y', '307', binding, 'Bottom3::cbase1y() failed')
swig_assert_equal('b3.cbase2', '308', binding, 'Bottom3::cbase2() failed')
swig_assert_equal('b3.abase1', '309', binding, 'Bottom3::abase1() failed')

# test interfaces from C++ classes
cb1 = Multiple_inheritance_nspace::CBase1.new
cb2 = Multiple_inheritance_nspace::CBase2.new
swig_assert_equal('cb1.cbase1y', '1', binding, 'CBase1::cbase1y() failed')
swig_assert_equal('cb2.cbase2', '2', binding, 'CBase2::cbase2() failed')

# test nspace class as return value
ab1 = d3.cloneit
swig_assert_equal('ab1.abase1', '9', binding, 'Derived3::abase1() through ABase1 failed')

# test concrete base class as return value
cb6 = d2.cloneit
cb7 = d1.cloneit
swig_assert_equal('cb6.cbase1y', '6', binding, 'Derived2::cbase1y() through CBase1 failed')
swig_assert_equal('cb7.cbase2', '4', binding, 'Derived1:cbase2() through ABase1 failed')

# test multi inheritance
cb3 = Multiple_inheritance_nspace::Derived1.new
cb4 = Multiple_inheritance_nspace::Derived3.new
cb5 = Multiple_inheritance_nspace::Derived3.new
ab6 = Multiple_inheritance_nspace::Derived2.new
swig_assert_equal('cb3.cbase1y', '3', binding, 'Derived1::cbase1y() through CBase1 failed')
swig_assert_equal('cb4.cbase1y', '7', binding, 'Derived3::cbase1y() through CBase1 failed')
swig_assert_equal('cb5.cbase2', '8', binding, 'Derived3::cbase2() through CBase2 failed')
swig_assert_equal('ab6.abase1', '5', binding, 'Derived2::abase1() through ABase1 failed')

# test base classes as parameter in Ruby
swig_assert_equal('jcbase1b(d1)', '3', binding, 'jcbase1b() through Derived1 as parameter failed')
swig_assert_equal('jcbase1b(d2)', '6', binding, 'jcbase1b() through Derived2 as parameter failed')
swig_assert_equal('jcbase1b(d3)', '7', binding, 'jcbase1b() through Derived3 as parameter failed')
swig_assert_equal('jcbase2(d1)', '4', binding, 'jcbase2() through Derived1 as parameter failed')
swig_assert_equal('jcbase2(d3)', '8', binding, 'jcbase2() through Derived3 as parameter failed')
swig_assert_equal('jabase1(d2)', '5', binding, 'jabase1() through Derived2 as parameter failed')
swig_assert_equal('jabase1(d3)', '9', binding, 'jabase1() through Derived3 as parameter failed')

# value parameters
# test CBase1 CBase2 as parameters (note slicing for Derived and Bottom classes)
swig_assert_equal('Multiple_inheritance_nspace::InputValCBase1(d1)', '1', binding, 'InputValCBase1(), Derived1 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputValCBase1(d2)', '1', binding, 'InputValCBase1(), Derived2 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputValCBase1(d3)', '1', binding, 'InputValCBase1(), Derived3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputValCBase2(d3)', '2', binding, 'InputValCBase2(), Derived3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputValCBase2(d1)', '2', binding, 'InputValCBase2(), Derived1 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputValCBase1(cb1)', '1', binding, 'InputValCBase1(), CBase1 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputValCBase2(cb2)', '2', binding, 'InputValCBase2(), CBase2 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputValCBase1(b1)', '1', binding, 'InputValCBase1(), Bottom1 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputValCBase1(b2)', '1', binding, 'InputValCBase1(), Bottom2 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputValCBase1(b3)', '1', binding, 'InputValCBase1(), Bottom3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputValCBase2(b3)', '2', binding, 'InputValCBase2(), Bottom3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputValCBase2(b1)', '2', binding, 'InputValCBase2(), Bottom1 as a parameter failed')

# pointer parameters
# test ABase1 as a parameter
swig_assert_equal('Multiple_inheritance_nspace::InputPtrABase1(d2)', '5', binding, 'InputPtrABase1() through Derived2 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrABase1(d3)', '9', binding, 'InputPtrABase1() through Derived3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrABase1(b2)', '205', binding, 'InputPtrABase1() through Bottom2 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrABase1(b3)', '309', binding, 'InputPtrABase1() through Bottom3 as a parameter failed')

# test CBase1 CBase2 as parameters
swig_assert_equal('Multiple_inheritance_nspace::InputPtrCBase1(d1)', '3', binding, 'InputPtrCBase1(), Derived1 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrCBase1(d2)', '6', binding, 'InputPtrCBase1(), Derived2 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrCBase1(d3)', '7', binding, 'InputPtrCBase1(), Derived3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrCBase2(d3)', '8', binding, 'InputPtrCBase2(), Derived3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrCBase2(d1)', '4', binding, 'InputPtrCBase2(), Derived1 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrCBase1(cb1)', '1', binding, 'InputPtrCBase1(), CBase1 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrCBase2(cb2)', '2', binding, 'InputPtrCBase2(), CBase2 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrCBase1(b1)', '103', binding, 'InputPtrCBase1(), Bottom1 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrCBase1(b2)', '206', binding, 'InputPtrCBase1(), Bottom2 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrCBase1(b3)', '307', binding, 'InputPtrCBase1(), Bottom3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrCBase2(b3)', '308', binding, 'InputPtrCBase2(), Bottom3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrCBase2(b1)', '104', binding, 'InputPtrCBase2(), Bottom1 as a parameter failed')

# reference parameters
# test ABase1 as a parameter
swig_assert_equal('Multiple_inheritance_nspace::InputRefABase1(d2)', '5', binding, 'InputRefABase1() through Derived2 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefABase1(d3)', '9', binding, 'InputRefABase1() through Derived3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefABase1(b2)', '205', binding, 'InputRefABase1() through Bottom2 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefABase1(b3)', '309', binding, 'InputRefABase1() through Bottom3 as a parameter failed')

# test CBase1 CBase2 as parameters
swig_assert_equal('Multiple_inheritance_nspace::InputRefCBase1(d1)', '3', binding, 'InputRefCBase1(), Derived1 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefCBase1(d2)', '6', binding, 'InputRefCBase1(), Derived2 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefCBase1(d3)', '7', binding, 'InputRefCBase1(), Derived3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefCBase2(d3)', '8', binding, 'InputRefCBase2(), Derived3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefCBase2(d1)', '4', binding, 'InputRefCBase2(), Derived1 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefCBase1(cb1)', '1', binding, 'InputRefCBase1(), CBase1 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefCBase2(cb2)', '2', binding, 'InputRefCBase2(), CBase2 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefCBase1(b1)', '103', binding, 'InputRefCBase1(), Bottom1 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefCBase1(b2)', '206', binding, 'InputRefCBase1(), Bottom2 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefCBase1(b3)', '307', binding, 'InputRefCBase1(), Bottom3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefCBase2(b3)', '308', binding, 'InputRefCBase2(), Bottom3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefCBase2(b1)', '104', binding, 'InputRefCBase2(), Bottom1 as a parameter failed')

# const reference pointer parameters
# test ABase1 as a parameter
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefABase1(d2)', '5', binding, 'InputCPtrRefABase1() through Derived2 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefABase1(d3)', '9', binding, 'InputCPtrRefABase1() through Derived3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefABase1(b2)', '205', binding, 'InputCPtrRefABase1() through Bottom2 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefABase1(b3)', '309', binding, 'InputCPtrRefABase1() through Bottom3 as a parameter failed')

# test CBase1 CBase2 as parameters
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefCBase1(d1)', '3', binding, 'InputCPtrRefCBase1(), Derived1 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefCBase1(d2)', '6', binding, 'InputCPtrRefCBase1(), Derived2 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefCBase1(d3)', '7', binding, 'InputCPtrRefCBase1(), Derived3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefCBase2(d3)', '8', binding, 'InputCPtrRefCBase2(), Derived3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefCBase2(d1)', '4', binding, 'InputCPtrRefCBase2(), Derived1 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefCBase1(cb1)', '1', binding, 'InputCPtrRefCBase1(), CBase1 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefCBase2(cb2)', '2', binding, 'InputCPtrRefCBase2(), CBase2 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefCBase1(b1)', '103', binding, 'InputCPtrRefCBase1(), Bottom1 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefCBase1(b2)', '206', binding, 'InputCPtrRefCBase1(), Bottom2 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefCBase1(b3)', '307', binding, 'InputCPtrRefCBase1(), Bottom3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefCBase2(b3)', '308', binding, 'InputCPtrRefCBase2(), Bottom3 as a parameter failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefCBase2(b1)', '104', binding, 'InputCPtrRefCBase2(), Bottom1 as a parameter failed')

# derived classes as parameters
swig_assert_equal('Multiple_inheritance_nspace::InputValDerived1(d1)', '3+4', binding, 'InputValDerived1() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputValDerived2(d2)', '6+5', binding, 'InputValDerived2() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputValDerived3(d3)', '7+8+9', binding, 'InputValDerived3() failed')

swig_assert_equal('Multiple_inheritance_nspace::InputRefDerived1(d1)', '3+4', binding, 'InputRefDerived1() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefDerived2(d2)', '6+5', binding, 'InputRefDerived2() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefDerived3(d3)', '7+8+9', binding, 'InputRefDerived3() failed')

swig_assert_equal('Multiple_inheritance_nspace::InputPtrDerived1(d1)', '3+4', binding, 'InputPtrDerived1() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrDerived2(d2)', '6+5', binding, 'InputPtrDerived2() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrDerived3(d3)', '7+8+9', binding, 'InputPtrDerived3() failed')

swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefDerived1(d1)', '3+4', binding, 'InputCPtrRefDerived1() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefDerived2(d2)', '6+5', binding, 'InputCPtrRefDerived2() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefDerived3(d3)', '7+8+9', binding, 'InputCPtrRefDerived3() failed')

# bottom classes as Derived parameters
swig_assert_equal('Multiple_inheritance_nspace::InputValDerived1(b1)', '3+4', binding, 'InputValDerived1() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputValDerived2(b2)', '6+5', binding, 'InputValDerived2() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputValDerived3(b3)', '7+8+9', binding, 'InputValDerived3() failed')

swig_assert_equal('Multiple_inheritance_nspace::InputRefDerived1(b1)', '103+104', binding, 'InputRefDerived1() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefDerived2(b2)', '206+205', binding, 'InputRefDerived2() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefDerived3(b3)', '307+308+309', binding, 'InputRefDerived3() failed')

swig_assert_equal('Multiple_inheritance_nspace::InputPtrDerived1(b1)', '103+104', binding, 'InputPtrDerived1() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrDerived2(b2)', '206+205', binding, 'InputPtrDerived2() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrDerived3(b3)', '307+308+309', binding, 'InputPtrDerived3() failed')

swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefDerived1(b1)', '103+104', binding, 'InputCPtrRefDerived1() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefDerived2(b2)', '206+205', binding, 'InputCPtrRefDerived2() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefDerived3(b3)', '307+308+309', binding, 'InputCPtrRefDerived3() failed')

# bottom classes as Bottom parameters
swig_assert_equal('Multiple_inheritance_nspace::InputValBottom1(b1)', '103+104', binding, 'InputValBottom1() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputValBottom2(b2)', '206+205', binding, 'InputValBottom2() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputValBottom3(b3)', '307+308+309', binding, 'InputValBottom3() failed')

swig_assert_equal('Multiple_inheritance_nspace::InputRefBottom1(b1)', '103+104', binding, 'InputRefBottom1() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefBottom2(b2)', '206+205', binding, 'InputRefBottom2() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputRefBottom3(b3)', '307+308+309', binding, 'InputRefBottom3() failed')

swig_assert_equal('Multiple_inheritance_nspace::InputPtrBottom1(b1)', '103+104', binding, 'InputPtrBottom1() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrBottom2(b2)', '206+205', binding, 'InputPtrBottom2() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputPtrBottom3(b3)', '307+308+309', binding, 'InputPtrBottom3() failed')

swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefBottom1(b1)', '103+104', binding, 'InputCPtrRefBottom1() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefBottom2(b2)', '206+205', binding, 'InputCPtrRefBottom2() failed')
swig_assert_equal('Multiple_inheritance_nspace::InputCPtrRefBottom3(b3)', '307+308+309', binding, 'InputCPtrRefBottom3() failed')

# return pointers
swig_assert_equal('Multiple_inheritance_nspace::MakePtrDerived1_CBase1().cbase1y', '3', binding, 'MakePtrDerived1_CBase1 failed')
swig_assert_equal('Multiple_inheritance_nspace::MakePtrDerived1_CBase2().cbase2', '4', binding, 'MakePtrDerived1_CBase2 failed')
swig_assert_equal('Multiple_inheritance_nspace::MakePtrDerived2_CBase1().cbase1y', '6', binding, 'MakePtrDerived2_CBase1 failed')
swig_assert_equal('Multiple_inheritance_nspace::MakePtrDerived2_ABase1().abase1', '5', binding, 'MakePtrDerived2_ABase1 failed')
swig_assert_equal('Multiple_inheritance_nspace::MakePtrDerived3_ABase1().abase1', '9', binding, 'MakePtrDerived3_ABase1 failed')
swig_assert_equal('Multiple_inheritance_nspace::MakePtrDerived3_CBase1().cbase1y', '7', binding, 'MakePtrDerived3_CBase1 failed')
swig_assert_equal('Multiple_inheritance_nspace::MakePtrDerived3_CBase2().cbase2', '8', binding, 'MakePtrDerived3_CBase2 failed')

# return references
swig_assert_equal('Multiple_inheritance_nspace::MakeRefDerived1_CBase1().cbase1y', '3', binding, 'MakeRefDerived1_CBase1 failed')
swig_assert_equal('Multiple_inheritance_nspace::MakeRefDerived1_CBase2().cbase2', '4', binding, 'MakeRefDerived1_CBase2 failed')
swig_assert_equal('Multiple_inheritance_nspace::MakeRefDerived2_CBase1().cbase1y', '6', binding, 'MakeRefDerived2_CBase1 failed')
swig_assert_equal('Multiple_inheritance_nspace::MakeRefDerived2_ABase1().abase1', '5', binding, 'MakeRefDerived2_ABase1 failed')
swig_assert_equal('Multiple_inheritance_nspace::MakeRefDerived3_ABase1().abase1', '9', binding, 'MakeRefDerived3_ABase1 failed')
swig_assert_equal('Multiple_inheritance_nspace::MakeRefDerived3_CBase1().cbase1y', '7', binding, 'MakeRefDerived3_CBase1 failed')
swig_assert_equal('Multiple_inheritance_nspace::MakeRefDerived3_CBase2().cbase2', '8', binding, 'MakeRefDerived3_CBase2 failed')

# return by value (sliced objects)
swig_assert_equal('Multiple_inheritance_nspace::MakeValDerived1_CBase1().cbase1y', '1', binding, 'MakeValDerived1_CBase1 failed')
swig_assert_equal('Multiple_inheritance_nspace::MakeValDerived1_CBase2().cbase2', '2', binding, 'MakeValDerived1_CBase2 failed')
swig_assert_equal('Multiple_inheritance_nspace::MakeValDerived2_CBase1().cbase1y', '1', binding, 'MakeValDerived2_CBase1 failed')
swig_assert_equal('Multiple_inheritance_nspace::MakeValDerived3_CBase1().cbase1y', '1', binding, 'MakeValDerived3_CBase1 failed')
swig_assert_equal('Multiple_inheritance_nspace::MakeValDerived3_CBase2().cbase2', '2', binding, 'MakeValDerived3_CBase2 failed')

