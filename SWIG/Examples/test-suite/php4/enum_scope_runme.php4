<?php
// Sample test file

require "tests.php4";
require "enum_scope.php";

check::classes("tree");
check::functions("chops");
check::equal(0,Tree_Oak,"0==Tree_Oak");
check::equal(1,Tree_Fir,"1==Tree_Fir");
check::equal(2,Tree_Cedar,"2==Tree_Cedar");
check::equal(Tree_Oak,chops(Tree_Oak),"Tree_Oak==chops(Tree_Oak)");
check::equal(Tree_Fir,chops(Tree_Fir),"Tree_Fir==chops(Tree_Fir)");
check::equal(Tree_Cedar,chops(Tree_Cedar),"Tree_Cedar==chops(Tree_Cedar)");

check::done();
?>
