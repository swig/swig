<?php

require "tests.php4";
require "argout.php";

check::functions(array(incp,incr,inctr,new_intp,copy_intp,delete_intp,intp_assign,intp_value,voidhandle,handle));

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

# Check the voidhandle call, first with null
unset($handle);
voidhandle(&$handle);
check::resource($handle,"_p_void",'$handle is not _p_void');
$handledata=handle($handle);
check::equal($handledata,"Here it is","\$handledata != \"Here it is\"");

unset($handle);
// without reference, should fatal error so can't test here
//voidhandle($handle);
//check::isnull($handle,'$handle not null');

check::done();
?>
