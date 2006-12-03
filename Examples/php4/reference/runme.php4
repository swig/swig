<?php

# This file illustrates the manipulation of C++ references in Php.
# This uses the low-level interface.  Shadow classes work differently.

require "example.php";

# ----- Object creation -----

print "Creating some objects:\n";
$a = new_Vector(3,4,5);
$b = new_Vector(10,11,12);

print "    Created a: $a " . Vector_print($a) . "\n";
print "    Created b: $b " . Vector_print($b) . "\n";

# ----- Call an overloaded operator -----

# This calls the wrapper we placed around
#
#      operator+(const Vector &a, const Vector &) 
#
# It returns a new allocated object.

print "Adding a+b\n";
$c = addv($a,$b);
print "    a+b =". Vector_print($c)."\n";

# Note: Unless we free the result, a memory leak will occur
$c = None;

# ----- Create a vector array -----

# Note: Using the high-level interface here
print "Creating an array of vectors\n";
$va = new_VectorArray(10);

print "    va: $va size=".VectorArray_size($va)."\n";

# ----- Set some values in the array -----

# These operators copy the value of $a and $b to the vector array
VectorArray_set($va,0,$a);
VectorArray_set($va,1,$b);

VectorArray_get($va,0);
# This will work, but it will cause a memory leak!

VectorArray_set($va,2,addv($a,$b));

# The non-leaky way to do it

$c = addv($a,$b);
VectorArray_set($va,3,$c);
$c = None;

# Get some values from the array

print "Getting some array values\n";
for ($i = 0; $i < 5; $i++) {
print "do $i\n";
    print "    va($i) = ". Vector_print(VectorArray_get($va,$i)). "\n";
}

# Watch under resource meter to check on this
#print "Making sure we don't leak memory.\n";
#for ($i = 0; $i < 1000000; $i++) {
#    $c = VectorArray_get($va,$i % 10);
#}

# ----- Clean up -----
print "Cleaning up\n";
# wants fixing FIXME
$va = None;
$a = None;
$b = None;

?>
