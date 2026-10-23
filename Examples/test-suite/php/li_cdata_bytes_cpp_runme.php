<?php

require "tests.php";

check::functions(array('predefStr', 'cdata', 'malloc', 'memmove', 'verifyBytes', 'free'));
check::classes(array('li_cdata_bytes_cpp'));
// No new vars
check::globals(array());

$m = predefStr();
$s = cdata($m, 0x200);

for($i = 0; $i < 0x100; ++$i) {
  $v = ord($s[$i]);
  check::equal($v, $i, "Value $v should be $i at index $i");
  $i2 = $i + 0x100;
  $v = ord($s[$i2]);
  check::equal($v, $i, "Value $v should be $i at index $i2");
}
for($i = 0; $i < 0x100; ++$i) {
  $d = chr(0x100 - 1 - $i);
  $s[$i] = $d;
  $s[$i + 0x100] = $d;
}
$m2 = malloc(0x200);
memmove($m2, $s);
check::equal(verifyBytes($m2), 0, "verifyBytes fail");
free($m2);
