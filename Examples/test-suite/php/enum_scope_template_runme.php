<?php
require "tests.php";
require "enum_scope_template.php";

check::classes(array("enum_scope_template", "TreeInt"));
check::functions(array("chops","treeint_chops"));
check::equal(0,TreeInt::Oak,"0==TreeInt_Oak");
check::equal(1,TreeInt::Fir,"1==TreeInt_Fir");
check::equal(2,TreeInt::Cedar,"2==TreeInt_Cedar");
check::equal(TreeInt::Oak,chops(TreeInt::Oak),"TreeInt_Oak==chops(TreeInt_Oak)");
check::equal(TreeInt::Fir,chops(TreeInt::Fir),"TreeInt_Fir==chops(TreeInt_Fir)");
check::equal(TreeInt::Cedar,chops(TreeInt::Cedar),"TreeInt_Cedar==chops(TreeInt_Cedar)");

check::done();
?>
