<?php

require "tests.php4";
require "argout.php";

check::functions(array(incp,incr));

$p=2;
check::equal(2,incp(&$p),"2==incp($p)");
check::equal(3,$p,"3==$p");

$r=7;
check::equal(7,incr(&$r),"7==incr($r)");
check::equal(8,$r,"8==$r");

echo $_SERVER[argv][0]." ok\n";
?>
