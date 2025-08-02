<?php

require "tests.php";

// No new functions
check::functions(array());
check::classes(array('director_binary_string_rev_len','Callback','Caller'));
// No new vars
check::globals(array());

class DirectorBinaryStringCallback extends Callback {
  function run(string $dataBufferAA)
  {
    $ret = 0;
    if ($dataBufferAA != null) {
      for ($i = 0; $i < strlen($dataBufferAA); $i++)
        $ret = $ret + ord($dataBufferAA[$i]) * 2;
    }
    return $ret;
  }
}

$callback = new DirectorBinaryStringCallback();
$caller = new Caller($callback);
$sum = $caller->call();

check::equal($sum, 9*2*8, "Unexpected sum: $sum");
