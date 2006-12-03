# Example using pointers to member functions

require 'example'

# Get the pointers

area_pt = Example::areapt
perim_pt = Example::perimeterpt

puts "area_pt  = #{area_pt}"
puts "perim_pt = #{perim_pt}"

# Create some objects

c = Example::Circle.new(4)
s = Example::Square.new(10)

# Do some calculations

puts "Circle area  = #{Example::do_op(c, area_pt)}"
puts "Circle perim = #{Example::do_op(c, perim_pt)}"
puts "Square area  = #{Example::do_op(s, area_pt)}"
puts "Square perim = #{Example::do_op(s, perim_pt)}"

puts "areavar      = #{Example::areavar}"
puts "perimetervar = #{Example::perimetervar}"

# Try the variables
puts "Circle area  = #{Example::do_op(c, Example::areavar)}"
puts "Circle perim = #{Example::do_op(c, Example::perimetervar)}"
puts "Square area  = #{Example::do_op(s, Example::areavar)}"
puts "Square perim = #{Example::do_op(s, Example::perimetervar)}"

# Modify one of the variables
Example::areavar = perim_pt

puts "Circle perimeter = #{Example::do_op(c, Example::areavar)}"

# Try the constants

puts "Example::AREAPT = #{Example::AREAPT}"
puts "Example::PERIMPT= #{Example::PERIMPT}"
puts "Example::NULLPT = #{Example::NULLPT}"

puts "Circle area  = #{Example::do_op(c, Example::AREAPT)}"
puts "Circle perim = #{Example::do_op(c, Example::PERIMPT)}"
puts "Square area  = #{Example::do_op(s, Example::AREAPT)}"
puts "Square perim = #{Example::do_op(s, Example::PERIMPT)}"
