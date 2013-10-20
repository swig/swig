#!/usr/bin/perl
use strict;
use warnings;

# This file illustrates the manipulation of C++ references in Perl.
# This uses the low-level interface.  Proxy classes work differently.

use example;

# ----- Object creation -----

print "Creating some objects:\n";
my $a = example::new_Vector(3,4,5);
my $b = example::new_Vector(10,11,12);

print "    Created",example::Vector_print($a),"\n";
print "    Created",example::Vector_print($b),"\n";

# ----- Call an overloaded operator -----

# This calls the wrapper we placed around
#
#      operator+(const Vector &a, const Vector &) 
#
# It returns a new allocated object.

print "Adding a+b\n";
my $c = example::addv($a,$b);
print "    a+b =", example::Vector_print($c),"\n";

# Note: Unless we free the result, a memory leak will occur
undef $c;

# ----- Create a vector array -----

# Note: Using the high-level interface here
print "Creating an array of vectors\n";
my $va = example::new_VectorArray(10);
print "    va = $va\n";

# ----- Set some values in the array -----

# These operators copy the value of $a and $b to the vector array
example::VectorArray_set($va,0,$a);
example::VectorArray_set($va,1,$b);

# This will work, but it will cause a memory leak!

example::VectorArray_set($va,2,example::addv($a,$b));

# The non-leaky way to do it

$c = example::addv($a,$b);
example::VectorArray_set($va,3,$c);
undef $c;

# Get some values from the array

print "Getting some array values\n";
for (my $i = 0; $i < 5; $i++) {
    print "    va($i) = ", example::Vector_print(example::VectorArray_get($va,$i)), "\n";
}

# Watch under resource meter to check on this
print "Making sure we don't leak memory.\n";
for (my $i = 0; $i < 1000000; $i++) {
    $c = example::VectorArray_get($va,$i % 10);
}

# ----- Clean up -----
print "Cleaning up\n";

undef $va;
undef $a;
undef $b;

