require 'profiletest'

a = Profiletest::A.new()
b = Profiletest::B.new()

for i in 0...1000000
  a = b.fn(a)
end

