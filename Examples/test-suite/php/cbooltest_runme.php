<?php

require "tests.php";

check::equal(cbooltest::do_or(true, false), true, "do_or() test failed");
check::equal(cbooltest::do_and(true, false), false, "do_and() test failed");
check::equal(cbooltest::TRUE_CONSTANT, true, "TRUE_CONSTANT test failed");
check::equal(cbooltest::FALSE_CONSTANT, false, "FALSE_CONSTANT test failed");
