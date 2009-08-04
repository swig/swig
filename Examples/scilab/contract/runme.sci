// builder the *.so
exec example_builder.sce;

// loader the *.so
exec loader.sce;

// Call our gcd() function
x = 42;
y = 105;
g = gcd(x,y);
printf("The gcd of %d and %d is %d\n",x,y,g);

// Call our fact() function
x=5;
g=fact(x);
printf("The fact of %d is %d",x,g);

// Manipulate the Foo global variable

// Output its current value
printf("Foo = %f\n",Foo_get());

// Change its value
Foo_set (3.1415926);

// See if the change took effect
printf("Foo = %f\n", Foo_get());

//Call our gcd() function to test the contract conditon
x=-42;
y=105;
g=gcd(x,y);
printf("The gcd of %d and %d is %d\n",x,y,g);

exit



