#!/usr/bin/env ruby
#
# Test for charptr_fragment.i
#

require 'swig_assert'
require 'charptr_fragment'

if Charptr_fragment.getCharBuf != 'hello'
  raise RuntimeError, "getCharBuf failed"
end

if Charptr_fragment.getBinaryCharBuf != 'hello'
  raise RuntimeError, "getBinaryCharBuf failed"
end
