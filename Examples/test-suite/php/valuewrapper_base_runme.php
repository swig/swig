<?php

require "tests.php";

check::classes(array("valuewrapper_base","Base","Interface_BP"));
check::functions("make_interface_bp");

$ibp=valuewrapper_base::make_interface_bp();
check::classname("interface_bp",$ibp);

check::done();
