# Example using pointers to member functions

use example;

# Get the pointers

$area_pt = example::areapt();
$perim_pt = example::perimeterpt();

print "area_pt  =", $area_pt, "\n";
print "perim_pt = ", $perim_pt, "\n";

# Create some objects

$c = new example::Circle(4);
$s = new example::Square(10);

# Do some calculations

print "Circle area  = ", example::do_op($c,$area_pt), "\n";
print "Circle perim = ", example::do_op($c,$perim_pt), "\n";
print "Square area  = ", example::do_op($s,$area_pt), "\n";
print "Square perim = ", example::do_op($s,$perim_pt), "\n";

print "areavar      =", $example::areavar, "\n";
print "perimetervar =", $example::perimetervar, "\n";

# Try the variables
print "Circle area  = ", example::do_op($c,$example::areavar), "\n";
print "Circle perim = ", example::do_op($c,$example::perimetervar), "\n";
print "Square area  = ", example::do_op($s,$example::areavar), "\n";
print "Square perim = ", example::do_op($s,$example::perimetervar), "\n";

# Modify one of the variables
$example::areavar = $perim_pt;

print "Circle perimeter = ", example::do_op($c,$example::areavar), "\n";

# Try the constants

print "example.AREAPT =", $example::AREAPT, "\n";
print "example.PERIMPT=", $example::PERIMPT, "\n";
print "example.NULLPT =", $example::NULLPT, "\n";

print "Circle area  = ", example::do_op($c,$example::AREAPT), "\n";
print "Circle perim = ", example::do_op($c,$example::PERIMPT), "\n";
print "Square area  = ", example::do_op($s,$example::AREAPT), "\n";
print "Square perim = ", example::do_op($s,$example::PERIMPT), "\n";



