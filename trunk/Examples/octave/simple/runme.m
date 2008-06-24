# file: runme.m

example 

# Call our gcd() function

x = 42
y = 105
g = example.gcd(x,y)
printf("The gcd of %d and %d is %d\n",x,y,g);

# Manipulate the Foo global variable

# Output its current value
example.cvar.Foo

# Change its value
example.cvar.Foo = 3.1415926

# See if the change took effect
printf("Foo = %f\n", example.cvar.Foo);

