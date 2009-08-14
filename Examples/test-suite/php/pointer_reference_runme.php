<?php

require "tests.php";
require "pointer_reference.php";

$s  = get();
check::equal(Struct_value_get($s), 10, "pointer_reference.get failed");

$ss = new_Struct(20);
set($ss);
check::equal(Struct_value_get(Struct_instance()), 20, "pointer_reference.set failed");

check::done();
?>
