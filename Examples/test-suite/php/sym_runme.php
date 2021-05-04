<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('Flim','Flam'));
// No new vars
check::globals(array());

$flim=new flim();
$flam=new flam();

check::equal($flim->hulahoops(),"flim-jam","flim()->hulahoops==flim-jam");
check::equal($flim->jar(),"flim-jar","flim()->jar==flim-jar");
check::equal($flam->jam(),"flam-jam","flam()->jam==flam-jam");
check::equal($flam->jar(),"flam-jar","flam()->jar==flam-jar");

check::done();
