# Example using pointers to member functions

catch { load ./example[info sharedlibextension] example}

# Get the pointers

set area_pt [ areapt ]
set perim_pt [ perimeterpt ]

puts "area_pt  = $area_pt"
puts "perim_pt = $perim_pt"

# Create some objects

set c [Circle -args 4]
set s [Square -args 10]

# Do some calculations

puts "Circle area  = [do_op $c $area_pt]"
puts "Circle perim = [do_op $c $perim_pt]"
puts "Square area  = [do_op $s $area_pt]"
puts "Square perim = [do_op $s $perim_pt]"

puts "areavar      = $areavar";
puts "perimetervar = $perimetervar";

# Try the variables
puts "Circle area  = [do_op $c $areavar]"
puts "Circle perim = [do_op $c $perimetervar]"
puts "Square area  = [do_op $s $areavar]"
puts "Square perim = [do_op $s $perimetervar]"

# Modify one of the variables
set areavar $perim_pt

puts "Circle perimeter = [do_op $c $areavar]"

# Try the constants

puts "example.AREAPT = $AREAPT"
puts "example.PERIMPT= $PERIMPT"
puts "example.NULLPT = $NULLPT"

puts "Circle area  = [do_op $c $AREAPT]"
puts "Circle perim = [do_op $c $PERIMPT]"
puts "Square area  = [do_op $s $AREAPT]"
puts "Square perim = [do_op $s $PERIMPT]"

