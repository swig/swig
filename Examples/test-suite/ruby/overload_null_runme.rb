#!/usr/bin/env ruby
#
# Put script description here.
#
# 
# 
# 
#

require 'swig_assert'
require 'overload_null'

include Overload_null

o = Overload.new
x = X.new

swig_assert(1 == o.byval1(x))
swig_assert(2 == o.byval1(nil))

swig_assert(3 == o.byval2(nil))
swig_assert(4 == o.byval2(x))

swig_assert(5 == o.byref1(x))
swig_assert(6 == o.byref1(nil))

swig_assert(7 == o.byref2(nil))
swig_assert(8 == o.byref2(x))

swig_assert(9 == o.byconstref1(x))
swig_assert(10 == o.byconstref1(nil))

swig_assert(11 == o.byconstref2(nil))
swig_assert(12 == o.byconstref2(x))

# const pointer references
swig_assert(13 == o.byval1cpr(x))
swig_assert(14 == o.byval1cpr(nil))

swig_assert(15 == o.byval2cpr(nil))
swig_assert(16 == o.byval2cpr(x))

# forward class declaration
swig_assert(17 == o.byval1forwardptr(x))
swig_assert(18 == o.byval1forwardptr(nil))

swig_assert(19 == o.byval2forwardptr(nil))
swig_assert(20 == o.byval2forwardptr(x))

swig_assert(21 == o.byval1forwardref(x))

swig_assert(22 == o.byval2forwardref(x))
