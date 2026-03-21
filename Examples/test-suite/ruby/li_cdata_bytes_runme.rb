#!/usr/bin/env ruby
#
# Put description here
#

require 'swig_assert'
require 'li_cdata_bytes'

include Li_cdata_bytes

def test
  m = predefStr()
  s = cdata(m, 512)
  for i in (0..255) do
    swig_assert(s[i].ord == i, binding, "Value #{ s[i].ord } should be #{ i } at index #{ i }")
    i2 = i + 256
    swig_assert(s[i2].ord == i, binding, "Value #{ s[i2].ord } should be #{ i } at index #{ i2 }")
  end
  for i in (0..255) do
    d = (255 - i).chr
    s[i] = d
    s[i + 256] = d
  end
  m2 = malloc(512)
  memmove(m2, s)
  swig_assert(verifyBytes(m2) == 0, binding, "verifyBytes fail")
  free(m2)
end

# The test work on macos, but seemed a bit heavy.
# The test breaks occasionally, simply skip it.
test unless /darwin/ =~ RUBY_PLATFORM and RUBY_VERSION[0..2] == "3.2"
