<?php

require "tests.php";

// No new functions
check::functions(array());
check::classes(array('director_binary_string','Callback','Caller'));
// No new vars
check::globals(array());

class DirectorBinaryStringCallback extends Callback {
  function run(string $dataBufferAA, string $dataBufferBB)
  {
    $ret = 0;
    if ($dataBufferAA != null) {
      for ($i = 0; $i < strlen($dataBufferAA); $i++)
        $ret = $ret + ord($dataBufferAA[$i]) * 2;
    }
    if ($dataBufferBB != null) {
      for ($i = 0; $i < strlen($dataBufferBB); $i++)
        $ret = $ret + ord($dataBufferBB[$i]) * 3;
    }
    return $ret;
  }
  function writeData(string $dataBufferAA)
  {
    $ret = 0;
    if ($dataBufferAA != null) {
      for ($i = 0; $i < strlen($dataBufferAA); $i++)
        $ret = $ret + ord($dataBufferAA[$i]) * 2;
    }
    return $ret;
  }
}

$caller = new Caller();
$callback = new DirectorBinaryStringCallback();
$caller->setCallback($callback);
$sum = $caller->call();
$sumData = $caller->callWriteData();
$caller->delCallback();

check::equal($sum, 9*2*8 + 13*3*5, "Unexpected sum: $sum");
check::equal($sumData, 9*2*8, "Unexpected sumData: $sumData");

// FIXME Error: Cannot instantiate abstract class Callback
// It does make sense as writeData() is abstract
// (new Callback())->run("", "");

$callback = new DirectorBinaryStringCallback();
$caller->setCallback($callback);
$caller->call_null();
$caller->delCallback();
