#!/usr/bin/env ruby
#
# Put script description here.
#
# Author::    
# Copyright:: 
# License::   Ruby
#

require 'swig_assert'
require 'argout'

include Argout

t = new_intp
intp_assign(t, 5)
v = incp(t)
swig_assert( v == 5, "incp - v == 5 was #{v}")
val = intp_value(t)
swig_assert( val == 6, "incp - intp_value(t) == 6 was #{val}")

t = new_intp
intp_assign(t, 5)
v = incr(t)
swig_assert( v == 5, "incr - v == 5 was #{v}")
val = intp_value(t)
swig_assert( val == 6, "incr - intp_value(t) == 6 was #{val}")

t = new_intp
intp_assign(t, 5)
v = inctr(t)
swig_assert( v == 5, "inctr - v == 5 was #{v}")
val = intp_value(t)
swig_assert( val == 6, "inctr - intp_value(t) == 6 was #{val}")


#
# @todo: how to use voidhandle and handle?
#

