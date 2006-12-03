<?php

# This file illustrates the manipulation of C++ references in Php.
# This uses the low-level interface.  Shadow classes work differently.

require "example.php";

# ----- Object creation -----

print "Creating some objects:\n";
$a = new Vector(3,4,5);
$b = new Vector(10,11,12);

print "    Created a: $a " . $a->print() . "\n";
print "    Created b: $b " . $b->print() . "\n";

# ----- Call an overloaded operator -----

# This calls the wrapper we placed around
#
#      operator+(const Vector &a, const Vector &) 
#
# It returns a new allocated object.

print "Adding a+b\n";
$c = addv($a,$b);
print "    a+b =". $c->print()."\n";

# Note: Unless we free the result, a memory leak will occur
$c = 0;

# ----- Create a vector array -----

# Note: Using the high-level interface here
print "Creating an array of vectors\n";
$va = new VectorArray(10);

print "    va: $va size=".$va->size()."\n";

# ----- Set some values in the array -----

# These operators copy the value of $a and $b to the vector array
$va->set(0,$a);
$va->set(1,$b);

$va->get(0);
# This will work, but it will cause a memory leak!

$va->set(2,addv($a,$b));

# The non-leaky way to do it

$c = addv($a,$b);
$va->set(3,$c);
$c = NULL;

# Get some values from the array

print "Getting some array values\n";
for ($i = 0; $i < 5; $i++) {
print "do $i\n";
    $v = $va->get($i);
    print "    va($i) = ". $v->print(). "\n";
}

# Watch under resource meter to check on this
#print "Making sure we don't leak memory.\n";
#for ($i = 0; $i < 1000000; $i++) {
#    $c = VectorArray_get($va,$i % 10);
#}

# ----- Clean up -----
print "Cleaning up\n";
# wants fixing FIXME
#delete_VectorArray($va);
#delete_Vector($a);
#delete_Vector($b);

?>
