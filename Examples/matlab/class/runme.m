% file: runme.m

% This file illustrates the proxy class C++ interface generated
% by SWIG.

% ----- Object creation -----

disp('Creating some objects:')
c = example.Circle(10);
s = example.Square(10);
u = example.CircleInscribedInSquare(10);

% ----- Access a static member -----

disp(sprintf('A total of %i shapes were created', example.Shape.nshapes));

% ----- Member data access -----

% Set the location of the object

c.x = 20;
c.y = 30;

s.x = -10;
s.y = 5;

u.x = 1;
u.y = 1;

disp(sprintf('Here is their current position:'))
disp(sprintf('    Circle = (%f, %f)',c.x,c.y))
disp(sprintf('    Square = (%f, %f)',s.x,s.y))
disp(sprintf(' CinSquare = (%f, %f)',u.x,u.y))

% ----- Call some methods -----

disp('Here are some properties of the shapes:')
for i=0:2
  if i==0
    o = c;
  elseif i==1
    o = s;
  elseif i==2
    o = u;
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
clear u

disp(sprintf('%i shapes remain', example.Shape.nshapes));
disp('Goodbye')
