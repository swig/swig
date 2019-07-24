# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

overload_complicated

pInt = []; # NULL

# Check the correct constructors are available
p = Pop(pInt);

p = Pop(pInt, false);

# Check overloaded in const only and pointers/references which target languages cannot disambiguate
if (p.hip(false) != 701)
  error("Test 1 failed")
endif

if (p.hip(pInt) != 702)
  error("Test 2 failed")
endif

# Reverse the order for the above
if (p.hop(pInt) != 805)
  error("Test 3 failed")
endif

if (p.hop(false) != 801)
  error("Test 4 failed")
endif

# Few more variations and order shuffled
if (p.pop(false) != 901)
  error("Test 5 failed")
endif

if (p.pop(pInt) != 904)
  error("Test 6 failed")
endif

if (p.pop() != 905)
  error("Test 7 failed")
endif

# Overload on const only
if (p.bop(pInt) != 1001)
  error("Test 8 failed")
endif

if (p.bip(pInt) != 2002)
  error("Test 9 failed")
endif

# Globals
if (muzak(false) != 3001)
  error("Test 10 failed")
endif

if (muzak(pInt) != 3002)
  error("Test 11 failed")
endif

