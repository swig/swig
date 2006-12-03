require 'using_private'

include Using_private

f = FooBar.new
f.x = 3

if f.blah(4) != 4
  raise RuntimeError, "blah(int)"
end

if f.defaulted() != -1
  raise RuntimeError, "defaulted()"
end

if f.defaulted(222) != 222
  raise RuntimeError, "defaulted(hi)"
end

