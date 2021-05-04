<?php
require "tests.php";

check::functions(array("chops"));
check::classes(array("enum_scope_template", "TreeInt"));
// No new vars
check::globals(array());

check::equal(0,TreeInt::Oak,"0==TreeInt_Oak");
check::equal(1,TreeInt::Fir,"1==TreeInt_Fir");
check::equal(2,TreeInt::Cedar,"2==TreeInt_Cedar");
check::equal(TreeInt::Oak,chops(TreeInt::Oak),"TreeInt_Oak==chops(TreeInt_Oak)");
check::equal(TreeInt::Fir,chops(TreeInt::Fir),"TreeInt_Fir==chops(TreeInt_Fir)");
check::equal(TreeInt::Cedar,chops(TreeInt::Cedar),"TreeInt_Cedar==chops(TreeInt_Cedar)");

check::done();
