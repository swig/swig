<?php

require "tests.php4";
require "argout.php";

check::functions(array(incp,incr,inctr,new_intp,copy_intp,delete_intp,intp_assign,intp_value));

$ip=copy_intp(42);
check::equal(42,incp($ip),"42==incp($ip)");
check::equal(43,intp_value($ip),"43=$ip");

$p=2;
check::equal(2,incp(&$p),"2==incp($p)");
check::equal(3,$p,"3==$p");

$r=7;
check::equal(7,incr(&$r),"7==incr($r)");
check::equal(8,$r,"8==$r");

$tr=4;
check::equal(4,inctr(&$tr),"4==incr($tr)");
check::equal(5,$tr,"5==$tr");

echo $_SERVER[argv][0]." ok\n";
?>
