<?php

require "tests.php";

check::functions(array('incp','incr','inctr','new_intp','copy_intp','delete_intp','intp_assign','intp_value','voidhandle','handle'));

$ip=copy_intp(42);
check::equal(42,incp($ip),"42==incp($ip)");
check::equal(43,intp_value($ip),"43=$ip");

$p=copy_intp(2);
check::equal(2,incp($p),"2==incp($p)");
check::equal(3,intp_value($p),"3==$p");

$r=copy_intp(7);
check::equal(7,incr($r),"7==incr($r)");
check::equal(8,intp_value($r),"8==$r");

$tr=copy_intp(4);
check::equal(4,inctr($tr),"4==incr($tr)");
check::equal(5,intp_value($tr),"5==$tr");

# Check the voidhandle call, first with NULL and then with the SWIG\p_void we
# get from the first call.
$handle=NULL;
for ($i=0; $i != 1; $i++) {
  voidhandle($handle);
  check::equal(get_class($handle),"SWIG\\_p_void",'$handle is not _p_void');
  $handledata=handle($handle);
  check::equal($handledata,"Here it is","\$handledata != \"Here it is\"");
}

check::done();
