#!/usr/bin/env ruby
#
# Regression test for a SWIG bug where std::vector<T> cannot be used as a parameter or
# return type across an %import boundary when T is only forward-declared in the
# importing module, while T's real definition and %template(...) std::vector<T> live in
# the imported module. See import_vector_fwd_a.i for the full explanation.
#

require 'swig_assert'

require 'import_vector_fwd_a'
require 'import_vector_fwd_b'

bv = Import_vector_fwd_b::BarVector.new
bv.push(Import_vector_fwd_b::Bar.new)

c = Import_vector_fwd_a::Container.new

swig_assert("c.addBars(bv)", binding)

bars = c.getBars
swig_assert("bars.is_a?(Import_vector_fwd_b::BarVector)", binding)
swig_assert_equal_simple(1, bars.size)
