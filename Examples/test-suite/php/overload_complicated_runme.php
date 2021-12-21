<?php
require "tests.php";

$pInt = NULL;

# Check the correct constructors are available
$p = new Pop($pInt);

$p = new Pop($pInt, false);

# Check overloaded in const only and pointers/references which target
# languages cannot disambiguate
check::equal($p->hip(false), 701, "Test 1 failed");

check::equal($p->hip($pInt), 702, "Test 2 failed");

# Reverse the order for the above
check::equal($p->hop($pInt), 805, "Test 3 failed");

check::equal($p->hop(false), 801, "Test 4 failed");

# Few more variations and order shuffled
check::equal($p->pop(false), 901, "Test 5 failed");

check::equal($p->pop($pInt), 904, "Test 6 failed");

check::equal($p->pop(), 905, "Test 7 failed");

# Overload on const only
check::equal($p->bop($pInt), 1001, "Test 8 failed");

check::equal($p->bip($pInt), 2002, "Test 9 failed");

# Globals
check::equal(muzak(false), 3001, "Test 10 failed");

check::equal(muzak($pInt), 3002, "Test 11 failed");

check::done();
