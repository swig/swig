<?php

require "tests.php";

// Test make_optional with value
$v = li_std_optional::make_optional(42);

// Test make_empty_optional
$e = li_std_optional::make_empty_optional();

// Test optional_value_or with value
$r1 = li_std_optional::optional_value_or(li_std_optional::make_optional(10), 99);
check::equal($r1, 10, "optional_value_or with value test failed");

// Test optional_value_or with empty
$r2 = li_std_optional::optional_value_or(li_std_optional::make_empty_optional(), 99);
check::equal($r2, 99, "optional_value_or with empty test failed");

check::done();
