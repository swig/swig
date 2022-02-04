<?php
require "tests.php";

# Overloading bool, int, string
check::equal(overloaded(true), "bool", "wrong!");
check::equal(overloaded(false), "bool", "wrong!");

check::equal(overloaded(0), "int", "wrong!");
check::equal(overloaded(1), "int", "wrong!");
check::equal(overloaded(2), "int", "wrong!");

check::equal(overloaded("1234"), "string", "wrong!");

# Test bool masquerading as int
check::equal(intfunction(true), "int", "wrong!");
check::equal(intfunction(false), "int", "wrong!");

# Test int masquerading as bool
check::equal(boolfunction(1), "true", "wrong!");
check::equal(boolfunction(0), "false", "wrong!");

#############################################

# Overloading bool, int, string
check::equal(overloaded_ref(true), "bool", "wrong!");
check::equal(overloaded_ref(false), "bool", "wrong!");

check::equal(overloaded_ref(0), "int", "wrong!");
check::equal(overloaded_ref(1), "int", "wrong!");
check::equal(overloaded_ref(2), "int", "wrong!");

check::equal(overloaded_ref("1234"), "string", "wrong!");

# Test bool masquerading as int
check::equal(intfunction_ref(true), "int", "wrong!");
check::equal(intfunction_ref(false), "int", "wrong!");

# Test int masquerading as bool
check::equal(boolfunction(1), "true", "wrong!");
check::equal(boolfunction(0), "false", "wrong!");

check::done();
