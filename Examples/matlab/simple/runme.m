% file: runme.m

% Call our gcd() function

x = 42
y = 105
g = example.gcd(x,y)
disp(sprintf('The gcd of %d and %d is %d',x,y,g))

% Manipulate the Foo global variable

% Output its current value
example.Foo

% Change its value
example.Foo(3.1415926)

% See if the change took effect
disp(sprintf('Foo = %f', example.Foo))
