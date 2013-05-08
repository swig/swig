# file: runme.m

swigexample

# Call our gcd() function

x = 42
y = 105
g = swigexample.gcd(x,y)
printf("The gcd of %d and %d is %d\n",x,y,g);

# Manipulate the Foo global variable

# Output its current value
swigexample.cvar.Foo

# Change its value
swigexample.cvar.Foo = 3.1415926

# See if the change took effect
printf("Foo = %f\n", swigexample.cvar.Foo);
