# Operator overloading example
require 'example'

a = Example::Complex.new(2,3)
b = Example::Complex.new(-5,10)

puts "a   = #{a}"
puts "b   = #{b}"

c = a + b
puts "c   = #{c}"
puts "a*b = #{a*b}"
puts "a-c = #{a-c}"

e = Example::ComplexCopy(a-c)
puts "e   = #{e}"

# Big expression
f = ((a+b)*(c+b*e)) + (-a)
puts "f   = #{f}"

