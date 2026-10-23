<?php

require "tests.php";

check::equal(char_input_array("ab"), ord("a"), "char_input_array(\"ab\")");
check::equal(char_input_array(null), -1, "char_input_array(null)");

check::done();
