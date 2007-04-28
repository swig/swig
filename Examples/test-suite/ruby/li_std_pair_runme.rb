#!/usr/bin/env ruby
#
# Put description here
#
# Author::    gga
# Copyright:: 2007
# License::   SWIG
#

require 'swig_assert'

require 'li_std_pair'

include Li_std_pair

#
# Because of template specializations for pair<int, int>, this should return
# an Array of size 2, where both elements are Fixnums.
#
intPair = makeIntPair(7, 6)
raise RuntimeError unless intPair.instance_of?(Array)
raise RuntimeError unless intPair.size == 2
raise RuntimeError unless (intPair[0] == 7 && intPair[1] == 6)

#
# Each of these should return a reference to a wrapped
# std::pair<int, int> object (i.e. an IntPair instance).
#
intPairPtr = makeIntPairPtr(7, 6)
raise RuntimeError unless intPairPtr.instance_of?(IntPair)
raise RuntimeError unless (intPairPtr.first == 7 && intPairPtr.second == 6)

intPairRef = makeIntPairRef(7, 6)
raise RuntimeError unless intPairRef.instance_of?(IntPair)
raise RuntimeError unless (intPairRef.first == 7 && intPairRef.second == 6)

intPairConstRef = makeIntPairConstRef(7, 6)
raise RuntimeError unless intPairConstRef.instance_of?(IntPair)
raise RuntimeError unless (intPairConstRef.first == 7 && intPairConstRef.second == 6)

#
# Now test various input typemaps. Each of the wrapped C++ functions
# (product1, product2 and product3) is expecting an argument of a
# different type (see li_std_pair.i). Typemaps should be in place to
# convert this Array into the expected argument type.
#
raise RuntimeError unless product1(intPair) == 42
raise RuntimeError unless product2(intPair) == 42
raise RuntimeError unless product3(intPair) == 42

#
# Similarly, each of the input typemaps should know what to do
# with an IntPair instance.
#
raise RuntimeError unless product1(intPairPtr) == 42
raise RuntimeError unless product2(intPairPtr) == 42
raise RuntimeError unless product3(intPairPtr) == 42

