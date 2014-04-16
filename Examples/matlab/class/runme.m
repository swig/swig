% file: runme.m

% This file illustrates the proxy class C++ interface generated
% by SWIG.

% ----- Object creation -----

disp('Creating some objects:')
c = swigexample.Circle(10);
s = swigexample.Square(10);

% ----- Access a static member -----

disp(sprintf('A total of %i shapes were created', swigexample.Shape.nshapes));

% ----- Member data access -----

% Set the location of the object

c.x = 20;
c.y = 30;

s.x = -10;
s.y = 5;

disp(sprintf('Here is their current position:'))
disp(sprintf('    Circle = (%f, %f)',c.x,c.y))
disp(sprintf('    Square = (%f, %f)',s.x,s.y))

% ----- Call some methods -----

disp('Here are some properties of the shapes:')
for i=0:1
  if i
    o = c;
  else
    o = s;
  end
  disp(sprintf('  area      = %f', o.area()))
  disp(sprintf('  perimeter = %f', o.perimeter()))
end

% prevent o from holding a reference to the last object looked at
o = [];

disp('Guess I will clean up now')

% Note: this invokes the virtual destructor
clear c
clear s

disp(sprintf('%i shapes remain', swigexample.Shape.nshapes));
disp('Goodbye')
