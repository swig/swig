#!/usr/bin/env ruby
#
# This test implementation is directly derived from its C# counterpart.
#

require 'swig_assert'
require 'nested_directors'

# nested classes not yet supported
#class CNested < Nested_directors::Base::Nest
#  def GetValue
#    true
#  end
#end

class CSub < Nested_directors::Sub
  def GetValue
    super
  end
  def Test
    GetValue()
  end
end

#n = CNested.new
#swig_assert('n.GetValue()', binding)

s = CSub.new
swig_assert('s.Test()', binding)
