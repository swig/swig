# file: runme.m

# This file illustrates the manipulation of C++ references in Octave

example

# ----- Object creation -----

printf("Creating some objects:\n");
a = example.Vector(3,4,5)
b = example.Vector(10,11,12)

printf("    Created %s\n",a.cprint());
printf("    Created %s\n",b.cprint());

# ----- Call an overloaded operator -----

# This calls the wrapper we placed around
#
#      operator+(const Vector &a, const Vector &) 
#
# It returns a new allocated object.

printf("Adding a+b\n");
c = example.addv(a,b);
printf("    a+b = %s\n", c.cprint());

clear c

# ----- Create a vector array -----

# Note: Using the high-level interface here
printf("Creating an array of vectors\n");
va = example.VectorArray(10)

# ----- Set some values in the array -----

# These operators copy the value of $a and $b to the vector array
va.set(0,a);
va.set(1,b);

va.set(2,example.addv(a,b))

# Get some values from the array

printf("Getting some array values\n");
for i=0:4,
    printf("    va(%d) = %s\n",i,va.get(i).cprint());
end;

# Watch under resource meter to check on this
printf("Making sure we don't leak memory.\n");
for i=0:1000000-1,
    c = va.get(mod(i,10));
end

# ----- Clean up -----
printf("Cleaning up\n");

clear va
clear a
clear b

