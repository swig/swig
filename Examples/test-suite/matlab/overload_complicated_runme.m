import overload_complicated.*

pInt = None;

% Check the correct constructors are available
p = Pop(pInt);

p = Pop(pInt, 0);

% Check overloaded in const only and pointers/references which target languages cannot disambiguate
if (p.hip(0) ~= 701)
  error('Test 1 failed')
end

if (p.hip(pInt) ~= 702)
  error('Test 2 failed')
end

% Reverse the order for the above
if (p.hop(pInt) ~= 805)
  error('Test 3 failed')
end

if (p.hop(0) ~= 801)
  error('Test 4 failed')
end

% Few more variations and order shuffled
if (p.pop(0) ~= 901)
  error('Test 5 failed')
end

if (p.pop(pInt) ~= 902)
  error('Test 6 failed')
end

if (p.pop() ~= 905)
  error('Test 7 failed')
end

% Overload on const only
if (p.bop(pInt) ~= 1001)
  error('Test 8 failed')
end

if (p.bip(pInt) ~= 2001)
  error('Test 9 failed')
end

% Globals
if (muzak(0) ~= 3001)
  error('Test 10 failed')
end

if (muzak(pInt) ~= 3002)
  error('Test 11 failed')
end

