<?php
// Sample test file

require "tests.php4";
require "enum_scope_template.php";

check::classes("treeint");
check::functions("chops");
check::equal(0,TreeInt_Oak,"0==TreeInt_Oak");
check::equal(1,TreeInt_Fir,"0==TreeInt_Fir");
check::equal(2,TreeInt_Cedar,"0==TreeInt_Cedar");
check::equal(TreeInt_Oak,chops(TreeInt_Oak),"TreeInt_Oak==chops(TreeInt_Oak)");
check::equal(TreeInt_Fir,chops(TreeInt_Fir),"TreeInt_Fir==chops(TreeInt_Fir)");
check::equal(TreeInt_Cedar,chops(TreeInt_Cedar),"TreeInt_Cedar==chops(TreeInt_Cedar)");

check::done();
?>
