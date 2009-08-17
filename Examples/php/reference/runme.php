<?php

# This file illustrates the manipulation of C++ references in PHP.

require "example.php";

# ----- Object creation -----

print "Creating some objects:\n";
$a = new Vector(3,4,5);
$b = new Vector(10,11,12);

print "    Created a: {$a->as_string()}\n";
print "    Created b: {$b->as_string()}\n";

# ----- Call an overloaded operator -----

# This calls the wrapper we placed around
#
#      operator+(const Vector &a, const Vector &) 
#
# It returns a new allocated object.

print "Adding a+b\n";
$c = example::addv($a,$b);
print "    a+b ={$c->as_string()}\n";

# Note: Unless we free the result, a memory leak will occur
$c = None;

# ----- Create a vector array -----

# Note: Using the high-level interface here
print "Creating an array of vectors\n";
$va = new VectorArray(10);

print "    va: size={$va->size()}\n";

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
    print "    va($i) = {$va->get($i)->as_string()}\n";
}

# Watch under resource meter to check on this
#print "Making sure we don't leak memory.\n";
#for ($i = 0; $i < 1000000; $i++) {
#    $c = $va->get($i % 10);
#}

# ----- Clean up -----
print "Cleaning up\n";
# wants fixing FIXME
$va = NULL;
$a = NULL;
$b = NULL;

?>
