require 'varargs'

if Varargs.test("Hello") != "Hello"
  raise RuntimeError, "Failed"
end

f = Varargs::Foo.new
if f.test("Hello") != "Hello"
  raise RuntimeError, "Failed"
end

