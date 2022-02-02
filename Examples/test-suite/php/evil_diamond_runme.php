<?php

require "tests.php";

check::classes(array("evil_diamond","foo","bar","baz","spam"));
check::functions("test");
check::is_a("bar","foo");
check::is_a("baz","foo");
check::is_a("spam","foo");
check::is_a("spam","bar");
//No multiple inheritance
//check::is_a("spam","baz");

check::done();
