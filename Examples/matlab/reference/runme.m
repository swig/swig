% file: runme.m

% This file illustrates the manipulation of C++ references in Octave

% ----- Object creation -----

disp(sprintf('Creating some objects:'))
a = swigexample.Vector(3,4,5)
b = swigexample.Vector(10,11,12)

disp(sprintf('    Created %s',a.cprint()))
disp(sprintf('    Created %s',b.cprint()))

% ----- Call an overloaded operator -----

% This calls the wrapper we placed around
%
%      operator+(const Vector &a, const Vector &)
%
% It returns a new allocated object.

disp(sprintf('Adding a+b'))
c = swigexample.addv(a,b);
disp(sprintf('    a+b = %s\n', c.cprint()))

clear c

% ----- Create a vector array -----

% Note: Using the high-level interface here
disp(sprintf('Creating an array of vectors'))
va = swigexample.VectorArray(10)

% ----- Set some values in the array -----

% These operators copy the value of $a and $b to the vector array
va.set(0,a);
va.set(1,b);

va.set(2,swigexample.addv(a,b))

% Get some values from the array

disp(sprintf('Getting some array values'))
for i=0:4,
    disp(sprintf('    va(%d) = %s',i,va.get(i).cprint()))
end

% Watch under resource meter to check on this
disp(sprintf('Making sure we don''t leak memory.'))
for i=0:10000-1, % removed 00
    c = va.get(mod(i,10));
end

% ----- Clean up -----
disp(sprintf('Cleaning up'))

clear va
clear a
clear b
