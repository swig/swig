% file: runme.m

% Call our gcd() function

x = 42
y = 105
g = swigexample.gcd(x,y)
disp(sprintf('The gcd of %d and %d is %d',x,y,g))

% Manipulate the Foo global variable

% Output its current value
swigexample.Foo

% Change its value
swigexample.Foo(3.1415926)

% See if the change took effect
disp(sprintf('Foo = %f', swigexample.Foo))
