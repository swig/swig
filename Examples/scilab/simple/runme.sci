// loader the *.so
exec loader.sce;

// Call our gcd() function

x = 42;
y = 105;
g = gcd(x,y);
printf("The gcd of %d and %d is %d\n",x,y,g);

// Manipulate the Foo global variable

// Output its current value
Foo_get()

// Change its value
Foo_set(3.1415926)

// See if the change took effect
if Foo_get() <> 3.1415926 then pause,end

exit

