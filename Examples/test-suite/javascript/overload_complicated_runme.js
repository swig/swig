var overload_complicated = require("overload_complicated");

pInt = null;

// Check the correct constructors are available
p = new overload_complicated.Pop(pInt);

p = new overload_complicated.Pop(pInt, false);

// Check overloaded in const only and pointers/references which target
// languages cannot disambiguate
if (p.hip(false) != 701) {
    throw new Error("Test 1 failed");
}

if (p.hip(pInt) != 702) {
    throw new Error("Test 2 failed");
}

// Reverse the order for the above
if (p.hop(pInt) != 805) {
    throw new Error("Test 3 failed");
}

if (p.hop(false) != 801) {
    throw new Error("Test 4 failed");
}

// Few more variations and order shuffled
if (p.pop(false) != 901) {
    throw new Error("Test 5 failed");
}

if (p.pop(pInt) != 902) {
    throw new Error("Test 6 failed");
}

if (p.pop() != 905) {
    throw new Error("Test 7 failed");
}

// Overload on const only
if (p.bop(pInt) != 1001) {
    throw new Error("Test 8 failed");
}

if (p.bip(pInt) != 2001) {
    throw new Error("Test 9 failed");
}

// Globals
if (overload_complicated.muzak(false) != 3001) {
    throw new Error("Test 10 failed");
}

if (overload_complicated.muzak(pInt) != 3002) {
    throw new Error("Test 11 failed");
}
