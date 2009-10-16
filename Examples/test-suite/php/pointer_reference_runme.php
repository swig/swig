<?php

require "tests.php";
require "pointer_reference.php";

$s  = pointer_reference::get();
check::equal($s->value, 10, "pointer_reference::get() failed");

$ss = new Struct(20);
pointer_reference::set($ss);
$i = Struct::instance();
check::equal($i->value, 20, "pointer_reference::set() failed");

check::done();
?>
