lines(0);
ilib_verbose(0);
exec loader.sce;

// Call our gcd() function
x = 42;
y = 105;
g = gcd(x, y);
printf("The gcd of %d and %d is %d\n", x, y, g);

// Call our fact() function
x = 5;
g = fact(x);
printf("The fact of %d is %d\n", x, g);

// Manipulate the Foo global variable

// Output its current value
printf("Foo = %f\n", Foo_get());

// Change its value
Foo_set(3.1415926);

// See if the change took effect
printf("Foo = %f\n", Foo_get());

// Check error message if violate contract
try
    g = gcd(-42, 105);
    error("g = gcd(-42, 105) must provoke a RunTimeError");
catch

end

try
    fact(-4);
    error("fact(-4) must provoke a RunTimeError");
catch
end

exit



