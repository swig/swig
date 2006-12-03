require 'overload_subtype'

include Overload_subtype

f = Foo.new
b = Bar.new

if spam(f) != 1
  raise RuntimeError, "foo"
end

if spam(b) != 2
  raise RuntimeError, "bar"
end

