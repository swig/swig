<?php

require "tests.php";
require "arrays_global_twodim.php";

check::functions(array(fn_taking_arrays,get_2d_array));
check::classes(array(arrays_global_twodim,SimpleStruct,Material));
check::classmethods(SimpleStruct,array(__construct,__set,__isset,__get,double_field_set,double_field_get));
check::classmethods(Material,array(__construct,__set,__isset,__get));

$a1=array(10,11,12,13);
$a2=array(14,15,16,17);
$a=array($a1,$a2);

$_a=check::get(array_const_i);

for($x=0;$x<count($a1);$x++) {
  for($y=0;$y<2;$y++) {
    check::equal($a[$y][$x],get_2d_array($_a,$y,$x),"check array $x,$y");
  }
}

check::done();
?>
