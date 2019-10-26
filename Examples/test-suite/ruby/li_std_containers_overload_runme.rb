#!/usr/bin/env ruby
#
# Put description here
#
# 
# 
# 
#

require 'swig_assert'

require 'li_std_containers_overload'

include Li_std_containers_overload

def check(got, expected)
  if (got != expected)
    raise RuntimeError, "Failed check. '#{got}' != '#{expected}'"
  end
end

v = VectorX.new()
check(VectorOverload(v), "vector<X>")

v = VectorY.new()
check(VectorOverload(v), "vector<Y>")

v = VectorInt.new()
check(VectorOverload(v), "vector<int>")

v = VectorString.new()
check(VectorOverload(v), "vector<string>")

v = [X.new()]
check(VectorOverload(v), "vector<X>")

v = [Y.new()]
check(VectorOverload(v), "vector<Y>")

v = [1, 2, 3]
check(VectorOverload(v), "vector<int>")

v = ["aaa", "bbb", "ccc"]
check(VectorOverload(v), "vector<string>")
