<?php

require "tests.php";
require "newobject3.php";

$factory = new factory();

check::classname("Product", $factory->create(7));
check::classname("Product", $factory->create(7, 6));
check::classname("Product", $factory->create("test"));
check::classname("Product", $factory->create("test", 2));

check::isnull($factory->create(0), "create(0) should be NULL");
check::isnull($factory->create(7, -1), "create(7, -1) should be NULL");
check::isnull($factory->create(0, -1), "create(0, -1) should be NULL");
check::isnull($factory->create("bad", -1), "create(\"bad\", -1) should be NULL");

?>
