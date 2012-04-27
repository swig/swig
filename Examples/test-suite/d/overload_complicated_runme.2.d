module overload_complicated_runme;

import std.exception;
import overload_complicated.overload_complicated;
import overload_complicated.Pop;

void main() {
  int* pInt = new int;

  // Check the correct constructors are available
  auto p = new Pop(pInt);
  p = new Pop(pInt, false);

  // Check overloaded in const only and pointers/references which target languages cannot disambiguate
  enforce(p.hip(false) == 701, "Test 1 failed");
  enforce(p.hip(pInt) == 702, "Test 2 failed");

  // Reverse the order for the above
  enforce(p.hop(pInt) == 805, "Test 3 failed");
  enforce(p.hop(false) == 801, "Test 4 failed");

  // Few more variations and order shuffled
  enforce(p.pop(false) == 901, "Test 5 failed");
  enforce(p.pop(pInt) == 902, "Test 6 failed");
  enforce(p.pop() == 905, "Test 7 failed");

  // Overload on const only
  enforce(p.bop(pInt) == 1001, "Test 8 failed");
  enforce(p.bip(pInt) == 2001, "Test 9 failed");

  // Globals
  enforce(muzak(false) == 3001, "Test 10 failed");
  enforce(muzak(pInt) == 3002, "Test 11 failed");
}
